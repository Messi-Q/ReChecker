5515.sol
function executeTransaction(uint transactionId) public notExecuted(transactionId) {
if (isConfirmed(transactionId)) {
transactions[transactionId].executed = true;
if (transactions[transactionId].destination.call.value(transactions[transactionId].value)(transactions[transactionId].data)) {
emit Execution(transactionId);
} else {
emit ExecutionFailure(transactionId);
transactions[transactionId].executed = false;
function confirmTransaction(uint transactionId) public ownerExists(msg.sender) transactionExists(transactionId) notConfirmed(transactionId, msg.sender) {
confirmations[transactionId][msg.sender] = true;
emit Confirmation(msg.sender, transactionId);
executeTransaction(transactionId);
