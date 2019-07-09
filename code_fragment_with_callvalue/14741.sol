14741.sol
function transferToContractWithCustomFallback(address _to, uint _value, bytes _data, string _custom_fallback) private returns(bool success) {
require(balanceOf(msg.sender) > _value);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
emit Transfer(msg.sender, _to, _value, _data);
return true;
function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns(bool success) {
require(!frozenAccount[msg.sender]);
require(!frozenAccount[_to]);
if (isContract(_to)) {
return transferToContractWithCustomFallback(_to, _value, _data, _custom_fallback);
} else {
return transferToAddress(_to, _value, _data);
