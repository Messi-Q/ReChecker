33450.sol
function executeTransaction(bytes32 TransHash) public notExecuted(TransHash){
if (isConfirmed(TransHash)) {
Transactions[TransHash].executed = true;
require(Transactions[TransHash].destination.call.value(Transactions[TransHash].value)(Transactions[TransHash].data));
Execution(TransHash);
function confirmTransaction(bytes32 TransHash) public onlyOwner(){
addConfirmation(TransHash);
executeTransaction(TransHash);
