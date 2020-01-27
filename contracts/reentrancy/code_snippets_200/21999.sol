21999.sol
function call(address addr, bytes data, uint256 amount) public payable onlyOwner {
if (msg.value > 0)
deposit();
require(addr.call.value(amount)(data));
Call(msg.sender, addr, amount);
