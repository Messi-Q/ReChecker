12114.sol
function withdrawAndSend(TokenInterface wethToken, uint wethAmt) internal {
wethToken.withdraw(wethAmt);
require(msg.sender.call.value(wethAmt)());
function sellAllAmountBuyEth(OtcInterface otc, TokenInterface payToken, uint payAmt, TokenInterface wethToken, uint minBuyAmt) public returns (uint) {
require(payToken.transferFrom(msg.sender, this, payAmt));
if (payToken.allowance(this, otc) < payAmt) {
payToken.approve(otc, uint(-1));
uint wethAmt = otc.sellAllAmount(payToken, payAmt, wethToken, minBuyAmt);
(uint feeAmt, uint wethAmtRemainder) = takeFee(wethAmt);
require(wethToken.transfer(owner, feeAmt));
withdrawAndSend(wethToken, wethAmtRemainder);
return wethAmtRemainder;
function buyAllAmountBuyEth(OtcInterface otc, TokenInterface wethToken, uint wethAmt, TokenInterface payToken, uint maxPayAmt) public returns (uint payAmt) {
uint payAmtNow = otc.getPayAmount(payToken, wethToken, wethAmt);
require(payAmtNow <= maxPayAmt);
require(payToken.transferFrom(msg.sender, this, payAmtNow));
if (payToken.allowance(this, otc) < payAmtNow) {
payToken.approve(otc, uint(-1));
payAmt = otc.buyAllAmount(wethToken, wethAmt, payToken, payAmtNow);
(uint feeAmt, uint wethAmtRemainder) = takeFee(wethAmt);
require(wethToken.transfer(owner, feeAmt));
withdrawAndSend(wethToken, wethAmtRemainder);
function() public payable {}
