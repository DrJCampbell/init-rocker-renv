
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

build: R_runscript init_renv install_renv renv rocker

R_runscript: R-rocker
	cat R-tmp | sed -e "s|RENV_PATHS_ROOT=\[set path\]|RENV_PATHS_ROOT=$(RENV_PATHS_ROOT)|" > $@
	chmod 700 $@
	rm R-tmp

#.PHONY: init_renv
init_renv: renv
	singularity exec \
	--bind ${PROJECT_PATH},${RENV_PATHS_ROOT},${TMP} \
	--pwd ${PROJECT_PATH} \
	--containall \
	--cleanenv \
	./${ROCKER_LINK} R -e ".libPaths( \"${R_LIBS_PROJECT}\" );renv::init();renv::restore();q( save = \"no\")"

.PHONY: install_renv
install_renv: $(R_LIBS_PROJECT)/renv
	@mkdir -p ${R_LIBS_PROJECT}
	singularity exec \
	--bind ${PROJECT_PATH},${TMP} \
	--pwd ${PROJECT_PATH} \
	--containall \
	--cleanenv \
	./${ROCKER_LINK} R -e ".libPaths( \"${R_LIBS_PROJECT}\" );install.packages( \"renv\" );q( save = \"no\")"

.PHONY: renv
renv: .Renviron
	@echo "# maintain separability within the cache" > $@
	@echo "RENV_PATHS_PREFIX=$(RENV_PATHS_PREFIX)" >> $@
	@echo "# but do use the cache!" >> $@
	@echo "RENV_PATHS_ROOT=$(RENV_PATHS_ROOT)" >> $@
	@echo "# ensure that the renv library stays in the project directory" >> $@
	@echo "RENV_PATHS_LIBRARY=renv/library" >> $@
	@echo "# Need a temporary system library to install renv right at the start" >> $@
	@echo "R_LIBS_USER=.tmp_r_lib" >> $@

.PHONY: rocker
rocker: $(rocker_image_file)
	module load Singularity/3.6.4;
	singularity pull ${rocker_image_uri}
	ln $@ ${ROCKER_LINK}
