# Setup R Rocker container with renv

This repo contains a make file and associated scripts and documentation to setup an R analysis environment using a R [Rocker](https://rocker-project.org/) container and [renv](https://rstudio.github.io/renv/articles/renv.html) package environment.

## Quick start

1. Clone repository
2. cd to the 'init-rocker-renv directory'
3. Build the R environment
  + To build the environment in the repo diectory type `make build`
  + To build and delpoy the environment to a different directory type `make build RHOME=[target direcory]`

`git@github.com:phileastbioinf/init-rocker-renv.git`
`make build RHOME=".."`


