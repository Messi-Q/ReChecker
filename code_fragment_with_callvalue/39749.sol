39749.sol
function calcRefund(address _addressToRefund) internal {
uint amount = balanceOf[_addressToRefund];
balanceOf[_addressToRefund] = 0;
if (amount > 0) {
if (_addressToRefund.call.value(amount)()) {
LogFundTransfer(_addressToRefund, amount, false);
} else {
balanceOf[_addressToRefund] = amount;
function safeWithdraw() public onlyAfterDeadline  {
if (amountRaised >= fundingGoal){
fundingGoalReached = true;
LogGoalReached(bankRollBeneficiary, amountRaised);
crowdsaleClosed = true;
if (!fundingGoalReached) {
calcRefund(msg.sender);
if (msg.sender == owner && fundingGoalReached) {
bankrollBeneficiaryAmount = (this.balance*80)/100;
if (bankRollBeneficiary.send(bankrollBeneficiaryAmount)) {
LogFundTransfer(bankRollBeneficiary, bankrollBeneficiaryAmount, false);
etherollBeneficiaryAmount = this.balance;
if(!etherollBeneficiary.send(etherollBeneficiaryAmount)) throw;
LogFundTransfer(etherollBeneficiary, etherollBeneficiaryAmount, false);
} else {
fundingGoalReached = false;
function emergencyWithdraw() public isEmergency  {
calcRefund(msg.sender);
