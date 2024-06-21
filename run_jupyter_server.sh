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

# Create temporary directory to be populated with directories to bind-mount in the container
# where writable file systems are necessary. Adjust path as appropriate for your computing environment.
# sifdir='/nemo/stp/babs/working/ghanata/code/R/sif/rocker-binder-renv'
workdir=$(./env/bin/python -c 'import tempfile; print(tempfile.mkdtemp())')

mkdir -p -m 700 ${workdir}/tmp

if [ -z ${SLURM_JOB_ID+x} ]; then
	OMP_NUM_THREADS_VAL=16
else
	OMP_NUM_THREADS_VAL=${SLURM_JOB_CPUS_PER_NODE}
fi

# get unused socket per https://unix.stackexchange.com/a/132524
# tiny race condition between the python & singularity commands
readonly PORT=$(./env/bin/python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
cat 1>&2 <<END
1. Point your web browser to http://$(hostname).nemo.thecrick.org:${PORT}

2. SSH tunnel from your workstation using the following command:

   ssh -N -L 8888:$(hostname).nemo.thecrick.org:${PORT} ${USER}@$(hostname).nemo.thecrick.org

   and point your web browser to http://localhost:8888

When done using Jupyter lab, terminate the job by:

1. Exit the Jupyter lab Session (From within Jupyter lab interface: File > Shut Down)
2. Issue the following command on the login node:

      scancel -f ${SLURM_JOB_ID}
END

# We will write Jupyter script in a file to send notifications
cat > ${workdir}/tmp/jupyter.sh <<END
#!/bin/sh

# Start server
jupyter lab --ip 0.0.0.0 --no-browser --port ${PORT} --NotebookApp.token='' --NotebookApp.password=''

printf 'Jupyter lab exited\n' 1>&2
END

source ./venv/bin/activate
sh ${workdir}/tmp/jupyter.sh >> $LOG 2>&1
