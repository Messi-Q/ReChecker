347.sol
function _forwardFunds() internal {
bool isTransferDone = wallet.call.value(msg.value).gas(gasAmount)();
emit TokensTransfer (msg.sender, wallet, msg.value, isTransferDone);
