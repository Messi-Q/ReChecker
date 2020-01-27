40353.sol
function withdraw(uint256 tokens) noEther onlyDaoChallenge {
if (tokens == 0 || tokenBalance == 0 || tokenBalance < tokens) throw;
tokenBalance -= tokens;
if(!owner.call.value(tokens * tokenPrice)()) throw;
function withdraw(uint256 tokens) noEther {
DaoAccount account = accountFor(msg.sender, false);
if (account == DaoAccount(0x00)) throw;
account.withdraw(tokens);
notifyWithdraw(msg.sender, tokens);
