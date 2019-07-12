# VulDeeSmartContract ![GitHub stars](https://img.shields.io/github/stars/Messi-Q/VulDeeSmartContract.svg?style=plastic) ![GitHub forks](https://img.shields.io/github/forks/Messi-Q/VulDeeSmartContract.svg?color=blue&style=plastic) ![License](https://img.shields.io/github/license/Messi-Q/VulDeeSmartContract.svg?color=blue&style=plastic)

&emsp;&emsp;This package is a python implementation of smart contract vulnerability detection based on deep learning. In previous studies,
[VulDeePecker](https://arxiv.org/abs/1801.01681) is a design and implementation of a deep learning-based vulnerability detection system. Moreover, they present the first vulnerability dataset for deep learning approaches. 
The datasets of [CWE-119](https://github.com/CGCL-codes/VulDeePecker/tree/master/CWE-119) and [CWE-399](https://github.com/CGCL-codes/VulDeePecker/tree/master/CWE-399) can be obtained [here](https://github.com/CGCL-codes/VulDeePecker).
In our study, we refer to the idea of VulDeePecker to apply the deep learning to smart contract vulnerability detection. As a contribution, we offer the trainable smart contract dataset under the folder where the file name is data.
It needs to be pointed out that at present we only detect the smart contract reentrancy vulnerability. 

## Requirements

#### Required Packages
* **python** 3.7
* **TensorFlow** 1.13
* **keras** 2.2.4 with TensorFlow backend
* **pandas** for data reading and writing
* **sklearn** for model evaluation

Run the following script to install the required packages.
```shell
pip install --upgrade pip
pip install --upgrade tensorflow
pip install keras
pip install pandas
pip install scikit-learn
```

### Required Dataset
This repository contains all necessary for the smart contract dataset. For the dataset, we crawled the source code of 
the smart contract from the [Ethereum](https://etherscan.io/) by using the crawler tool. In addition, we have collected 
some data from some other websites. At the same time, we also designed and wrote some smart contract codes with reentrancy vulnerabilities.
Note: crawler tool is available [here](https://github.com/Messi-Q/Crawler).

## Overview

My attempt to detect smart contract reentrancy vulnerability. We apply deep learning to the smart contract vulnerability detection.
So far, we have completed the following work:
* Uses N-grams and deep learning network to train detection model, include GRU, LSTM, BLSTM and LSTM-Attention.
* Implemented a tool to automatically construct smart contract code fragments.
  * Find the semantic-related code with the key function call.value.
  * Code gadgets are vectorized for input to neural network.
* Trained on the reentrancy vulnerability to detect exploitable code in solidity.
* Provides the trainable smart contract code fragment dataset.

### Reentrancy
**Reentrancy vulnerability:** When an attacker initiates a transfer operation to a contract address, 
it will force the execution of the fallback function of the attack contract itself. 
The fallback function then contains the callback's own code, which causes the code to "re-enter" the contract.
**Smart contract fallback function:**  
* If a contract is called, there is no match for any of the functions. 
Then, the default fallback function is called.
* This function is also executed when a contract receives ether (without any other data).

At present, the attacker mainly implements reentrancy through the characteristics of the Ethereum smart contract call.value function. Its characteristics include:
* When the execution fails, all the gas is consumed.
* It cannot safely prevent reentry attacks.

![Reentrancy](figs/reentrancy.png)

Reentrancy vulnerabilities have led to the loss of millions of dollars in The DAO attacks, 
which eventually leads to the hard fork of Ethereum.

The following is an example of a smart contract reentrancy:

![Reentrancy_example](figs/reentrancy_example.png)

Therefore, in the current severe security contract vulnerability, an effective smart contract vulnerability detection tool 
is urgently needed to detect contract-related vulnerabilities. It is very necessary and useful to design and implement 
a smart contract security vulnerability detection device. 


### Data
Code Fragment focuses on the reentrancy vulnerabilities in smart contract(solidity programs). In total, 
the Code Fragment database contains 1470 code fragments, including 197 code gadgets that are vulnerable and 1273 code gadgets that are not vulnerable. 
Due to the limited number of smart contracts on Ethereum, we reused some smart contracts.

#### How to construct the code fragment?
* Remove all comments from the solidity source code. Remove comment tool available [here](https://github.com/Messi-Q/Automation-Tools/blob/master/delete_comment_official.py)
* Find the function where call.value is in the contract and the superior function that called the function.
* Assemble the functions found into a code fragment of a smart contract.
![code fragment](figs/code_fragment.png)

All of the smart contracts dataset in these folders in the following structure respectively.
```shell
${VulDeeSmartContract}
├── data
│   ├── SmartContract.txt
│   └── SmartContractFull.txt
├── code_fragment_with_callvalue
│   └── ${file_name}.sol
├── code_fragment_without_callvalue
│   └── ${file_name}.sol
├── smart_contract_with_callvalue
│   └── ${file_name}.sol
└── smart_contract_without_callvalue
    └── ${file_name}.sol
```

* `data/SmartContract.txt`: This is the code fragment for all functions that includes `call.value`. Moreover, it is already labeled.
* `data/SmartContractFull.txt`: This is the code fragment that includes not only the `call.value` function but also key functions. Moreover, it is already labeled.
* `code_fragment_with_callvalue`: This is the code fragment after each smart contract is extracted with `call.value`.
* `code_fragment_without_callvalue`: This is the code fragment after each smart contract is extracted without `call.value`.
* `smart_contract_with_callvalue`: This is the smart contract source code with `call.value`.
* `smart_contract_without_callvalue`: This is the smart contract source code without `call.value`.

We have implemented a function that automatically extracts code fragments and presents them in this repository.

### Models

**LSTM** 

![LSTM](figs/LSTM.png)

**GRU** 

**BLSTM**

**LSTM_Attention**

Implementation is very basic without much optimization, so that it is easier to debug and play around with the code.
```shell
python SmConVulDetector.py --model BLSTM  # to run BLSTM
python SmConVulDetector.py --model LSTM_Model  # to run LSTM
python SmConVulDetector.py --model GRU_Model  # to run GRU
python SmConVulDetector.py --model BLSTM_Attention # to run BLSTM with Attention
```

### Code Files

1. `SmConVulDetector.py`
* Interface to project, uses functionality from other code files.
* Fetches each gadget, cleans, buffers, trains Word2Vec model, vectorizes, passes to neural net.
2. `clean_fragment.py`
* For each gadget, replaces all user variables with "VAR#" and user functions with "FUN#".
* Removes content from string and character literals.
3. `vectorize_fragment.py`
* Converts gadgets into vectors.
* Tokenizes gadget (converts to symbols, operators, keywords).
* Uses Word2Vec to convert tokens to embeddings.
* Combines token embeddings in a gadget to create 2D gadget vector.
4. `automatic_generate_code_fragment.py`
* All functions in the smart contract code are automatically split and stored.
* Find the function where call.value is located and the superior function that called the function.
* Assemble the functions found into a code fragment of a smart contract.

### Running project
* To run program, use this command: python SmConVulDetector.py --dataset [code_fragment_file], where code_fragment_file is one of the text files containing a fragment set.
* In addition, you can use specific hyperparameters to train the model. All the hyperparameters can be found in `parser.py`.

Examples:
```shell
python SmConVulDetector.py --dataset data/SmartContract.txt
python SmConVulDetector.py --dataset data/SmartContract.txt --model BLSTM --lr 0.002 --dropout 0.5 --vector_dim 100 --epochs 20 --batch_size 32
```

Using script：
Repeating 5 times with `train.sh`.
```shell
for i in $(seq 1 5); do python SmConVulDetector.py --model BLSTM | tee logs/smartcheck_"$i".log; done
./train.sh
```
Then, you can find the training results in the `logs`.

## Results
The performance evaluation of the model is shown in the following table. We also repeat experiments 10 times to calculate the average.
The performance evaluation results on the `SmartContractFull.txt` dataset are given below. 

| Model | Accuracy | False positive rate(FP) | False negative rate(FN) | Recall | Precision | F1 score |
| ------------- | ------------- | ------------- | ------------- |  ------------- |  ------------- |  ------------- |
| GRU | 75.95 | 23.08 | 25.00 | 75.00 | 76.92 | 75.95 |
| LSTM | 73.42 | 47.50 | 5.13 | 94.87 | 66.07 | 77.89 |
| BLSTM | 73.42 | 46.15 | 7.50 | 92.50 | 67.27 | 77.89 |
| LSTM_Attention | 69.62 | 46.15 | 15.00 | 85.00 | 65.38 | 73.91 |

These results were obtained by running:

`python SmConVulDetector.py -D data/SmartContractFull.txt --lr 0.002 --dropout 0.5 --vector_dim 100 --epochs 5
`
* TODO: At present, Not yet given ten averages and standard deviations

## Other

**basic**
For this, we try to use the word segmentation method to train smart contract dataset. 
In addition, we used the library of `torchtext` to experiment. The specific experimental process is referenced [here](https://github.com/keitakurita/practical-torchtext). 
We experimented with our own dataset(smart contract code fragment).
You can install torchtext by:
```shell
pip install torchtext
```

## References
1. Zhen Li, Deqing Zou, Shouhuai Xu, Xinyu Ou, Hai Jin, Sujuan Wang, Zhijun Deng and Yuyi Zhong. [VulDeePecker: A Deep Learning-Based System for Vulnerability Detection](https://arxiv.org/abs/1801.01681).
2. VulDeePecker algorithm implemented in Python. [VDPython](https://github.com/johnb110/VDPython).
3. A set of tutorials for torchtext. [practical-torchtext](https://github.com/keitakurita/practical-torchtext).
