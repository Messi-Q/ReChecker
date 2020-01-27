39191.sol
function withdraw(Bank storage self, address accountAddress, uint value) public returns (bool) {
if (self.accountBalances[accountAddress] >= value) {
deductFunds(self, accountAddress, value);
if (!accountAddress.send(value)) {
if (!accountAddress.call.value(value)()) {  throw; }
return true;
return false;
uint constant DEFAULT_SEND_GAS = 100000;
