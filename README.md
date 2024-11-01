# CO2DockerDemo

This is a demo for the [CohortOperations2](https://github.com/finngen/CohortOperations2) tool. 

This demo connects to 2 Eunomia databases stored in the docker and to the [Atlas-demo](https://atlas-demo.ohdsi.org/), and includes the following analysis:

- CohortDiagnostics
- Cohorts Overlaps
- Cohorts Demographics
- CodeWAS
- TimeCodeWAS

Ready docker image is available here: [javiergrata/co2demo](https://hub.docker.com/r/javiergrata/co2demo)

Pull the image by:
```
docker pull javiergrata/co2demo:latest
```

```
docker run --rm  \
    -p 3838:3838 -p 3839:3839 -p 3837:3837 \
    -it co2demo:latest
```
