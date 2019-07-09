14945.sol
function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool) {
require(_spender != address(this));
super.approve(_spender, _value);
require(_spender.call.value(msg.value)(_data));
return true;
