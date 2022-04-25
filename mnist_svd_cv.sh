#!/bin/bash
#PBS -N mnist_svd_cv
#PBS -l select=2:ncpus=128,walltime=00:50:00
#PBS -q qexp
#PBS -e mnist_svd_cv.e
#PBS -o mnist_svd_cv.o

cd ~/ASwR
pwd

module load R
echo "loaded R"

## --args blas fork
#time Rscript mnist_svd_cv.R --args 4 32
time mpirun -np 8 Rscript mnist_svd_cv.R --args 4 4
