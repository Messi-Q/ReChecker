import re
import warnings
import numpy as np
from gensim.models import Word2Vec

warnings.filterwarnings("ignore")

# Sets for operators
operators3 = {'<<=', '>>='}
operators2 = {
    '->', '++', '--',
    '!~', '<<', '>>', '<=', '>=',
    '==', '!=', '&&', '||', '+=',
    '-=', '*=', '/=', '%=', '&=', '^=', '|='
}
operators1 = {
    '(', ')', '[', ']', '.',
    '+', '-', '*', '&', '/',
    '%', '<', '>', '^', '|',
    '=', ',', '?', ':', ';',
    '{', '}'
}

"""
Functionality to train Word2Vec model and vectorize fragments
Trains Word2Vec model using list of tokenized fragments
Uses trained model embeddings to create 2D fragment vectors
"""


class FragmentVectorizer:
    def __init__(self, vector_length):
        self.fragments = []
        self.vector_length = vector_length
        self.forward_slices = 0
        self.backward_slices = 0

    """
    Takes a line of solidity code (string) as input
    Tokenizes solidity code (breaks down into identifier, variables, keywords, operators)
    Returns a list of tokens, preserving order in which they appear
    """

    @staticmethod
    def tokenize(line):
        tmp, w = [], []
        i = 0
        while i < len(line):
            # Ignore spaces and combine previously collected chars to form words
            if line[i] == ' ':
                tmp.append(''.join(w))
                tmp.append(line[i])
                w = []
                i += 1
            # Check operators and append to final list
            elif line[i:i + 3] in operators3:
                tmp.append(''.join(w))
                tmp.append(line[i:i + 3])
                w = []
                i += 3
            elif line[i:i + 2] in operators2:
                tmp.append(''.join(w))
                tmp.append(line[i:i + 2])
                w = []
                i += 2
            elif line[i] in operators1:
                tmp.append(''.join(w))
                tmp.append(line[i])
                w = []
                i += 1
            # Character appended to word list
            else:
                w.append(line[i])
                i += 1
        # Filter out irrelevant strings
        res = list(filter(lambda c: c != '', tmp))
        return list(filter(lambda c: c != ' ', res))

    """
    Tokenize entire fragment
    Tokenize each line and concatenate to one long list
    """

    @staticmethod
    def tokenize_fragment(fragment):
        tokenized = []
        function_regex = re.compile('function(\d)+')
        backwards_slice = False
        for line in fragment:
            tokens = FragmentVectorizer.tokenize(line)
            tokenized += tokens
            if len(list(filter(function_regex.match, tokens))) > 0:
                backwards_slice = True
            else:
                backwards_slice = False
        return tokenized, backwards_slice

    """
    Add input fragment to model
    Tokenize fragment and buffer it to list
    """

    def add_fragment(self, fragment):
        tokenized_fragment, backwards_slice = FragmentVectorizer.tokenize_fragment(fragment)
        self.fragments.append(tokenized_fragment)
        if backwards_slice:
            self.backward_slices += 1
        else:
            self.forward_slices += 1

    """
    Uses Word2Vec to create a vector for each fragment
    Gets a vector for the fragment by combining token embeddings
    Number of tokens used is min of number_of_tokens and 100
    """

    def vectorize(self, fragment):
        tokenized_fragment, backwards_slice = FragmentVectorizer.tokenize_fragment(fragment)
        vectors = np.zeros(shape=(100, self.vector_length))
        if backwards_slice:
            for i in range(min(len(tokenized_fragment), 100)):
                vectors[100 - 1 - i] = self.embeddings[tokenized_fragment[len(tokenized_fragment) - 1 - i]]
        else:
            for i in range(min(len(tokenized_fragment), 100)):
                vectors[i] = self.embeddings[tokenized_fragment[i]]
        return vectors

    """
    Done adding fragments, then train Word2Vec model
    Only keep list of embeddings, delete model and list of fragments
    """

    def train_model(self):
        # Set min_count to 1 to prevent out-of-vocabulary errors
        model = Word2Vec(self.fragments, min_count=1, size=self.vector_length, sg=0)  # sg=0: CBOW; sg=1: Skip-Gram
        self.embeddings = model.wv
        del model
        del self.fragments
