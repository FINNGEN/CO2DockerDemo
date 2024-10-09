#
# Config Mode
#
# All configs need:
# - CO2_CONFIG_MODE : Identifier for the config mode
# - CO2_CONFIG_PATH : path to the folder with the config yml files
CO2ConfigMode <- Sys.getenv('CO2_CONFIG_MODE')
configPath <- Sys.getenv('CO2_CONFIG_PATH')

# check correct settings
possibleConfigModes <- c("Eunomia")
if( !(CO2ConfigMode %in% possibleConfigModes) ){
  message("Please select a valid database from: ", paste(possibleConfigModes, collapse = ", "))
  stop()
}


#
# Eunomia Mode
#
if (CO2ConfigMode == "Eunomia") {

  CO2AnalysisModulesConfig <- CohortOperations2::readAndParseYalm(
    pathToYalmFile = file.path(configPath, "atlasDemo_CO2AnalysisModulesConfig.yml")
  )

}

#
# run app
#
app <- CO2AnalysisModules::run_app(
  CO2AnalysisModulesConfig = CO2AnalysisModulesConfig
)
app
