
input = "./reentrancy/SmartContract_fragment.txt"
out = "out.txt"

f = open(input, "r")
f_w = open(out, "a")

lines = f.readlines()
count = 1

for i in range(len(lines)):
    if lines[i].strip() == "---------------------------------":
        count += 1
        result = lines[i + 1].strip().split(" ")
        result1 = count
        result2 = result[1]
        f_w.write("---------------------------------" + "\n")
        f_w.write(str(result1) + " " + str(result2) + "\n")
    elif ".sol" not in lines[i]:
        f_w.write(lines[i])
