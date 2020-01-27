4591.sol
function finishDistribution() onlyOwner canDistr public returns (bool) {
crowdsaleClosed = true;
uint256 amount = tokenReward.sub(amountRaisedIsc);
balances[beneficiary] = balances[beneficiary].add(amount);
emit Transfer(address(0), beneficiary, amount);
require(msg.sender.call.value(amountRaised)());
return true;
