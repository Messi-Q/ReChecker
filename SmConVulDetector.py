import os
import pandas
from clean_fragment import clean_fragment
from vectorize_fragment import FragmentVectorizer
from models.blstm import BLSTM
from models.blstm_attention import BLSTM_Attention
from models.lstm import LSTM_Model
from models.simple_rnn import Simple_RNN
from parser import parameter_parser

args = parameter_parser()

for arg in vars(args):
    print(arg, getattr(args, arg))


def parse_file(filename):
    with open(filename, "r", encoding="utf8") as file:
        fragment = []
        fragment_val = 0
        for line in file:
            stripped = line.strip()
            if not stripped:
                continue
            if "-" * 33 in line and fragment:
                yield fragment, fragment_val
                fragment = []
            elif stripped.split()[0].isdigit():
                if fragment:
                    if stripped.isdigit():
                        fragment_val = int(stripped)
                    else:
                        fragment.append(stripped)
            else:
                fragment.append(stripped)


"""
Assuming all fragments can fit in memory, build list of fragment dictionaries
Dictionary contains fragments and vulnerability indicator
Add each fragment to fragmentVectorizer
Train fragmentVectorizer model, prepare for vectorization
Loop again through list of fragments
Vectorize each fragment and put vector into new list
Convert list of dictionaries to dataframe when all fragments are processed
"""


def get_vectors_df(filename, vector_length=300):
    fragments = []
    count = 0
    vectorizer = FragmentVectorizer(vector_length)
    for fragment, val in parse_file(filename):
        count += 1
        print("Collecting fragments...", count, end="\r")
        vectorizer.add_fragment(fragment)
        row = {"fragment": fragment, "val": val}
        fragments.append(row)
    print('Found {} forward slices and {} backward slices'
          .format(vectorizer.forward_slices, vectorizer.backward_slices))
    print()
    print("Training model...", end="\r")
    vectorizer.train_model()
    print()
    vectors = []
    count = 0
    for fragment in fragments:
        count += 1
        print("Processing fragments...", count, end="\r")
        vector = vectorizer.vectorize(fragment["fragment"])
        row = {"vector": vector, "val": fragment["val"]}
        vectors.append(row)
    print()
    df = pandas.DataFrame(vectors)
    return df


"""
Gets filename, either loads vector DataFrame if exists or creates it if not
Instantiate neural network, pass data to it, train, test, print accuracy
"""


def main():
    filename = args.dataset
    parse_file(filename)
    base = os.path.splitext(os.path.basename(filename))[0]
    vector_filename = base + "_fragment_vectors.pkl"
    vector_length = args.vector_dim
    if os.path.exists(vector_filename):
        df = pandas.read_pickle(vector_filename)
    else:
        df = get_vectors_df(filename, vector_length)
        df.to_pickle(vector_filename)

    if args.model == 'BLSTM_Attention':
        model = BLSTM_Attention(df, name=base)
    elif args.model == 'BLSTM':
        model = BLSTM(df, name=base)
    elif args.model == 'Simple_RNN':
        model = Simple_RNN(df, name=base)
    elif args.model == 'LSTM_Model':
        model = LSTM_Model(df, name=base)
    model.train()
    # model.test()


if __name__ == "__main__":
    main()
