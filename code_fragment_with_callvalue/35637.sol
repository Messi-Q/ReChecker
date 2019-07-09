35637.sol
function transfer(address _to, uint48 _value, bytes _data, string _custom_fallback) returns (bool success) {
if(isContract(_to)) {
require(balanceOf(msg.sender) >= _value);
balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
balances[_to] = safeAdd(balanceOf(_to), _value);
ContractReceiver receiver = ContractReceiver(_to);
receiver.call.value(0)(bytes4(sha3(_custom_fallback)), msg.sender, _value, _data);
Transfer(msg.sender, _to, _value, _data);
return true;
} else {
return transferToAddress(_to, _value, _data);
