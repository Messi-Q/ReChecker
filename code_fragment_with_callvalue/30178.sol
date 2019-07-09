30178.sol
function buy() payable notPaused() public returns(bool) {
require(now >= salesStart);
require(now < salesDeadline);
uint tokensToBuy = msg.value * MULTIPLIER / TOKEN_PRICE;
require(tokensToBuy > 0);
uint timeBonus = _calculateTimeBonus(tokensToBuy, now);
uint volumeBonus = _calculateVolumeBonus(tokensToBuy, msg.sender, msg.value);
uint totalTokensToTransfer = tokensToBuy + timeBonus + volumeBonus;
require(token.transfer(msg.sender, totalTokensToTransfer));
LogBought(msg.sender, msg.value, totalTokensToTransfer, 0);
require(wallet.call.value(msg.value)());
return true;
