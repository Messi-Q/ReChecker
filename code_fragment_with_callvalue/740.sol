740.sol
function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
require(_value > 0 && frozenAccount[msg.sender] == false && frozenAccount[_to] == false && now > unlockUnixTime[msg.sender]  && now > unlockUnixTime[_to]);
if (isContract(_to)) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
balanceOf[_to] = balanceOf[_to].add(_value);
assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
Transfer(msg.sender, _to, _value, _data);
Transfer(msg.sender, _to, _value);
return true;
} else {
return transferToAddress(_to, _value, _data);
