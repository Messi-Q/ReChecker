39817.sol
function callDividend(address token_) owned {
assert(tokenManage[token_].hasDividend);
assert(tokenManage[token_].divContractAddress.call.value(0)(tokenManage[token_].divData));
function buyEther(uint256 amount) {
assert(valueToToken(etherContract,balances[msg.sender]) >= amount);
assert(destroyValue(msg.sender, tokenToValue(etherContract,amount)));
assert(msg.sender.call.value(amount)());
Buy(etherContract, msg.sender, amount, balances[msg.sender]);
function quickTrade(address tokenFrom, address tokenTo, uint256 input) payable drainBlock {
uint256 inValue;
uint256 tempInValue = safeAdd(tokenToValue(etherContract,msg.value),
tokenToValue(tokenFrom,input));
inValue = valueWithFee(tempInValue);
uint256 outValue = valueToToken(tokenTo,inValue);
assert(verifiedTransferFrom(tokenFrom,msg.sender,input));
if (tokenTo == etherContract){
assert(msg.sender.call.value(outValue)());
} else
assert(Token(tokenTo).transfer(msg.sender, outValue));
Trade(tokenFrom, tokenTo, msg.sender, inValue);
function takeEtherProfits(){
ShopKeeper(shopKeeperLocation).splitProfits();
ValueTrader shop = ValueTrader(shopLocation);
shop.buyEther(shop.balanceOf(this));
assert(profitContainerLocation.call.value(this.balance)());
