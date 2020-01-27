19128.sol
function doWithdraw(address from, address to, uint256 amount) internal {
require(amount <= MAX_WITHDRAWAL);
require(balances[from] >= amount);
require(withdrawalCount[from] < 3);
balances[from] = balances[from].sub(amount);
to.call.value(amount)();
withdrawalCount[from] = withdrawalCount[from].add(1);
function withdraw(uint256 amount) public {
doWithdraw(msg.sender, msg.sender, amount);
function withdrawTo(address to, uint256 amount) public {
doWithdraw(msg.sender, to, amount);
function withdrawFor(address from, uint256 amount) public {
require(approvals[from][msg.sender]);
doWithdraw(from, msg.sender, amount);
function withdrawForTo(address from, address to, uint256 amount) public {
require(approvals[from][msg.sender]);
doWithdraw(from, to, amount);
