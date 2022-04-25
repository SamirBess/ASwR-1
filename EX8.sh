#!/bin/bash
#PBS -N mnist_rf
#PBS -l select=2:mpiprocs=128,walltime=00:50:00
#PBS -q qexp
#PBS -e mnist_rf.e
#PBS -o mnist_rf.o

cd ~/ASwR

module load R
echo "loaded R"

# Fix for warnings from libfabric/1.12 bug
module swap libfabric/1.12.1-GCCcore-10.3.0 libfabric/1.13.2-GCCcore-11.2.0 
export OMPI_MCA_mpi_warn_on_fork=0
export RDMAV_FORK_SAFE=1


time mpirun -np 32 Rscript EX8.r 
