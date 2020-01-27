#!/usr/bin/env bash

for i in $(seq 1 10);
do
python SmConVulDetector.py | tee logs/lstm/smartcheck_"$i".log;
done