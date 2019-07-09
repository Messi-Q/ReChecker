21886.sol
function buy(address recipient, uint256 value) public payable {
if (value> msg.value) throw;
if (value < msg.value) {
require(msg.sender.call.value(msg.value - value)());
buyToken(recipient, value);
function buyToken(address recipient, uint256 value) internal {
if (block.number<startBlock || block.number>endBlock || safeAdd(totalEtherRaised,value)>etherCap || halted) throw;
if (block.number>=startBlock && block.number<=startBlock+prePeriod && safeAdd(totalEtherRaised,value) > preEtherCap) throw;
uint tokens = safeMul(value, price());
balances[recipient] = safeAdd(balances[recipient], tokens);
totalSupply = safeAdd(totalSupply, tokens);
totalEtherRaised = safeAdd(totalEtherRaised, value);
if (block.number<=startBlock+prePeriod) {
presaleTokenSupply = safeAdd(presaleTokenSupply, tokens);
Transfer(address(0), recipient, tokens);
if (!founder.call.value(value)()) throw;
Buy(recipient, value, tokens);
