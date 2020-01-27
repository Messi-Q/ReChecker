32559_1.sol
function transfer(address _to, uint256 _value, bytes _data, string _custom_fallback) onlyPayloadSize(4 * 32) public returns (bool success) {
if(isContract(_to)) {
require(Balances(balancesContract()).get(msg.sender) >= _value);
Balances(balancesContract()).transfer(msg.sender, _to, _value);
ContractReceiver receiver = ContractReceiver(_to);
require(receiver.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
Transfer(msg.sender, _to, _value);
Transfer(msg.sender, _to, _value, _data);
return true;
} else {
return transferToAddress(_to, _value, _data);
