16925.sol
function withdraw() public{
assert(msg.sender.call.value(balances[msg.sender])()) ;
balances[msg.sender] = 0;
