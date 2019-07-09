10107.sol
function transfer(address to, uint value, bytes data, string customFallback) public returns (bool) {
if(balanceOf(msg.sender) < value) revert();
balances[msg.sender] = balances[msg.sender].sub(value);
balances[to] = balances[to].add(value);
if (isContract(to)) {
assert(to.call.value(0)(bytes4(keccak256(customFallback)), msg.sender, value, data));
emit Transfer(msg.sender, to, value, data);
return true;
