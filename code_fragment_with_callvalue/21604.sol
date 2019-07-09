21604.sol
function buyToken() public payable {
address currentOwner;
uint256 currentPrice;
uint256 paidTooMuch;
uint256 payment;
if (tokenPrice < tokenPrice2) {
currentOwner = tokenOwner;
currentPrice = tokenPrice;
require(tokenOwner2 != msg.sender);
} else {
currentOwner = tokenOwner2;
currentPrice = tokenPrice2;
require(tokenOwner != msg.sender);
require(msg.value >= currentPrice);
paidTooMuch = msg.value.sub(currentPrice);
payment = currentPrice.div(2);
if (tokenPrice < tokenPrice2) {
tokenPrice = currentPrice.mul(110).div(50);
tokenOwner = msg.sender;
} else {
tokenPrice2 = currentPrice.mul(110).div(50);
tokenOwner2 = msg.sender;
lastBuyBlock = block.number;
flips++;
Transfer(currentOwner, msg.sender, currentPrice);
if (currentOwner != address(0)) {
payoutRound = getRoundId()-3;
currentOwner.call.value(payment).gas(24000)();
if (paidTooMuch > 0)
msg.sender.transfer(paidTooMuch);
function finishRound() public {
require(tokenPrice > tokenStartPrice);
require(lastBuyBlock + newRoundDelay < block.number);
lastBuyBlock = block.number;
address owner = tokenOwner;
uint price = tokenPrice;
if (tokenPrice2>tokenPrice) {
owner = tokenOwner2;
price = tokenPrice2;
uint lastPaidPrice = price.mul(50).div(110);
uint win = this.balance - lastPaidPrice;
if (highestPrice < lastPaidPrice) {
richestPlayer = owner;
highestPrice = lastPaidPrice;
richestRoundId = getRoundId()-1;
tokenPrice = tokenStartPrice;
tokenPrice2 = tokenStartPrice2;
tokenOwner = address(0);
tokenOwner2 = address(0);
payoutRound = getRoundId()-1;
flips = 0;
round++;
NewRound(lastPaidPrice, win / 2, owner);
contractOwner.transfer((this.balance - (lastPaidPrice + win / 2) - win / 10) * 19 / 20);
owner.call.value(lastPaidPrice + win / 2).gas(24000)();
if (richestPlayer!=address(0)) {
payoutRound = richestRoundId;
RichestBonus(win / 10, richestPlayer);
richestPlayer.call.value(win / 10).gas(24000)();
function finishRound() public {
require(tokenPrice > tokenStartPrice);
require(lastBuyBlock + newRoundDelay < block.number);
lastBuyBlock = block.number;
address owner = tokenOwner;
uint price = tokenPrice;
if (tokenPrice2>tokenPrice) {
owner = tokenOwner2;
price = tokenPrice2;
uint lastPaidPrice = price.mul(50).div(110);
uint win = this.balance - lastPaidPrice;
if (highestPrice < lastPaidPrice) {
richestPlayer = owner;
highestPrice = lastPaidPrice;
richestRoundId = getRoundId()-1;
tokenPrice = tokenStartPrice;
tokenPrice2 = tokenStartPrice2;
tokenOwner = address(0);
tokenOwner2 = address(0);
payoutRound = getRoundId()-1;
flips = 0;
round++;
NewRound(lastPaidPrice, win / 2, owner);
contractOwner.transfer((this.balance - (lastPaidPrice + win / 2) - win / 10) * 19 / 20);
owner.call.value(lastPaidPrice + win / 2).gas(24000)();
if (richestPlayer!=address(0)) {
payoutRound = richestRoundId;
RichestBonus(win / 10, richestPlayer);
richestPlayer.call.value(win / 10).gas(24000)();
