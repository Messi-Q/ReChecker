import os
import shutil

output = "./block.timestamp/graph_data_name_185.txt"
f = open(output, "r")
lines = f.readlines()

input1 = "../contracts/block.timestamp/"
out1 = "./time/"

for i in lines:
    inp = input1 + i.strip()
    shutil.copy(inp, out1 + i.strip())
