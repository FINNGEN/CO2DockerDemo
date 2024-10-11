########################################
#### CURRENT FILE: ON START SCRIPT #####
########################################

install.packages("renv")

## activate renv and install usethis
renv::init()
renv::activate()
renv::install("usethis")


## Fill the DESCRIPTION ----
usethis::use_description(
  fields = list(
    Title = "CO2DockerDemo",
    Description = "Project to manage the shiny apps in CO2Docker",
    `Authors@R` = 'person("Javier", "Gracia-Tabuenca", email = "javier.graciatabuenca@tuni.fi",
                          role = c("aut", "cre"),
                          comment = c(ORCID = "0000-0002-2455-0598"))',
    Language =  "en"
  )
)

