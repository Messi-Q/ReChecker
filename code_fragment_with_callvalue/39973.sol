39973.sol
function _unsafeSend(address _to, uint _value) internal returns(bool) {
return _to.call.value(_value)();
function _forward(address _to, bytes _data) internal returns(bool, bool) {
uint startGas = msg.gas + forwardCallGas + (_data.length * 50);
if (_to == 0x0) {
return (false, _safeFalse());
if (!_to.call.value(msg.value)(_data)) {
return (false, _safeFalse());
return (true, _applyRefund(startGas));
function checkForward(bytes _data) constant returns(bool, bool) {
return _forward(allowedForwards[sha3(_data[0], _data[1], _data[2], _data[3])], _data);
function checkForward(bytes _data) constant returns(bool, bool) {
return _forward(allowedForwards[sha3(_data[0], _data[1], _data[2], _data[3])], _data);
