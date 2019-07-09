40589.sol
function sendRobust(address to, uint value) internal {
if (!to.send(value)) {
if (!to.call.value(value)()) throw;
function _fillOrder(address _from, uint numTokens) internal returns (bool) {
if (numTokens == 0) throw;
if (this.balance < numTokens * weiPerToken / decimalPlaces) throw;
if (!token.transferFrom(_from, owner, numTokens)) return false;
sendRobust(_from, numTokens * weiPerToken / decimalPlaces);
OrderFilled(_from, numTokens);
return true;
