# Setup R Rocker container with renv

This repo contains a make file and associated scripts and documentation to setup an R analysis environment using a R [Rocker](https://rocker-project.org/) container and [renv](https://rstudio.github.io/renv/articles/renv.html) package environment.

## Quick start

1. Clone repository
2. cd to the `init-rocker-renv` directory
3. Build the R environment
  + To build the environment in the repo diectory type `make build`
  + To build and delpoy the environment to a different directory type `make build RHOME=[target direcory]`

> [!IMPORTANT]
> An install of [Singularity](https://github.com/sylabs/singularity/releases) is required to run the [Rocker](https://rocker-project.org/) [Docker](https://www.docker.com/) container.

### ssh
```
git clone git@github.com:phileastbioinf/init-rocker-renv.git
make build RHOME=".."
```
### http
```
git clone https://github.com/phileastbioinf/init-rocker-renv.git
make build RHOME=".."
```

## Details

The process is as follows:

1. 

