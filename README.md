# CO2DockerDemo

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
