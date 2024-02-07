ml = module is-loaded $1 || module load $1
singularity_command=$(call ml,Singularity/3.6.4); singularity
conda_command=$(call ml,Anaconda3/2023.09-0); conda

rocker_image=verse
R_version=4.3.1
RENV_PATHS_ROOT=/camp/stp/babs/working/software/renv
RENV_PATHS_PREFIX=rocker
RENV_PATHS_LIBRARY=renv/library
R_LIBS_PROJECT=.tmp_r_lib
TMP=/tmp
ROCKER_ALIAS=rockerimage.sif
