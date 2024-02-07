
## makefile to configure an R Rocker container with Renv environment

include config.mk

ifndef RHOME
    RHOME=./
endif

RHOME_FULL=$(shell readlink -f ${RHOME})
rocker_image_uri=docker://rocker/${rocker_image}:${R_version}
rocker_image_file=${rocker_image}_${R_version}.sif
BUILD_PATH=$(shell readlink -f ${PWD})
ADDITIONAL_PATHS=$(shell ./find-symlinks.sh ${RHOME})
PYTHON_ENV_HOME=./env
build: python_env rocker renv install_renv init_renv R_runscript

R_runscript: R-rocker

R-rocker:
	echo ${RHOME}
	cat R-tmp | sed -e "s|RENV_PATHS_ROOT=\[set path\]|RENV_PATHS_ROOT=$(RENV_PATHS_ROOT)|" | \
		sed -e "s|ADDITIONAL_PATHS=\[set path\]|ADDITIONAL_PATHS=${ADDITIONAL_PATHS}|" > $@
	chmod 700 $@
	@if [ ${RHOME_FULL} != ${BUILD_PATH} ]; then \
        	cp R-rocker ${RHOME}; \
		chmod -R 755 renv; \
		cp -r *renv* ${RHOME}; \
		cp ${ROCKER_ALIAS} ${RHOME}; \
		cp .Rprofile ${RHOME}; \
		cp .Renviron ${RHOME}; \
		cd ${RHOME}; \
		#@echo "removing ${BUILD_PATH}"; \
		#rm -rfI ${BUILD_PATH}; \
	fi
	#rm R-tmp

#.PHONY: init_renv
#init_renv: renv

init_renv:
	$(singularity_command) exec \
	--bind ${BUILD_PATH},${RENV_PATHS_ROOT},${TMP} \
	--pwd ${BUILD_PATH} \
	--containall \
	--cleanenv \
	./${ROCKER_ALIAS} R -e ".libPaths( \"${R_LIBS_PROJECT}\" );renv::init();renv::restore();q( save = \"no\")"
	echo "setwd( Sys.getenv( \"BABS_PROJECT_HOME\" ) )" >> .Rprofile

.PHONY: install_renv
install_renv: $(R_LIBS_PROJECT)/renv

$(R_LIBS_PROJECT)/renv:
	@mkdir -p ${R_LIBS_PROJECT}
	${singularity_command} exec \
	--bind ${BUILD_PATH},${TMP} \
	--pwd ${BUILD_PATH} \
	--containall \
	--cleanenv \
	./${ROCKER_ALIAS} R -e ".libPaths( \"${R_LIBS_PROJECT}\" );install.packages( \"renv\" );q( save = \"no\")"

.PHONY: renv
renv: .Renviron

.Renviron:
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
	
$(rocker_image_file):
	${singularity_command} pull ${rocker_image_uri}
	ln $@ ${ROCKER_ALIAS}

.PHONY: python_env
python_env: $(PYTHON_ENV_HOME)

$(PYTHON_ENV_HOME):
	mkdir env
	conda create --prefix=$@ python	
