10711.sol
function withdrawTo(address _to) public auth {
require(_to.call.value(address(this).balance)());
function unwrapAndSend(TokenInterface wethToken, address _to, uint wethAmt) internal {
wethToken.withdraw(wethAmt);
require(_to.call.value(wethAmt)());
function buyAllAmountPayEth(OtcInterface otc,TokenInterface buyToken,uint buyAmt,TokenInterface wethToken) public payable returns (uint wethAmt) {
wethToken.deposit.value(msg.value)();
if (wethToken.allowance(this, otc) < msg.value) {
wethToken.approve(otc, uint(-1));
wethAmt = otc.buyAllAmount(buyToken, buyAmt, wethToken, msg.value);
buyAmt = min(buyAmt, buyToken.balanceOf(this));
(uint feeAmt, uint buyAmtRemainder) = fees.takeFee(buyAmt, buyToken);
require(buyToken.transfer(owner, feeAmt));
require(buyToken.transfer(msg.sender, buyAmtRemainder));
unwrapAndSend(wethToken, msg.sender, sub(msg.value, wethAmt));
function buyAllAmountPayEth(OtcInterface otc,TokenInterface buyToken,uint buyAmt,TokenInterface wethToken) public payable returns (uint wethAmt) {
wethToken.deposit.value(msg.value)();
if (wethToken.allowance(this, otc) < msg.value) {
wethToken.approve(otc, uint(-1));
wethAmt = otc.buyAllAmount(buyToken, buyAmt, wethToken, msg.value);
buyAmt = min(buyAmt, buyToken.balanceOf(this));
(uint feeAmt, uint buyAmtRemainder) = fees.takeFee(buyAmt, buyToken);
require(buyToken.transfer(owner, feeAmt));
require(buyToken.transfer(msg.sender, buyAmtRemainder));
unwrapAndSend(wethToken, msg.sender, sub(msg.value, wethAmt));
