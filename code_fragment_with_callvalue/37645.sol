37645.sol
function endSale() {
if (saleHasEnded) throw;
if (!minCapReached) throw;
if (msg.sender != executor) throw;
uint256 additionalSFT = (totalSupply.mul(DEV_PORTION)).div(100 - DEV_PORTION);
uint256 totalSupplySafe = totalSupply.add(additionalSFT);
uint256 devShare = additionalSFT;
totalSupply = totalSupplySafe;
balances[devSFTDestination] = devShare;
saleHasEnded = true;
if (this.balance > 0) {
if (!devETHDestination.call.value(this.balance)()) throw;
function withdrawFunds() {
if (0 == this.balance) throw;
if (!minCapReached) throw;
if (!devETHDestination.call.value(this.balance)()) throw;
