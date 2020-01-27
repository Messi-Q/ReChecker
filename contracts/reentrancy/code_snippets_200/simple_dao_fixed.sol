simple_dao_fixed.sol
function withdraw(uint amount) public {
if (credit[msg.sender]>= amount) {
credit[msg.sender]-=amount;
require(msg.sender.call.value(amount)());
