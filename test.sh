#!/bin/bash

for taux in 3 5 15 30
do 
  for ratio in 2 3 4 5 6
  do
    for pop in 50 100 200
    do
      for x in 1 2 3 4 5
      do
        for y in 1 2 3 4 5 6 7 8 9 10
        do
          python3 mastermind.py $ratio $taux 40 $pop "eval.csv"
        done
      done
    done
  done
done