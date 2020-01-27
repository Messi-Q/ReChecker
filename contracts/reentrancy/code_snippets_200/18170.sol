18170.sol
function mintETHRewards( address _contract, uint256 _amount ) public onlyManager() {
require(_amount <= wingsETHRewards);
require(_contract.call.value(_amount)());
wingsETHRewards -= _amount;
