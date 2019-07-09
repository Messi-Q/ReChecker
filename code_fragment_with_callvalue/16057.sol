16057.sol
function callFirstTarget () public payable onlyPlayers {
require (msg.value >= 0.005 ether);
firstTarget.call.value(msg.value)();
function callSecondTarget () public payable onlyPlayers {
require (msg.value >= 0.005 ether);
secondTarget.call.value(msg.value)();
function winPrize() public payable onlyOwner {
owner.call.value(1 wei)();
