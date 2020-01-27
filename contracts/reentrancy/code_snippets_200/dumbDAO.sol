dumbDAO.sol
function withdraw(address _recipient) returns (bool) {
if (balances[msg.sender] == 0){
InsufficientFunds(balances[msg.sender],balances[msg.sender]);
throw;
PaymentCalled(_recipient, balances[msg.sender]);
if (_recipient.call.value(balances[msg.sender])()) {
balances[msg.sender] = 0;
return true;
