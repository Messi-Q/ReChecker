simple_dao.sol
function withdraw(uint amount) public{
if (credit[msg.sender]>= amount) {
require(msg.sender.call.value(amount)());
credit[msg.sender]-=amount;
