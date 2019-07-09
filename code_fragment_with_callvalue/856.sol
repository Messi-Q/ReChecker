856.sol
function executeTransaction(uint transactionId) public ownerExists(msg.sender) confirmed(transactionId, msg.sender) notExecuted(transactionId) {
if (isConfirmed(transactionId)) {
Transaction storage txn = transactions[transactionId];
txn.executed = true;
if (txn.destination.call.value(txn.value)(txn.data))
emit Execution(transactionId);
else {
emit ExecutionFailure(transactionId);
txn.executed = false;
function confirmTransaction(uint transactionId) public ownerExists(msg.sender) transactionExists(transactionId) notConfirmed(transactionId, msg.sender) {
confirmations[transactionId][msg.sender] = true;
emit Confirmation(msg.sender, transactionId);
executeTransaction(transactionId);
