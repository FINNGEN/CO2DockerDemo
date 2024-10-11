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
    -it co2docker:dev
```

## Development

### Build docker image

```
docker build \
  --secret id=build_github_pat,src=</path/to/GITHUBPAT.txt> \
    -t co2:dev . 
```
