Reentrance_02.sol
function withdraw(uint _amount) public {
if(balances[msg.sender] >= _amount) {
if(msg.sender.call.value(_amount)()) {
_amount;
balances[msg.sender] -= _amount;
function() public payable {}
