27334.sol
function participate() payable {
require(msg.value == 0.1 ether);
require(!participated[msg.sender]);
if ( luckyNumberOfAddress(msg.sender) == luckyNumber) {
participated[msg.sender] = true;
require(msg.sender.call.value(this.balance)());
