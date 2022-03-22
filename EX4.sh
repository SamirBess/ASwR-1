#!/bin/bash
#PBS -N rf
#PBS -l select=1:ncpus=128,walltime=00:50:00
#PBS -q qexp
#PBS -e rf_cv.e
#PBS -o rf_cv.o

cd ~/ASwR
pwd

module load R
echo "loaded R"


time Rscript EX4.R 128 16 16 
