#!/usr/bin/env bash

for i in $(seq 1 10);
do
python SmConVulDetector.py | tee evaluations/logs/blstm_att/smartcheck_"$i".log;
done