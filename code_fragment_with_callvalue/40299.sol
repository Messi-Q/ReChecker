40299.sol
function redeem(uint tokens) {
if (!feeAccount.call.value(safeMul(tokens,fee)/(1 ether))()) throw;
if (!resolved) {
yesToken.destroy(msg.sender, tokens);
noToken.destroy(msg.sender, tokens);
if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
Redeem(msg.sender, tokens, tokens, tokens);
} else if (resolved) {
if (outcome==0) {
noToken.destroy(msg.sender, tokens);
if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
Redeem(msg.sender, tokens, 0, tokens);
} else if (outcome==1) {
yesToken.destroy(msg.sender, tokens);
if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
Redeem(msg.sender, tokens, tokens, 0);
function redeem(uint tokens) {
if (!feeAccount.call.value(safeMul(tokens,fee)/(1 ether))()) throw;
if (!resolved) {
yesToken.destroy(msg.sender, tokens);
noToken.destroy(msg.sender, tokens);
if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
Redeem(msg.sender, tokens, tokens, tokens);
} else if (resolved) {
if (outcome==0) {
noToken.destroy(msg.sender, tokens);
if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
Redeem(msg.sender, tokens, 0, tokens);
} else if (outcome==1) {
yesToken.destroy(msg.sender, tokens);
if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
Redeem(msg.sender, tokens, tokens, 0);
function redeem(uint tokens) {
if (!feeAccount.call.value(safeMul(tokens,fee)/(1 ether))()) throw;
if (!resolved) {
yesToken.destroy(msg.sender, tokens);
noToken.destroy(msg.sender, tokens);
if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
Redeem(msg.sender, tokens, tokens, tokens);
} else if (resolved) {
if (outcome==0) {
noToken.destroy(msg.sender, tokens);
if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
Redeem(msg.sender, tokens, 0, tokens);
} else if (outcome==1) {
yesToken.destroy(msg.sender, tokens);
if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
Redeem(msg.sender, tokens, tokens, 0);
function redeem(uint tokens) {
if (!feeAccount.call.value(safeMul(tokens,fee)/(1 ether))()) throw;
if (!resolved) {
yesToken.destroy(msg.sender, tokens);
noToken.destroy(msg.sender, tokens);
if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
Redeem(msg.sender, tokens, tokens, tokens);
} else if (resolved) {
if (outcome==0) {
noToken.destroy(msg.sender, tokens);
if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
Redeem(msg.sender, tokens, 0, tokens);
} else if (outcome==1) {
yesToken.destroy(msg.sender, tokens);
if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
Redeem(msg.sender, tokens, tokens, 0);
