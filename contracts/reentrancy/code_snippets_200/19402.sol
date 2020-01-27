19402.sol
function buyToken(address recipient, uint256 value) internal {
if (block.number<startBlock || block.number>endBlock) throw;
uint tokens = safeMul(value, price());
if(safeAdd(crowdSaleSoldAmount, tokens)>crowdSaleCap) throw;
balances[recipient] = safeAdd(balances[recipient], tokens);
crowdSaleSoldAmount = safeAdd(crowdSaleSoldAmount, tokens);
totalSupply = safeAdd(totalSupply, tokens);
Transfer(address(0), recipient, tokens);
if (!founder.call.value(value)()) throw;
Buy(recipient, value, tokens);
function price() constant returns(uint) {
if (block.number<startBlock || block.number > endBlock) return 0;
else  return crowdSalePrice;
function() public payable {
if(msg.value == 0) {
sendCandy(msg.sender);
}  else {
buyToken(msg.sender, msg.value);
