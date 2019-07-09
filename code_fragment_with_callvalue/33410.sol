33410.sol
function executeTransaction(uint transactionId)  internal notExecuted(transactionId) {
if (isConfirmed(transactionId)) {
Transaction tx = transactions[transactionId];
tx.executed = true;
if (tx.destination.call.value(tx.value)(tx.data))
Execution(transactionId);
else {
ExecutionFailure(transactionId);
tx.executed = false;
function confirmTransaction(uint transactionId)  public ownerExists(msg.sender) transactionExists(transactionId)  notConfirmed(transactionId, msg.sender){
confirmations[transactionId][msg.sender] = true;
Confirmation(msg.sender, transactionId);
executeTransaction(transactionId);
