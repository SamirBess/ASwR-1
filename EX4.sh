#!/bin/bash
#PBS -N rf
#PBS -l select=1:ncpus=128,walltime=00:50:00
#PBS -q qexp
#PBS -e rf_cv.e
#PBS -o rf_cv.o

cd ~/KPMS-IT4I-EX/code
pwd

module load R
echo "loaded R"


for i in {1..10}
  do
    echo "128 and 16 and 16 and 1"   
    time Rscript EX4.r 128 16 16 
  done