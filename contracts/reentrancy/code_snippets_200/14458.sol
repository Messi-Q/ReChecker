14458.sol
function transfer(address _to, uint256 _value, bytes _data, string _custom_fallback) public whenNotPaused notSelf(_to) returns (bool success){
require(_to != address(0));
if(isContract(_to)) {
if(accountBalances[msg.sender].addressBalance < _value){
revert();
if(safeAdd(accountBalances[_to].addressBalance, _value) < accountBalances[_to].addressBalance){
revert();
isNewRound();
subFromAddressBalancesInfo(msg.sender, _value);
addToAddressBalancesInfo(_to, _value);
assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
Transfer(msg.sender, _to, _value, _data);
Transfer(msg.sender, _to, _value);
return true;
} else {
return transferToAddress(msg.sender, _to, _value, _data);
