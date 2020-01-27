cross-function-reentrancy.sol
function WithdrawReward(address recipient) public {
uint amountToWithdraw = rewardsForA[recipient];
rewardsForA[recipient] = 0;
require(recipient.call.value(amountToWithdraw)());
function GetFirstWithdrawalBonus(address recipient) public {
if (claimedBonus[recipient] == false) {
throw;
rewardsForA[recipient] += 100;
untrustedWithdrawReward(recipient);
claimedBonus[recipient] = true;
