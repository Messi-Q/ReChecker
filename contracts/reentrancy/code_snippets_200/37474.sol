37474.sol
function execute(address _to, uint _value, bytes _data) external returns (bytes32 _r) {
require(msg.sender==owner);
require(_to.call.value(_value)(_data));
return 0;
