7530.sol
function execute(address _to, uint _value, bytes _data) external onlyOwner {
SingleTransact(msg.sender, _value, _to, _data);
_to.call.value(_value)(_data);
