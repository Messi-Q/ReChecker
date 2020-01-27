35806.sol
function withdraw(uint amount) {
require(tokens[0][msg.sender] >= amount);
tokens[0][msg.sender] = safeSub(tokens[0][msg.sender], amount);
require(msg.sender.call.value(amount)());
Withdraw(0, msg.sender, amount, tokens[0][msg.sender]);
