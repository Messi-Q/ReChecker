11705.sol
function commonWithdraw(address token, uint value) internal {
require (tokens[token][msg.sender] >= value);
tokens[token][msg.sender] -= value;
totalDeposited[token] -= value;
require((token != 0)?
ERC20(token).transfer(msg.sender, value):
msg.sender.call.value(value)()
);
emit Withdraw(
token,
msg.sender,
value,
tokens[token][msg.sender]);
function withdraw(uint amount) public {
commonWithdraw(0, amount);
function withdrawToken(address token, uint amount) public {
commonWithdraw(token, amount);
