39705_1.sol
function empty() returns (bool) {
return foundationWallet.call.value(this.balance)();
function donateAs(address addr) private returns (bool) {
state st = getState();
if (st != state.round0 && st != state.round1) { throw; }
if (msg.value < minDonation) { throw; }
if (weiPerCHF == 0) { throw; }
totalWeiDonated += msg.value;
weiDonated[addr] += msg.value;
uint chfCents = (msg.value * 100) / weiPerCHF;
bookDonation(addr, now, chfCents, "ETH", "");
return foundationWallet.call.value(this.balance)();
