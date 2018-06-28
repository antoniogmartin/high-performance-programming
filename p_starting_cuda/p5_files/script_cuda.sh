#!/bin/bash
 gcc -o ejemplo3 ejemplo3.c -std=c99
for i in {0..9}
do
echo "**************"
./ejemplo3 ./data/$i/input0.raw ./data/$i/input0.raw
./ejemplo4/src/ejemplo4 ./data/$i/input0.raw ./data/$i/input0.raw		
echo "**************"
done
