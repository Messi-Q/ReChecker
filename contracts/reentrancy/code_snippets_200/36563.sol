36563.sol
function forward(address _destination, uint256 _value, bytes _data) onlyOwner {
require(_destination != address(0));
assert(_destination.call.value(_value)(_data));
if (_value > 0) {
Withdrawal(_destination, _value, _data);
function() payable {
Deposit(msg.sender, msg.value);
