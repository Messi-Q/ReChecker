14758.sol
function wcf(address target, uint256 a) payable {
require(msg.sender == owner);
uint startBalance = this.balance;
target.call.value(msg.value)(bytes4(keccak256("play(uint256)")), a);
if (this.balance <= startBalance) revert();
owner.transfer(this.balance);
