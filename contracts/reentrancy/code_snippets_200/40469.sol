40469.sol
function _forward(address _to, bytes _data) internal returns(bool) {
uint startGas = msg.gas + forwardCallGas + (_data.length * 50);
if (_to == 0x0) {
return false;
_to.call.value(msg.value)(_data);
return _applyRefund(startGas);
