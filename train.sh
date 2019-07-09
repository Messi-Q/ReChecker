#!/usr/bin/env bash

for i in $(seq 1 5);
do
python SmConVulDetector.py --model BLSTM --lr 0.002 --dropout 0.5 --vector_dim 100 --epochs 10 | tee logs/smartcheck_"$i".log;
done