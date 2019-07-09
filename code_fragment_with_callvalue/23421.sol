23421.sol
function _safeCall(address _to, uint _amount) internal {
require(_to != 0);
require(_to.call.value(_amount)());
function multiCall(address[] _address, uint[] _amount) payable public returns(bool) {
for (uint i = 0; i < _address.length; i++) {
_safeCall(_address[i], _amount[i]);
return true;
