1430.sol
function callContract(address to, bytes data) onlyOwner public payable returns (bool) {
require(to.call.value(msg.value)(data));
return true;
