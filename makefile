
## makefile to configure an R Rocker container with Renv environment

rocker_image=verse
R_version=4.2.2
rocker_image_uri=docker://rocker/${rocker_image}:${R_version}
rocker_image_file=${rocker_image}_${R_version}.sif
RENV_PATHS_ROOT=/camp/stp/babs/working/software/renv
RENV_PATHS_PREFIX=rocker
RENV_PATHS_LIBRARY=renv/library
R_LIBS_PROJECT=.tmp_r_lib
PROJECT_PATH=$(shell readlink -f ${PWD})
TMP=/tmp
ROCKER_LINK=rockerimage.sif

build:

R_runscript:
ifeq (,$(wildcard ./R-rocker))
	cat R-tmp | sed -e "s|RENV_PATHS_ROOT=\[set path\]|RENV_PATHS_ROOT=$(RENV_PATHS_ROOT)|" > R-rocker
	rm R-tmp
endif

#.PHONY: init_renv
init_renv:
ifeq (,$(wildcard ./renv))
	singularity exec \
	--bind ${PROJECT_PATH},${RENV_PATHS_ROOT},${TMP} \
	--pwd ${PROJECT_PATH} \
	--containall \
	--cleanenv \
	./${ROCKER_LINK} R -e ".libPaths( \"${R_LIBS_PROJECT}\" );renv::init();renv::restore();q( save = \"no\")"
endif

.PHONY: install_renv
install_renv:
ifeq (,$(wildcard ${R_LIBS_PROJECT}/renv))
	@mkdir -p ${R_LIBS_PROJECT}
	singularity exec \
	--bind ${PROJECT_PATH},${TMP} \
	--pwd ${PROJECT_PATH} \
	--containall \
	--cleanenv \
	./${ROCKER_LINK} R -e ".libPaths( \"${R_LIBS_PROJECT}\" );install.packages( \"renv\" );q( save = \"no\")"
endif

.PHONY: renv
renv:
ifeq (,$(wildcard ./.Renviron))
	@echo "# maintain separability within the cache" > .Renviron
	@echo "RENV_PATHS_PREFIX=$(RENV_PATHS_PREFIX)" >> .Renviron
	@echo "# but do use the cache!" >> .Renviron
	@echo "RENV_PATHS_ROOT=$(RENV_PATHS_ROOT)" >> .Renviron
	@echo "# ensure that the renv library stays in the project directory" >> .Renviron
	@echo "RENV_PATHS_LIBRARY=renv/library" >> .Renviron
	@echo "# Need a temporary system library to install renv right at the start" >> .Renviron
	@echo "R_LIBS_USER=.tmp_r_lib" >> .Renviron
endif

.PHONY: rocker
rocker:
ifeq (,$(wildcard ./${rocker_image_file}))
	module load Singularity/3.6.4;
	singularity pull ${rocker_image_uri}
	ln $(rocker_image_file) ${ROCKER_LINK}
endif
