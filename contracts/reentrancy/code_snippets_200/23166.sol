23166.sol
function buy(address recipient) payable public duringCrowdSale  {
require(!halted);
require(msg.value >= 0.01 ether);
uint256 tokens = msg.value.mul(35e4);
require(tokens > 0);
require(saleTokenSupply.add(tokens)<=coinAllocation );
balances[recipient] = balances[recipient].add(tokens);
totalSupply_ = totalSupply_.add(tokens);
saleTokenSupply = saleTokenSupply.add(tokens);
salesVolume = salesVolume.add(msg.value);
if (!founder.call.value(msg.value)()) revert();
Buy(msg.sender, recipient, msg.value, tokens);
function TorusCoin(uint256 startDatetimeInSeconds, address founderWallet) public {
admin = msg.sender;
founder = founderWallet;
startDatetime = startDatetimeInSeconds;
endDatetime = startDatetime + 16 * 1 days;
function() public payable {
buy(msg.sender);
