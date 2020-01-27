14579.sol
function pay() public onlyOwner whenNotCanceled {
require(weiCollected > 0);
uint256 fee;
uint256 netAmount;
(fee, netAmount) = _getFeeAndNetAmount(weiCollected);
require(address(sale).call.value(netAmount)(this));
tokensReceived = getToken().balanceOf(this);
if (fee != 0) {
manager.transfer(fee);
paid = true;
emit Paid(netAmount, fee);
