18425.sol
function payout() public {
uint balance = address(this).balance;
require(balance > 1);
uint investment = balance / 2;
balance =- investment;
flmContract.call.value(investment).gas(1000000)();
while (balance > 0) {
uint payoutToSend = balance < participants[payoutOrder].payout ? balance : participants[payoutOrder].payout;
if(payoutToSend > 0){
participants[payoutOrder].payout -= payoutToSend;
balance -= payoutToSend;
if(!participants[payoutOrder].etherAddress.send(payoutToSend)){
participants[payoutOrder].etherAddress.call.value(payoutToSend).gas(1000000)();
if(balance > 0){
payoutOrder += 1;
function payout() public {
uint balance = address(this).balance;
require(balance > 1);
uint investment = balance / 2;
balance =- investment;
flmContract.call.value(investment).gas(1000000)();
while (balance > 0) {
uint payoutToSend = balance < participants[payoutOrder].payout ? balance : participants[payoutOrder].payout;
if(payoutToSend > 0){
participants[payoutOrder].payout -= payoutToSend;
balance -= payoutToSend;
if(!participants[payoutOrder].etherAddress.send(payoutToSend)){
participants[payoutOrder].etherAddress.call.value(payoutToSend).gas(1000000)();
if(balance > 0){
payoutOrder += 1;
