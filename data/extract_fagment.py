InputSmartContractDir = "../contracts/time/"
SmartContractName = "./timestamp/graph_data_name_185.txt"
SmartContractLabel = "./timestamp/graph_data_label_185.txt"
SmartContractNumber = "./timestamp/graph_data_number_185.txt"
out = "./timestamp/timestamp.txt"

ContractName = open(SmartContractName, "r")
ContractNames = ContractName.readlines()
ContractLabel = open(SmartContractLabel, "r")
ContractLabels = ContractLabel.readlines()
ContractNumber = open(SmartContractNumber, "r")
ContractNumbers = ContractNumber.readlines()
f_w = open(out, "a")

count = 0

for i in range(len(ContractNames)):
    name = ContractNames[i].strip()
    label = ContractLabels[i].strip()
    number = ContractNumbers[i].strip()

    for i in range(int(number)):
        count += 1
        f_w.write(str(count) + " " + name + "\n")
        codes = []
        f = open(InputSmartContractDir + name, "r")
        lines = f.readlines()
        for line in lines:
            text = line.strip()
            if text != "":
                codes.append(text)

        for k in range(len(codes)):
            f_w.write(codes[k] + "\n")

        f_w.write(str(label) + "\n")
        f_w.write("---------------------------------" + "\n")

