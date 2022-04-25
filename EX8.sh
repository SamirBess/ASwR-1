#!/bin/bash
#PBS -N mnist_rf
#PBS -l select=1:ncpus=128,walltime=00:50:00
#PBS -q qexp
#PBS -e mnist_rf.e
#PBS -o mnist_rf.o

module load R
echo "loaded R"

# Fix for warnings from libfabric/1.12 bug
module swap libfabric/1.12.1-GCCcore-10.3.0 libfabric/1.13.2-GCCcore-11.2.0 

# I want the number to divide 76 = 4*19
time mpirun -np 128 Rscript EX8.r 
