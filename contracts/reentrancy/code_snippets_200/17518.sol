17518.sol
function sendTransaction(address to, uint256 value, bytes data) public onlyOwner returns (bool) {
return to.call.value(value)(data);
