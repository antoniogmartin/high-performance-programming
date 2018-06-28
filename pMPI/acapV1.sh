#!/bin/bash
#PBS -q acap
#PBS -N primes

mpicc -o prime prime.c
for((N=1;N<11;N=N+2))
do
 mpirun -np $N $PBS_O_WORKDIR/prime 400000 >> datA2.dat
done 
