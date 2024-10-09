FROM --platform=linux/amd64  rocker/shiny:4.4.1
RUN /rocker_scripts/setup_R.sh https://packagemanager.posit.co/cran/__linux__/jammy/2024-09-24

# install OS dependencies including java and python 3
RUN apt-get update && apt-get install -y openjdk-8-jdk liblzma-dev libbz2-dev libncurses5-dev curl python3-dev python3.venv git \
    # rjava
    libssl-dev libcurl4-openssl-dev  libpcre2-dev libicu-dev \
    # xml2
    libxml2-dev \
    # sodium
    libsodium-dev\
    # systemfonts
    libfontconfig1-dev \
    # textshaping
    libharfbuzz-dev libfribidi-dev\
    #ragg
    libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev\
&& R CMD javareconf \
&& rm -rf /var/lib/apt/lists/*

COPY shinyApps/renv.lock ./renv.lock

# install renv & restore packages
RUN --mount=type=secret,id=build_github_pat \
	cp /usr/local/lib/R/etc/Renviron /tmp/Renviron \
  && echo "GITHUB_PAT=$(cat /run/secrets/build_github_pat)" >> /usr/local/lib/R/etc/Renviron \
  && Rscript -e 'install.packages("renv")' \
  && Rscript -e 'renv::restore()' \
  && cp /tmp/Renviron /usr/local/lib/R/etc/Renviron

# setup env variables in order to run cohortoperations
COPY config/* /config/
COPY eunomiaDatabases/* /eunomiaDatabases/
# TEMP give all permisions, without this i can read the database but not to create the tables
RUN chmod -R 777 /eunomiaDatabases

# copy app files
COPY shinyApps/apps/CohortOperations2_app.R /srv/shiny-server/co2/app.R
COPY shinyApps/apps/CO2AnalysisModulesViewer_app.R /srv/shiny-server/co2analysis/app.R

# drivers should be in the same path as shiny apps,
# otherwiser shiny server will not be able to access them
COPY ./bigquery /bigquery
RUN mkdir -p /srv/shiny-server/jdbc_drivers
RUN unzip /bigquery/bq_drivers_1.2.14.zip -d /srv/shiny-server/jdbc_drivers

# shiny apps confgiuration
COPY shinyApps/shiny-server.conf /etc/shiny-server/shiny-server.conf

# default configs
# choose mode for docker between
# 'Eunomia' or 'AtlasDevelopment' or 'Sandbox'
ENV CO2_CONFIG_MODE='Eunomia'
ENV DATABASECONNECTOR_JAR_FOLDER='/srv/shiny-server/jdbc_drivers'
ENV CO2_CONFIG_PATH='/config'
ENV EUNOMIA_DATA_FOLDER='/eunomiaDatabases'

RUN touch /srv/shiny-server/co2/errorReportSql.txt && chmod 777 /srv/shiny-server/co2/errorReportSql.txt

# Enable Logging from stdout
ENV SHINY_LOG_STDOUT=1
ENV SHINY_LOG_STDERR=1

# Set BUILD_TYPE=development to update the CohortOperations2 and CO2AnalysisModules without having to update renv.lock
ARG BUILD_TYPE=production
# if BUILD_TYPE=development, the following two arguments are used to specify the branch to be used for the CohortOperations2 and CO2AnalysisModules
# see ?renv::install for syntax
ARG CO2_BUILD_POINT=FINNGEN/CohortOperations2@development
ARG CO2ANALYISMODULES_BUILD_POINT=FINNGEN/CO2AnalysisModules@development


# dummy arg to bust cache
ARG CACHE_BUST=1

RUN --mount=type=secret,id=build_github_pat \
  if [ "$BUILD_TYPE" = "development" ]; then \
  	cp /usr/local/lib/R/etc/Renviron /tmp/Renviron \
    && echo "GITHUB_PAT=$(cat /run/secrets/build_github_pat)" >> /usr/local/lib/R/etc/Renviron \
    && Rscript -e 'renv::install("'$CO2_BUILD_POINT'", lock = TRUE)' \
    && Rscript -e 'renv::install("'$CO2ANALYISMODULES_BUILD_POINT'", lock = TRUE)' \
    # TEMP avoid updating the following packages
    && Rscript -e 'renv::install("dbplyr@2.4.0", lock = TRUE)' \
    && Rscript -e 'renv::install("FeatureExtraction@3.6.0", lock = TRUE)' \
    # END TEMP
    && cp /tmp/Renviron /usr/local/lib/R/etc/Renviron;\
  fi

# TEMP may be a better way
RUN cp /renv.lock /srv/shiny-server/co2/renv.lock

EXPOSE 8787
EXPOSE 8788
