40340.sol
function withdrawFunds(uint amount) {
if (accountIDs[msg.sender]>0) {
if (int(amount)<=getFunds(msg.sender, true) && int(amount)>0) {
accounts[accountIDs[msg.sender]].capital -= int(amount);
msg.sender.call.value(amount)();
Withdraw(msg.sender, amount, accounts[accountIDs[msg.sender]].capital);
function expire(uint accountID, uint8 v, bytes32 r, bytes32 s, bytes32 value) {
if (expired == false) {
if (ecrecover(sha3(factHash, value), v, r, s) == ethAddr) {
uint lastAccount = numAccounts;
if (accountID==0) {
accountID = 1;
} else {
lastAccount = accountID;
for (accountID=accountID; accountID<=lastAccount; accountID++) {
if (positions[accounts[accountID].user].expired == false) {
int result = positions[accounts[accountID].user].cash / 1000000000000000000;
for (uint optionID=0; optionID<numOptions; optionID++) {
int moneyness = getMoneyness(options[optionID], uint(value), margin);
result += moneyness * positions[accounts[accountID].user].positions[optionID] / 1000000000000000000;
positions[accounts[accountID].user].expired = true;
uint amountToSend = uint(accounts[accountID].capital + result);
accounts[accountID].capital = 0;
if (positions[accounts[accountID].user].hasPosition==true) {
numPositionsExpired++;
accounts[accountID].user.call.value(amountToSend)();
Expire(msg.sender, accounts[accountID].user);
if (numPositionsExpired == numPositions) {
expired = true;
