
# Install the packages that are needed for the shiny apps and record the packages in the renv.lock file
# Installing these packages will install all the dependencies

renv::install("FINNGEN/CohortOperations2", prompt = FALSE)
renv::install("FINNGEN/CO2AnalysisModules", prompt = FALSE)

# Here resinstall some packages to rewrite dependencies
renv::install("dbplyr@2.4.0", prompt = FALSE)
renv::install("FeatureExtraction@3.6.0", prompt = FALSE)

# save in renv.lock
renv::snapshot()
