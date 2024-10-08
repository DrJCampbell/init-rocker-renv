# Setup R Rocker container with renv

This repo contains a make file and associated scripts and documentation to setup an R analysis environment using a R [Rocker](https://rocker-project.org/) container, the [renv](https://rstudio.github.io/renv/articles/renv.html) package environment and a Python Conda environment.

## Quick start

1. Clone repository
2. `cd` to the `init-rocker-renv` directory
3. Build the R and jupyter python environment
  + To build the environment in the repo diectory type `make build`
  + To build and delpoy the environment to a different directory type `make build RHOME=[target direcory]`

> [!IMPORTANT]
> An installation of [Singularity](https://github.com/sylabs/singularity/releases) is required to run the [Rocker](https://rocker-project.org/) [Docker](https://www.docker.com/) container. The command to run singularity can be specficied by setting the `singularity_command` variable in `config.mk`

### ssh
```
git clone git@github.com:phileastbioinf/init-rocker-renv.git
cd init-rocker-renv
make build RHOME=".."
```
### http
```
git clone https://github.com/phileastbioinf/init-rocker-renv.git
cd init-rocker-renv
make build RHOME=".."
```

### Running R

You can run R via the `./R-rocker` script.
`./R-rocker -h` will give you the following help.

```
USAGE: R-rocker -p [command line option string to R] [R script file]\n\n
 * Running R-rocker with no commandline parameters will give you an R shell.
 * Specifying an R script file will run Rscript.
 * Use the -p flag to define the command line argument string to pass to either Rscript or R.
 * Run 'R-rocker container' to get a singularlity shell.
 * Run R-rocker rstudio to spin up an rstudio server via slurm sbatch.
     * -c [number of cores]
     * -m [memory resource request e.g. 50G]
     * -t [server walltime e.g. 8:00:00 (8 hours)]
```

### Container image flavours and R versions

[Rocker](https://rocker-project.org/) offers a number fo different container falvours designed for specifc analysis types along with different versions of R. The specific image/R-version combination can be set in the `config.mk` file. Please see rocker's [image](https://rocker-project.org/images/) list for availabel combinations and names. 
```
rocker_image=verse
R_version=4.2.2
```

### Python

Python is made available by linking a Python Conda environment to the R-rocker container. This is achieved by setting the PATH environment variable in the container to point `python` to the conda version. Reticulate is also configured so Python can be run from within R. You can specific a pre-existing Python Conda environment by setting the `PYTHON_ENV_PATH=[path to python conda environment]` variable in `config.mk`. This defaults the `env/` in the project directory and is created if it does not exist.

### RStudio

RStudio is made available via RStudio RServer. Details on how the server is setup and configured are below.

## Details

### The Process

1. Download and convert Rocker Docker container to singularity container
2. Write local `.Renviron` file
3. Run R within the container and install renv to a temporary local R library path (default `.tmp_r_lib`)
4. Run `renv::init()` and `renv::restore()` to setup renv environment
5. Add `reticulate` configuration to `.Rprofile`
6. Find and expand all symbolic links in the current tree that point outside of it. These paths are mounted when the container starts.
7. Write `R-rocker` script to run instances of R
8. Deploy the environment if `RHOME` has been set

### Bespoke environments

The repo contains a fairly generic `renv.lock`  that contains common pacakges along with a Seurat v5 install. If you would like to work with a custom enviroment replace this `renv.lock` with your own prior to building the enviroment. Alternativly you can reconfgiure the environment via renv post setup. Please see the [renv](https://rstudio.github.io/renv/articles/renv.html) documentation for details.

### Configuration options

All configuration options are contained in `config.mk`.

### Mounting additional paths

You can make additional file system paths available to the R session by adding them to the `ADDITIONAL_PATHS` variable in the `R-rocker` script.
`ADDITIONAL_PATHS="/additional/path/one,additiona/path/two"`

### RStudio

An RStudio server can be spun up with the following command. The server is run by the `run_rstudio_server.sh` script. This script is configured to spin up the server on an HPC node using slurm. Connection details can be found in the slurm output file `rstudio-server.job.xxxxx` once the server job is running. CPU allocation, memory allocation and walltime can be set using the `-c, -m and -t options`.  

```
./R-rocker rstudio
```

### Jupyter server

A jupyter server can be spun up in the same way as rstudio (see above) with the following command. The Jupyter server uses the virtual python environment created during the build process. Jupyter is not configured to run R and does not use the rocker container. Python packages can be installed into the virtual environment using the wrapper script `./venv-install.sh [package names]`. 

```
./R-rocker jupyter
```

### Further reading

* [renv documentation](https://rstudio.github.io/renv/articles/renv.html) for details on configuring renv
* [Rocker](https://rocker-project.org/) for image and R details
* [Rocker for RSudio-server](https://rocker-project.org/use/singularity.html#slurm-job-script)
* [Singularity user guide](https://docs.sylabs.io/guides/3.5/user-guide/)
* [Docker user guide](https://www.docker.com/)
* [Customising R-rocker containers](https://cloud.sylabs.io/dashboard)


## James' notes on specific scRNA-Seq packages

1. After installation (github readme), start R in a terminal using ./R-rocker or start Rstudio using ./R-rocker rstudio

2. You may have to use setwd() to set the working directory to the path starting with /nemo - This happened to me using rstudio.

eg setwd("/nemo/stp/babs/working/campbej/init-rocker-renv/")

Then use the menus 'Session' > 'Restart R'

3. If you have trouble installing monocle3, try doing it in the terminal version

I installed the Bioconductor dependencies first:

	renv::install('bioc::BiocGenerics')
	renv::install('bioc::DelayedArray')
	renv::install('bioc::DelayedMatrixStats',)
	renv::install('bioc::limma')
	renv::install('bioc::lme4')
	renv::install('bioc::S4Vectors')
	renv::install('bioc::SingleCellExperiment',)
	renv::install('bioc::SummarizedExperiment')
	renv::install('bioc::batchelor')
	renv::install('bioc::HDF5Array',)
	renv::install('bioc::terra')
	renv::install('bioc::ggrastr')

Then used wget to download the archived tar.gz source for leidenbase from https://cran.r-project.org/src/contrib/Archive/leidenbase/leidenbase_0.1.30.tar.gz

Then installed from source using:
	renv::install('leidenbase_0.1.30.tar.gz')






