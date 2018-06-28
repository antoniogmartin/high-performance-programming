#!/bin/bash
#PBS -q acap
#PBS -N primes

mpicc -o primeV2 primeV2.c
for((N=1;N<11;N=N+2))
do
 mpirun -np $N $PBS_O_WORKDIR/primeV2 400000 >> datB2.dat
done 
