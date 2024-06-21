#!/usr/bin/env bash
#SBATCH --job-name=jupyter
#SBATCH --output=jupyter-server.job.log
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --partition=ncpu
#SBATCH --time='8:00:00'
#SBATCH --mem=64G

LOG='jupyter-server.job.log'
echo $PWD > $LOG 2>&1
ml Singularity/3.6.4 

## Retaining everything relevant for R, so Rstudio under Jupyter lab is functional as well

# Create temporary directory to be populated with directories to bind-mount in the container
# where writable file systems are necessary. Adjust path as appropriate for your computing environment.
# sifdir='/nemo/stp/babs/working/ghanata/code/R/sif/rocker-binder-renv'
workdir=$(python -c 'import tempfile; print(tempfile.mkdtemp())')

mkdir -p -m 700 ${workdir}/run ${workdir}/tmp ${workdir}/var/lib/rstudio-server
cat > ${workdir}/database.conf <<END
provider=sqlite
directory=/var/lib/rstudio-server
END

# Set OMP_NUM_THREADS to prevent OpenBLAS (and any other OpenMP-enhanced
# libraries used by R) from spawning more threads than the number of processors
# allocated to the job.
#
# Set R_LIBS_USER to a path specific to rocker/rstudio to avoid conflicts with
# personal libraries from any R installation in the host environment

if [ -z ${SLURM_JOB_ID+x} ]; then
	OMP_NUM_THREADS_VAL=16
else
	OMP_NUM_THREADS_VAL=${SLURM_JOB_CPUS_PER_NODE}
fi

cat > ${workdir}/rsession.sh <<END
#!/bin/sh
export OMP_NUM_THREADS=${OMP_NUM_THREADS_VAL}
export R_LIBS_USER=${HOME}/R/rocker-rstudio/4.3
exec /usr/lib/rstudio-server/bin/rsession "\${@}"
END

chmod +x ${workdir}/rsession.sh

## removed ${sifdir}/rocker.Renviron:/usr/local/lib/R/etc/Renviron.site since this is configured withint the project environment
export SINGULARITY_BIND="${SINGULARITY_BIND}, \
	${workdir}/run:/run,${workdir}/tmp:/tmp,${workdir}/database.conf:/etc/rstudio/database.conf, \
	${workdir}/rsession.sh:/etc/rstudio/rsession.sh, \
	${workdir}/var/lib/rstudio-server:/var/lib/rstudio-server, \
	/etc/ssl/certs/ca-bundle.crt,${workdir}/tmp/jupyter.sh:/tmp/jupyter.sh, \
	$HOME/.ssh,$HOME/.config/R,$HOME/.config/rstudio,/sys/fs/cgroup, \
	$HOME/.local/share/jupyter/,$HOME/.jupyter/" 

# Do not suspend idle sessions.
# Alternative to setting session-timeout-minutes=0 in /etc/rstudio/rsession.conf
# https://github.com/rstudio/rstudio/blob/v1.4.1106/src/cpp/server/ServerSessionManager.cpp#L126
export SINGULARITYENV_RSTUDIO_SESSION_TIMEOUT=0

export SINGULARITYENV_USER=$(id -un)
export SINGULARITYENV_PASSWORD=$(openssl rand -base64 15)
# get unused socket per https://unix.stackexchange.com/a/132524
# tiny race condition between the python & singularity commands
readonly PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
cat 1>&2 <<END
1. Point your web browser to http://$(hostname).nemo.thecrick.org:${PORT}

2. SSH tunnel from your workstation using the following command:

   ssh -N -L 8888:$(hostname).nemo.thecrick.org:${PORT} ${SINGULARITYENV_USER}@LOGIN-HOST

   and point your web browser to http://localhost:8888

When done using Jupyter lab, terminate the job by:

1. Exit the Jupyter lab Session (From within Jupyter lab interface: File > Shut Down)
2. Issue the following command on the login node:

      scancel -f ${SLURM_JOB_ID}
END

# We will write Jupyter script in a file to send notifications
cat > ${workdir}/tmp/jupyter.sh <<END
#!/bin/sh


# Symlink current dir to home
ln -s $PWD $HOME/$(basename $PWD)
# Symlink babs dir to home
ln -s /nemo/stp/babs $HOME/babs

# Start server
jupyter lab --ip 0.0.0.0 --no-browser --port ${PORT} --NotebookApp.token='' --NotebookApp.password=''

printf 'Jupyter lab exited\n' 1>&2
END

singularity exec --cleanenv --containall ${sifdir}/rocker-binder-renv_v1_R4.3.2.sif \
	sh /tmp/jupyter.sh >> $LOG 2>&1
