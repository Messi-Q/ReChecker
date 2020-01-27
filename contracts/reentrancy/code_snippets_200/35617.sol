35617.sol
function buyRecipient(address recipient) duringCrowdSale payable {
require(!halted);
uint tokens = safeMul(msg.value, price(block.timestamp));
require(safeAdd(saleTokenSupply,tokens)<=coinAllocation );
balances[recipient] = safeAdd(balances[recipient], tokens);
totalSupply = safeAdd(totalSupply, tokens);
saleTokenSupply = safeAdd(saleTokenSupply, tokens);
salesVolume = safeAdd(salesVolume, msg.value);
if (!founder.call.value(msg.value)()) revert();
Buy(recipient, msg.value, tokens);
function buy() payable {
buyRecipient(msg.sender);
function() payable {
buyRecipient(msg.sender);
function buy() payable {
buyRecipient(msg.sender);
function() payable {
buyRecipient(msg.sender);
