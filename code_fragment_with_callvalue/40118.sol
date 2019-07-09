40118.sol
function withdrawEtherOrThrow(uint256 amount) private {
if (msg.sender != owner) throw;
bool result = owner.call.value(amount)();
if (!result) { throw;}
function refund() noEther onlyOwner {
if (tokenBalance == 0) throw;
tokenBalance = 0;
withdrawEtherOrThrow(tokenBalance * tokenPrice);
