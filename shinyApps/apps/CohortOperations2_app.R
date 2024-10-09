#
# Config Mode
#
# All configs need:
# - CO2_CONFIG_MODE : Identifier for the config mode
# - CO2_CONFIG_PATH : path to the folder with the config yml files
CO2ConfigMode <- Sys.getenv('CO2_CONFIG_MODE')
configPath <- Sys.getenv('CO2_CONFIG_PATH')

# timestamp with milliseconds
timestamp <- as.character(as.numeric(format(Sys.time(), "%d%m%Y%H%M%OS2"))*100)

# check correct settings
possibleConfigModes <- c("Eunomia")
if( !(CO2ConfigMode %in% possibleConfigModes) ){
  message("Please select a valid database from: ", paste(possibleConfigModes, collapse = ", "))
  stop()
}

#
# Eunomia Mode
#
# Needs:
# - EUNOMIA_DATA_FOLDER : path folder with Eunomia databases
#
if (CO2ConfigMode == "Eunomia") {

  if( Sys.getenv("EUNOMIA_DATA_FOLDER") == "" ){
    message("EUNOMIA_DATA_FOLDER not set. Please set this environment variable to the path of the Eunomia data folder.")
    stop()
  }

  pathToGiBleedEunomiaSqlite  <- Eunomia::getDatabaseFile("GiBleed", overwrite = FALSE)
  pathToMIMICEunomiaSqlite  <- Eunomia::getDatabaseFile("MIMIC", overwrite = FALSE)

  databasesConfig <- CohortOperations2::readAndParseYalm(
    pathToYalmFile = file.path(configPath, "eunomia_databasesConfig.yml"),
    pathToGiBleedEunomiaSqlite = pathToGiBleedEunomiaSqlite,
    pathToMIMICEunomiaSqlite = pathToMIMICEunomiaSqlite
  )

}

#
# Analysis Modules
#
analysisModulesConfig <- CohortOperations2::readAndParseYalm(
  pathToYalmFile = file.path(configPath, "all_analysisModulesConfig.yml")
)

#
# run app
#
app <- CohortOperations2::run_app(
  databasesConfig = databasesConfig,
  analysisModulesConfig = analysisModulesConfig,
)

app
