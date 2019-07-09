21697.sol
function Jump() public payable  {
if(msg.value > 1 ether)  {
msg.sender.call.value(this.balance);
