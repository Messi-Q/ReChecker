27188.sol
function loggedTransfer(uint amount, bytes32 message, address target, address currentOwner) protected {
if(!target.call.value(amount)()) throw;
Transfer(amount, message, target, currentOwner);
function divest(uint amount) public {
if ( investors[msg.sender].investment == 0 || amount == 0) throw;
investors[msg.sender].investment -= amount;
sumInvested -= amount;
this.loggedTransfer(amount, "", msg.sender, owner);
function payDividend() public {
uint dividend = calculateDividend();
if (dividend == 0) throw;
investors[msg.sender].lastDividend = sumDividend;
this.loggedTransfer(dividend, "Dividend payment", msg.sender, owner);
function doTransfer(address target, uint amount) public onlyOwner {
this.loggedTransfer(amount, "Owner transfer", target, owner);
