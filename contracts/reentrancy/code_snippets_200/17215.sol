17215.sol
function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public isRunning returns (bool ok) {
require(compatible223ex);
require(isUnlockedBoth(_to));
require(balances[msg.sender] >= _value);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
if (isContract(_to)) {
assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
Transfer(msg.sender, _to, _value, _data);
Transfer(msg.sender, _to, _value);
return true;
