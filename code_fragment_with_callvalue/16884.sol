16884.sol
function mintETHRewards(address _contract,  uint256 _amount) public onlyManager() {
require(_contract.call.value(_amount)());
