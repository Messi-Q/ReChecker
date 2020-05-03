import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import auc  # compute roc and auc
from scipy.interpolate import spline

# Compute ROC curve and ROC area for each class

# ------------------------------rnn------------------------------#
fpr_rnn, tpr_rnn = [], []
fpr_txt_rnn = "fpr_rnn.txt"
fpr_txt_read_rnn = open(fpr_txt_rnn, "r")
fpr_lines_rnn = fpr_txt_read_rnn.readlines()

for line in fpr_lines_rnn:
    fpr_rnn.append(float(line.strip()))

fpr_rnn = np.array(fpr_rnn)

tpr_txt_rnn = "tpr_rnn.txt"
tpr_txt_read_rnn = open(tpr_txt_rnn, "r")
tpr_lines_rnn = tpr_txt_read_rnn.readlines()

for line in tpr_lines_rnn:
    tpr_rnn.append(float(line.strip()))

tpr_rnn = np.array(tpr_rnn)

roc_auc_rnn = auc(fpr_rnn, tpr_rnn)
print(roc_auc_rnn)

# ------------------------------lstm------------------------------#

fpr_lstm, tpr_lstm = [], []
fpr_txt_lstm = "fpr_lstm.txt"
fpr_txt_read_lstm = open(fpr_txt_lstm, "r")
fpr_lines_lstm = fpr_txt_read_lstm.readlines()

for line in fpr_lines_lstm:
    fpr_lstm.append(float(line.strip()))

fpr_lstm = np.array(fpr_lstm)
tpr_txt_lstm = "tpr_lstm.txt"
tpr_txt_read_lstm = open(tpr_txt_lstm, "r")
tpr_lines_lstm = tpr_txt_read_lstm.readlines()

for line in tpr_lines_lstm:
    tpr_lstm.append(float(line.strip()))

tpr_lstm = np.array(tpr_lstm)
roc_auc_lstm = auc(fpr_lstm, tpr_lstm)
print(roc_auc_lstm)

# ------------------------------blstm------------------------------#
fpr_blstm, tpr_blstm = [], []
fpr_txt_blstm = "fpr_blstm.txt"
fpr_txt_read_blstm = open(fpr_txt_blstm, "r")
fpr_lines_blstm = fpr_txt_read_blstm.readlines()

for line in fpr_lines_blstm:
    fpr_blstm.append(float(line.strip()))

fpr_blstm = np.array(fpr_blstm)
tpr_txt_blstm = "tpr_blstm.txt"
tpr_txt_read_blstm = open(tpr_txt_blstm, "r")
tpr_lines_blstm = tpr_txt_read_blstm.readlines()

for line in tpr_lines_blstm:
    tpr_blstm.append(float(line.strip()))

tpr_blstm = np.array(tpr_blstm)
roc_auc_blstm = auc(fpr_blstm, tpr_blstm)
print(roc_auc_blstm)

# ------------------------------blstm_att------------------------------#

fpr_blstm_att, tpr_blstm_att = [], []
fpr_txt_blstm_att = "fpr_blstm_att.txt"
fpr_txt_read_blstm_att = open(fpr_txt_blstm_att, "r")
fpr_lines_blstm_att = fpr_txt_read_blstm_att.readlines()

for line in fpr_lines_blstm_att:
    fpr_blstm_att.append(float(line.strip()))

fpr_blstm_att = np.array(fpr_blstm_att)
tpr_txt_blstm_att = "tpr_blstm_att.txt"
tpr_txt_read_blstm_att = open(tpr_txt_blstm_att, "r")
tpr_lines_blstm_att = tpr_txt_read_blstm_att.readlines()

for line in tpr_lines_blstm_att:
    tpr_blstm_att.append(float(line.strip()))

tpr_blstm_att = np.array(tpr_blstm_att)
roc_auc_blstm_att = auc(fpr_blstm_att, tpr_blstm_att)
print(roc_auc_blstm_att)

plt.figure()
lw = 2
plt.rcParams['figure.figsize'] = (5, 3.5)

plt.plot(fpr_rnn, tpr_rnn, color='darkorange',
         lw=lw, label='ROC curve of RNN (AUC = %0.4f)' % roc_auc_rnn, linestyle='-', marker='.',
         markevery=0.05, mew=1.5)

plt.plot(fpr_lstm, tpr_lstm, color='brown',
         lw=lw, label='ROC curve of LSTM (AUC = %0.4f)' % roc_auc_lstm, linestyle='-', marker='.',
         markevery=0.05, mew=1.5)

plt.plot(fpr_blstm, tpr_blstm, color='slateblue',
         lw=lw, label='ROC curve of BLSTM (AUC = %0.4f)' % roc_auc_blstm, linestyle='-', marker='.',
         markevery=0.05, mew=1.5)

plt.plot(fpr_blstm_att, tpr_blstm_att, color='steelblue',
         lw=lw, label='ROC curve of BLSTM-ATT (AUC = %0.4f)' % roc_auc_blstm_att, linestyle='-', marker='.',
         markevery=0.05, mew=1.5)

plt.plot([0, 1], [0, 1], color='gray', lw=1, linestyle='--')
plt.xlim(-0.01, 1.01)
plt.ylim(-0.01, 1.01)
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
# plt.title('Roc curve comparision between corenodes and fullnodes')
plt.legend(loc="lower right")
plt.savefig("Roc.pdf")
plt.show()
