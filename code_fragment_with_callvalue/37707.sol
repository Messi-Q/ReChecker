37707.sol
function claimBounty() preventTheft {
uint balance = bountyAmount[msg.sender];
if (msg.sender.call.value(balance)()) {
totalBountyAmount -= balance;
bountyAmount[msg.sender] = 0;
