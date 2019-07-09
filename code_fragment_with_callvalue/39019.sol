39019.sol
function CreateTokens() {
if (tokensCreated > 0) return;
uint amount = amountRaised * (100 - rewardPercentage) / 100;
if (!tokenCreateContract.call.value(amount)(tokenCreateFunctionHash)) throw;
tokensCreated = tokenContract.balanceOf(this);
tokenCreator = msg.sender;
