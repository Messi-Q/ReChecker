import random

SmartContractLabel = "./infinite_loop/infinite_loop_contract_label.txt"
SmartContractNumber = "./infinite_loop/1.txt"
out = "./1.txt"

ContractLabel = open(SmartContractLabel, "r")
ContractLabels = ContractLabel.readlines()
ContractNumber = open(SmartContractNumber, "r")
ContractNumbers = ContractNumber.readlines()
f_w = open(out, "a")

list1 = []
list2 = []
for i in range(len(ContractLabels)):
    if ContractLabels[i].strip() == "0":
        list1.append(i)
    else:
        list2.append(i)

print(list1)
print(list2)

slice1 = random.sample(list1, int(len(list1) * 0.5))
slice2 = random.sample(list2, int(len(list2) * 0.2))

print(slice1)
print(slice2)

list3 = []
for i in range(len(ContractNumbers)):
    list3.append(int(ContractNumbers[i].strip()))

print(sum(list3))


"""
for i in range(len(ContractNumbers)):
    if i in slice1:
        f_w.write(str(int(ContractNumbers[i].strip()) + 1) + '\n')
    elif i in slice2:
        f_w.write(str(int(ContractNumbers[i].strip()) + 1) + '\n')
    else:
        f_w.write(ContractNumbers[i])

"""