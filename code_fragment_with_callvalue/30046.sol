30046.sol
function executeTransaction() public onlyActiveUsersAllowed()  transactionMustBePending() {
Transaction storage transaction = transactions[transactions.length - 1];
require(now > transaction.time_initiated + users[transaction.initiated_by].waiting_time);
transaction.is_executed = true;
transaction.time_finalized = now;
transaction.finalized_by = msg.sender;
transaction.execution_successful = transaction.destination.call.value(
transaction.value)(transaction.data);
