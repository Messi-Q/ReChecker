import os
import re
import csv


# 函数分割
def split_function(filepath):
    function_list = []
    f = open(filepath, 'r')
    lines = f.readlines()
    f.close()
    flag = -1  # 作为记号

    for line in lines:
        text = line.strip()
        if len(text) > 0 and text != "\n":
            if text.split()[0] == "function" or text.split()[0] == "constructor":
                function_list.append([text])
                flag += 1
            elif len(function_list) > 0 and ("function" or "constructor" in function_list[flag][0]):
                function_list[flag].append(text)

    return function_list


# 定位合约中 call.value 的位置
def find_location(filepath):
    allFunctionList = split_function(filepath)  # 存放所有的函数
    code_fragments = []  # code fragment 代码块
    callValueList = []  # 存放调用 call.value 的 W 函数
    CFunctionList = []  # 存放调用 W 函数的所有 C 函数
    withdrawNameList = []  # 存放调用 call.value 的 W 函数名
    otherFunctionList = []  # 存储 call.value 以外的函数
    params = []  # 存储 W 函数的参数

    # 存储调用 call.value 函数以外的函数
    for i in range(len(allFunctionList)):
        flag = 0
        for j in range(len(allFunctionList[i])):
            text = allFunctionList[i][j]
            if '.call.value' in text:
                flag += 1
        if flag == 0:
            otherFunctionList.append(allFunctionList[i])

    # (1) 遍历所有函数, 找到 call.value 关键字; 将包含 call.value 关键字的函数存入 callValueList & code_fragments;
    for i in range(len(allFunctionList)):
        for j in range(len(allFunctionList[i])):
            text = allFunctionList[i][j]
            if '.call.value' in text:
                location_i, location_j = i, j  # call.value 所处的位置
                # print("Call Value Location: ", allFunctionList[location_i])  # allFunctionList[location_i]
                callValueList.append(allFunctionList[location_i])

                # 获取 W 函数的参数
                ss = allFunctionList[location_i][0]
                p = re.compile(r'[(](.*?)[)]', re.S)  # 最小匹配
                result = re.findall(p, ss)
                result_params = result[0].split(",")

                for n in range(len(result_params)):
                    params.append(result_params[n].strip().split(" ")[-1])

                tmp = re.compile(r'\b([_A-Za-z]\w*)\b(?:(?=\s*\w+\()|(?!\s*\w+))')
                result_withdraw = tmp.findall(allFunctionList[location_i][0])
                withdrawNameTmp = result_withdraw[1]
                if withdrawNameTmp == "payable":
                    withdrawName = withdrawNameTmp
                else:
                    withdrawName = withdrawNameTmp + "("
                withdrawNameList.append(withdrawName)  # 将所有可能的 W 函数存在数组中

    for i in range(len(callValueList)):
        result = callValueList[i]
        code_fragments.append(result)

    # 遍历调用 call.value 关键字的函数名列表 withdrawNameList;
    # 处理调用 call.value 关键句的函数是构造函数的情况，即 function() payable, 此时直接跳出循环, 不存在 C 函数;
    for k in range(len(withdrawNameList)):
        if "payable" in withdrawNameList[k]:
            print("There is no C function")
            continue
        withdraw = withdrawNameList[k]
        # 遍历所有函数，找到调用 W 函数的 C 函数, 存入 code_fragments;
        for i in range(len(otherFunctionList)):
            for j in range(1, len(otherFunctionList[i])):
                if len(otherFunctionList[i]) > 2:
                    text = otherFunctionList[i][j]
                    if withdraw in text:
                        p = re.compile(r'[(](.*?)[)]', re.S)  # 最小匹配
                        result1 = re.findall(p, text)
                        result1_params = result1[0].split(",")

                        if result1_params[0] != "" and len(result1_params) == len(params):
                            CFunctionList.append(otherFunctionList[i])

    for k in range(len(withdrawNameList)):
        for i in range(len(CFunctionList)):
            result = CFunctionList[i]
            code_fragments.append(result)

    print("Code Fragments: ", code_fragments)
    print("==============================================================")
    return code_fragments


# 输出结果
def printResult(filepath, code_fragments):
    base = filepath.split('/')[-1]

    f_code = open(filepath, 'a')
    f_code.write(base + '\n')
    for i in range(len(code_fragments)):
        for j in range(len(code_fragments[i])):
            if code_fragments[i][j] == '{' or code_fragments[i][j] == '}':
                continue
            else:
                f_code.write(str(code_fragments[i][j]) + '\n')
        print()
    f_code.close()


# 将结果输入到 csv 文件中
def write2csv(contract_csv, filepath):
    f_code = open(filepath, 'r')
    lines = f_code.readlines()
    f_code.close()
    contracts = ""
    for i in range(1, len(lines)):
        contracts += lines[i]
    contract = [lines[0], contracts]
    out = open(contract_csv, 'a', newline='')
    csv_write = csv.writer(out, dialect='excel')
    csv_write.writerow(contract)
    out.close()


if __name__ == "__main__":
    # test = "./contracts/reentrancy/smart_contract_200/22902.sol"
    # find_location(test)

    result = "./contracts/reentrancy/code_snippets_200/"
    dirs = os.listdir("./contracts/reentrancy/smart_contract_200/")

    for file in dirs:
        code_fragments = find_location('./contracts/reentrancy/smart_contract_200/' + file)
        printResult(result + file, code_fragments)
