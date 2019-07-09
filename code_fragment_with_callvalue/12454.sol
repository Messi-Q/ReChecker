12454.sol
function submitPool(uint256 weiAmount) public onlyAdmin noReentrancy {
require(contractStage < CONTRACT_SUBMIT_FUNDS, "Cannot resubmit pool.");
require(receiverAddress != 0x00, "receiver address cannot be empty");
uint256 contractBalance = address(this).balance;
if(weiAmount == 0){
weiAmount = contractBalance;
require(minContribution <= weiAmount && weiAmount <= contractBalance, "submitted amount too small or larger than the balance");
finalBalance = contractBalance;
require(receiverAddress.call.value(weiAmount).gas(gasleft().sub(5000))(),"Error submitting pool to receivingAddress");
contractBalance = address(this).balance;
if(contractBalance > 0) {
ethRefundAmount.push(contractBalance);
contractStage = CONTRACT_SUBMIT_FUNDS;
emit PoolSubmitted(receiverAddress, weiAmount);
