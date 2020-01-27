39664_1.sol
function migrateBlockjack() only(ADMIN_CONTRACT) {
stopBlockjack();
if (currentBankroll > initialBankroll) {
if (!ADMIN_CONTRACT.call.value(currentBankroll - initialBankroll)()) throw;
suicide(DX);
function shareProfits() onlyOwner {
if (profitsLockedUntil > now) throw;
if (currentBankroll <= initialBankroll) throw;
uint256 profit = currentBankroll - initialBankroll;
if (!ADMIN_CONTRACT.call.value(profit)()) throw;
currentBankroll -= profit;
bankrollLockedUntil = now + BANKROLL_LOCK_PERIOD;
profitsLockedUntil = bankrollLockedUntil + BANKROLL_LOCK_PERIOD;
