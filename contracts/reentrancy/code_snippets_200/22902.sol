22902.sol
function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
if (isContract(_to)) {
require(allowedAddresses[_to]);
if (balanceOf(msg.sender) < _value) revert();
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
TransferContract(msg.sender, _to, _value, _data);
return true;
} else {
return transferToAddress(_to, _value, _data);
