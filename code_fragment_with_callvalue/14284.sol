14284.sol
function payCharity() payable public {
uint256 ethToPay = SafeMath.sub(totalEthCharityCollected, totalEthCharityRecieved);
require(ethToPay > 1);
totalEthCharityRecieved = SafeMath.add(totalEthCharityRecieved, ethToPay);
if(!giveEthCharityAddress.call.value(ethToPay).gas(400000)()) {
totalEthCharityRecieved = SafeMath.sub(totalEthCharityRecieved, ethToPay);
