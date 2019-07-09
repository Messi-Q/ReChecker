cross-function-reentrancy.sol
function untrustedWithdrawReward(address recipient) public {
uint amountToWithdraw = rewardsForA[recipient];
rewardsForA[recipient] = 0;
if (recipient.call.value(amountToWithdraw)() == false) {  throw;}
function untrustedGetFirstWithdrawalBonus(address recipient) public {
if (claimedBonus[recipient] == false) {  throw;}
rewardsForA[recipient] += 100;
untrustedWithdrawReward(recipient);
claimedBonus[recipient] = true;
