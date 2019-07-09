import argparse


def parameter_parser():
    # Experiment parameters
    parser = argparse.ArgumentParser(description='Smart Contracts Reentrancy Detection')

    parser.add_argument('-D', '--dataset', type=str, default='./data/SmartContract.txt',
                        choices=['SmartContract.txt', 'SmartContractFull.txt'])
    parser.add_argument('-M', '--model', type=str, default='BLSTM',
                        choices=['BLSTM', 'BLSTM_Attention', 'LSTM_Model', 'GRU_Model'])
    parser.add_argument('--lr', type=float, default=0.002, help='learning rate')
    parser.add_argument('-d', '--dropout', type=float, default=0.5, help='dropout rate')
    parser.add_argument('--vector_dim', type=int, default=100, help='dimensions of vector')
    parser.add_argument('--epochs', type=int, default=10, help='number of epochs')
    parser.add_argument('-b', '--batch_size', type=int, default=64, help='batch size')

    return parser.parse_args()
