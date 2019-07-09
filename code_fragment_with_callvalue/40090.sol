40090.sol
function multiAccessCallD(address _to, uint _value, bytes _data, address _sender) external onlyDelegate(_sender) onlymanyowners(_sender, sha3(msg.sig, _to, _value, _data)) returns(bool) {
return _to.call.value(_value)(_data);
function() returns(bool) {
return multiAccessCall(multiAccessRecipient, msg.value, msg.data);
function multiAccessCall(address _to, uint _value, bytes _data) returns(bool) {
return this.multiAccessCallD(_to, _value, _data, msg.sender);
