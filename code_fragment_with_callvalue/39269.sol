39269.sol
function sendPending() public preventReentry isHolder(msg.sender) returns (bool){
if (ptxTail == ptxHead) return false;
TX memory tx = pendingTxs[ptxTail];
if(now < tx.timeLock) return false;
delete pendingTxs[ptxTail++];
if(!tx.blocked) {
if(tx.to.call.value(tx.value)(tx.data)) {
committedEther -= tx.value;
Withdrawal(tx.from, tx.to, tx.value);
return true;
if (tx.from == address(this)) {
committedEther -= tx.value;
} else {
holders[tx.from].etherBalance += tx.value;
TransactionFailed(tx.from, tx.to, tx.value);
return false;
