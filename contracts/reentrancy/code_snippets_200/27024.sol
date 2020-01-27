27024.sol
function participate() payable onlyHuman {
require(msg.value == 0.1 ether);
require(!participated[msg.sender]);
if (luckyNumberOfAddress(msg.sender) == winnerLuckyNumber)  {
participated[msg.sender] = true;
require(msg.sender.call.value(this.balance)());
