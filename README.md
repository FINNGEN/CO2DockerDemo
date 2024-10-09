# CO2DockerDemo

Ready docker image is available here: `eu.gcr.io/atlas-development-270609/co2:dev`. 

Pull the image by:
```
docker pull eu.gcr.io/atlas-development-270609/co2:dev
```

Next sections describe how to run docker image using different configs:
- Eunomia database (default)
- Development ATLAS & WebAPI and BigQuery database
- Sandbox 

### 1. Run docker image using default Eunomia configs.
```
docker run --rm  \
    -p 3838:3838 -p 3839:3839 \
    -it eu.gcr.io/atlas-development-270609/co2:dev
```

### 2. Run docker image using development ATLAS and WebAPI using dummy FinnGen OMOP tables and BigQuery as a backend.

ATLAS and WebAPI using development OMOP tables in BigQeury are are running in a docker network from the instance `ohdsi-atlas-dev-manual-ak-vm` in `atlas-development-270609` project. To connect to ATLAS a couple of steps are needed.

First, we need to get a key to the service account through which we are going to connect to BQ tables.
Get service account JSON key file for the default Compute Engine service account `146473670970-compute@developer.gserviceaccount.com` in project `atlas-development-270609`. From Google Console choose the project `atlas-development-270609` and navigate to IAM & Admin > Service Accounts, then select "Compute Engine default service account". Once the window with the details for the service account open, select Keys tab and a new JSON key.
 
Set up the environment variable that contains the service account json key file that you just obtained by running:
```
export SERVICE_ACCOUNT_KEY_JSON=<PATH_TO_JSON_FILE>
```

Then, we need to establish connection with ATLAS. In the Google Cloud Console select `atlas-development-270609` project, go to the VPC Network > Firewall, select the existing rule `ohdsi-atlas-dev-tcp` and edit it - add your local IP address to the IP ranges and save. Confirm that ATLAS and WebAPI are available by opening `http://34.22.198.226:8788/atlas` and `http://34.22.198.226:8787/WebAPI/info`, respectively.

Run the docker:
```
docker run --rm \
    -p 3838:3838 -p 3839:3839 \
    -e CO2_CONFIG_MODE="AtlasDevelopment" \
    -v $SERVICE_ACCOUNT_KEY_JSON:/keys/keys.json \
    -e GCP_SERVICE_KEY="/keys/keys.json" \
    -it eu.gcr.io/atlas-development-270609/co2:dev
```


### 3. Run docker image using sandbox configs (only in sandbox).

```
docker run --rm -p 3838:3838 -p 3839:3839 \
    -e CO2_CONFIG_MODE="Sandbox" \
    -e SANDBOX_PROJECT="$SANDBOX_PROJECT" \
    -e SESSION_MANAGER="$SESSION_MANAGER" \
    -e SANDBOX_TOKEN="$(cat $HOME/.sandbox_token)" \
    -it eu.gcr.io/finngen-sandbox-v3-containers/co2:dev
```

Open http://localhost:3839, http://localhost:3838/co2analysis. 


## Development

### Build docker image

```
docker build \
  --secret id=build_github_pat,src=</path/to/GITHUBPAT.txt> \
  --build-arg BUILD_TYPE=<build_type> \
  -t co2:de . 
```

Where </path/to/GITHUBPAT.txt> is the path to the file with the GitHub Personal Access Token (PAT), and <build_type> is one of the following:
- `production` for production build. Will install packages only as stated in the `renv.lock` file.
- `development` for development build. Will update CohortOperation2 and CO2AnalysisModules packages from the development branch in the GitHub repository.
Alternatively, one can set `--build-arg CO2_BUILD_POINT=<build_point_renv_syntax>` and `--build-arg CO2ANALYISMODULES_BUILD_POINT=<build_point_renv_syntax>` to set an other build point for the CohortOperation2 and CO2AnalysisModules packages. eg `--build-arg CO2_BUILD_POINT=github::FINNGEN/CohortOperation2@my_dev_branch`. Add flag `--build-arg CACHEBUST=$(date +%s)` to force to rebuild docker from pulling specific branches when in development mode.

Example:
```
docker build --secret id=build_github_pat,src=GITHUBPAT.txt \
  --build-arg BUILD_TYPE=development \
  --build-arg CO2_BUILD_POINT=FINNGEN/CohortOperations2@link-to-viewer-in-codewas \
  --build-arg CO2ANALYISMODULES_BUILD_POINT=FINNGEN/CO2AnalysisModules@gwas-remove-duplicates-and-warn \
  --build-arg CACHE_BUST=6 \
  -t co2:dev .
```

### Tag and push the image 

To atlas-development-270609 project:

```
docker tag co2:dev eu.gcr.io/atlas-development-270609/co2:<tag>
docker push eu.gcr.io/atlas-development-270609/co2:<tag>
```

Where `<tag>` is the can be:
- `latest` for the production build
- `dev` for the development build
- `dev-<name>` for the development build for the build with the name `<name>`, typically the developer name or the branch name.

To sandbox:

```
docker tag eu.gcr.io/finngen-sandbox-v3-containers/co2:<tag>
docker push eu.gcr.io/finngen-sandbox-v3-containers/co2:<tag>
```
Where `<tag>` is the can be:
- `latest` for the production build
- `dev` for the development build
- `dev-<name>` for the development build for the build with the name `<name>`, typically the developer name or the branch name.
