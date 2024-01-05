singularity_command = $(call ml Singularity/3.4.2); singularity

rocker_image=verse
R_version=4.2.2
RENV_PATHS_ROOT=/camp/stp/babs/working/software/renv
RENV_PATHS_PREFIX=rocker
RENV_PATHS_LIBRARY=renv/library
R_LIBS_PROJECT=.tmp_r_lib
TMP=/tmp
ROCKER_ALIAS=rockerimage.sif
