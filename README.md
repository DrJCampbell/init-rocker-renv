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
### Running R

You can run R via the `./R-rocker` script.
`./R-rocker -h` will give you the following help.

```
USAGE: R-rocker -p [command line option string to R] [R script file]
* Running R-rocker with no commandline parameters will give you an R shell."
* Specifying an R script file will run Rscript."
* Use the -p flag to define the command line argument string to pass to either Rscript or R."
* Run 'R-rocker container' to get a singularlity shell."
```

## Details

### The Process

1. Download and convert Rocker Docker container to singularity container
2. Write local `.Renviron` file
3. Run R within the container and install renv to a temporary local R library path (default `.tmp_r_lib`)
4. Run `renv::init()` and `renv::restore()` to setup renv environment
5. Find and expand all symbolic links in the current tree that point outside of it. These paths are mounted when the container starts.
6. Write `R-rocker` script to run instances of R
7. Deply the environment if `RHOME` has been set

### Bespoke environments

### Configuration options

### Mounting new paths

### Further reading



