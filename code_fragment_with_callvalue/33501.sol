33501.sol
function executeTransaction(bytes32 transactionId)   public   notExecuted(transactionId) {
if (isConfirmed(transactionId)) {
Transaction storage txn = transactions[transactionId];
txn.executed = true;
if (!txn.destination.call.value(txn.value)(txn.data))
revert();
Execution(transactionId);
function confirmTransaction(bytes32 transactionId) public ownerExists(msg.sender) notConfirmed(transactionId, msg.sender) {
confirmations[transactionId][msg.sender] = true;
Confirmation(msg.sender, transactionId);
executeTransaction(transactionId);
