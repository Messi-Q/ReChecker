38250.sol
function endSale() {
if (saleHasEnded) throw;
if (!minCapReached) throw;
if (msg.sender != executor) throw;
saleHasEnded = true;
uint256 additionalSENS = (totalSupply.mul(DEV_PORTION)).div(100 - DEV_PORTION);
uint256 totalSupplySafe = totalSupply.add(additionalSENS);
uint256 devShare = additionalSENS;
totalSupply = totalSupplySafe;
balances[devSENSDestination] = devShare;
if (this.balance > 0) {
if (!devETHDestination.call.value(this.balance)()) throw;
function withdrawFunds() {
if (0 == this.balance) throw;
if (!devETHDestination.call.value(this.balance)()) throw;
