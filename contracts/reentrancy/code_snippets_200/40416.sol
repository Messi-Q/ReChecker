40416.sol
function withdraw(uint amount) {
if (msg.value>0) throw;
if (tokens[0][msg.sender] < amount) throw;
tokens[0][msg.sender] -= amount;
if (!msg.sender.call.value(amount)()) throw;
Withdraw(0, msg.sender, amount, tokens[0][msg.sender]);
