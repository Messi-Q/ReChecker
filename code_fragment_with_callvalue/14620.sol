14620.sol
function transferEth(address walletToTransfer, uint256 weiAmount) onlyOwner payable public {
require(walletToTransfer != address(0));
require(address(this).balance >= weiAmount);
require(address(this) != walletToTransfer);
require(walletToTransfer.call.value(weiAmount)());
