import pandas as pd
import numpy as np

VAL_RATIO = 0.2
TEST_RATIO = 0.2


def prepare_csv(seed=999):
    # 加载训练数据
    df_train = pd.read_csv("./code_fragment_csv/contract_csv.csv")
    df_train["sequence_text"] = df_train.sequence_text.str.replace("\n", " ")
    idx = np.arange(df_train.shape[0])
    # 将训练数据分成训练集和验证集
    np.random.seed(seed)
    np.random.shuffle(idx)
    val_size = int(len(idx) * VAL_RATIO)
    test_size = int(len(idx) * TEST_RATIO)
    df_train.iloc[idx[val_size + test_size:], :].to_csv("./contract_csv/contract_train.csv",
                                                        index=False)
    df_train.iloc[idx[:val_size], :].to_csv("./contract_csv/contract_valid.csv", index=False)
    df_train.iloc[idx[val_size:val_size + test_size], :].to_csv(
        "./contract_csv/contract_test.csv", index=False)


if __name__ == "__main__":
    prepare_csv()
