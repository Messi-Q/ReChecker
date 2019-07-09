35661.sol
function refund() stopInEmergency {
if(getState() != State.Refunding) throw;
address investor = msg.sender;
if(balances[investor] == 0) throw;
uint amount = balances[investor];
delete balances[investor];
if(!(investor.call.value(amount)())) throw;
Refunded(investor, amount);
