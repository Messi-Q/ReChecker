35649.sol
function playerWithdrawPendingTransactions() public  payoutsAreActive   returns (bool)  {
uint withdrawAmount = playerPendingWithdrawals[msg.sender];
playerPendingWithdrawals[msg.sender] = 0;
if (msg.sender.call.value(withdrawAmount)()) {
return true;
} else {
playerPendingWithdrawals[msg.sender] = withdrawAmount;
return false;
