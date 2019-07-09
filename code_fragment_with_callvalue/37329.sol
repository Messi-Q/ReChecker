37329.sol
function buyICO() onlyExecutorOrOwner {
if (getBlockNumber() < icoStartBlock) return;
if (this.balance == 0) return;
uint256 purchaseAmount = Math.min256(this.balance, purchaseCap);
assert(crowdSale.call.value(purchaseAmount)());
ICOPurchased(purchaseAmount);
