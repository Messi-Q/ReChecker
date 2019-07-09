14995.sol
function fund() public payable {
if (dateSaleStarted==0 || now < dateSaleStarted)
return _errorBuyingTokens("CrowdSale has not yet started.");
if (now > dateSaleEnded)
return _errorBuyingTokens("CrowdSale has ended.");
if (totalRaised >= hardCap)
return _errorBuyingTokens("HardCap has been reached.");
if (msg.value % 1000000000 != 0)
return _errorBuyingTokens("Must send an even amount of GWei.");
if (!wasSaleStarted) {
wasSaleStarted = true;
emit SaleStarted(now);
uint _amtToFund = (totalRaised + msg.value) > hardCap ? hardCap - totalRaised : msg.value;
uint _numTokens = getTokensFromEth(_amtToFund);
token.mint(msg.sender, _numTokens);
totalRaised += _amtToFund;
emit BuyTokensSuccess(now, msg.sender, _amtToFund, _numTokens);
if (totalRaised < softCap) {
amtFunded[msg.sender] += _amtToFund;
uint _refund = msg.value > _amtToFund ? msg.value - _amtToFund : 0;
if (_refund > 0){
require(msg.sender.call.value(_refund)());
emit UserRefunded(now, msg.sender, _refund);
function endSale() public {
require(wasSaleStarted && !wasSaleEnded);
require(totalRaised >= hardCap || now > dateSaleEnded);
wasSaleEnded = true;
wasSoftCapMet = totalRaised >= softCap;
if (!wasSoftCapMet) {
token.mint(wallet, 1e30);
emit SaleFailed(now);
return;
token.freeze(false);
uint _lockerAmt = token.totalSupply() / 4;
token.mint(locker, _lockerAmt);
locker.startVesting(_lockerAmt, 600);
uint _capitalAmt = (totalRaised * capitalPctBips) / 10000;
if (address(this).balance < _capitalAmt) _capitalAmt = address(this).balance;
treasury.addCapital.value(_capitalAmt)();
if (wallet.call.value(address(this).balance)()) {}
emit SaleSuccessful(now);
function refund() public {
require(wasSaleEnded && !wasSoftCapMet);
require(amtFunded[msg.sender] > 0);
uint _amt = amtFunded[msg.sender];
amtFunded[msg.sender] = 0;
require(msg.sender.call.value(_amt)());
emit UserRefunded(now, msg.sender, _amt);
function fundCapital() public payable {
if (!wasSaleEnded)
return _errorBuyingTokens("Sale has not ended.");
if (!wasSoftCapMet)
return _errorBuyingTokens("SoftCap was not met.");
uint _amtNeeded = capitalFundable();
uint _amount = msg.value > _amtNeeded ? _amtNeeded : msg.value;
if (_amount == 0) {
return _errorBuyingTokens("No capital is needed.");
totalRaised += _amount;
token.mint(msg.sender, _amount);
treasury.addCapital.value(_amount)();
emit BuyTokensSuccess(now, msg.sender, _amount, _amount);
uint _refund = msg.value > _amount ? msg.value - _amount : 0;
if (_refund > 0) {
require(msg.sender.call.value(_refund)());
emit UserRefunded(now, msg.sender, _refund);
function _errorBuyingTokens(string _reason) private {
require(msg.sender.call.value(msg.value)());
emit BuyTokensFailure(now, msg.sender, _reason);
function collectOwedDividends() public returns (uint _amount) {
_updateCreditedPoints(msg.sender);
_amount = creditedPoints[msg.sender] / POINTS_PER_WEI;
creditedPoints[msg.sender] = 0;
dividendsCollected += _amount;
emit CollectedDividends(now, msg.sender, _amount);
require(msg.sender.call.value(_amount)());
function collect() public {
require(msg.sender == owner);
token.collectOwedDividends();
uint _amount = address(this).balance;
if (_amount > 0) require(owner.call.value(_amount)());
emit Collected(now, owner, _amount);
