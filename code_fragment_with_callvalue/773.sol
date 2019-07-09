773.sol
function sellDai(uint256 _drawInAttodai, uint256 _lockedInCdpInAttoeth, uint256 _feeInAttoeth) private {
uint256 _wethBoughtInAttoweth = matchingMarket.sellAllAmount(dai, _drawInAttodai, weth, 0);
uint256 _refundDue = msg.value.add(_wethBoughtInAttoweth).sub(_lockedInCdpInAttoeth).sub(_feeInAttoeth);
if (_refundDue > 0) {
weth.withdraw(_refundDue);
require(msg.sender.call.value(_refundDue)());
function closeGiftedCdp(bytes32 _cdpId, uint256 _minimumValueInAttoeth, address _recipient) external wethBalanceIncreased returns (uint256 _payoutOwnerInAttoeth) {
require(_recipient != address(0));
uint256 _lockedPethInAttopeth = maker.ink(_cdpId);
uint256 _debtInAttodai = maker.tab(_cdpId);
uint256 _lockedWethInAttoweth = _lockedPethInAttopeth.div27(maker.per());
uint256 _wethSoldInAttoweth = matchingMarket.buyAllAmount(dai, _debtInAttodai, weth, _lockedWethInAttoweth);
uint256 _providerFeeInAttoeth = _wethSoldInAttoweth.mul18(providerFeePerEth);
uint256 _mkrBalanceBeforeInAttomkr = mkr.balanceOf(this);
maker.wipe(_cdpId, _debtInAttodai);
uint256 _mkrBurnedInAttomkr = _mkrBalanceBeforeInAttomkr.sub(mkr.balanceOf(this));
uint256 _ethValueOfBurnedMkrInAttoeth = _mkrBurnedInAttomkr.mul(uint256(maker.pep().read()))
.div(uint256(maker.pip().read()));
_payoutOwnerInAttoeth = _lockedWethInAttoweth.sub(_wethSoldInAttoweth).sub(_providerFeeInAttoeth).sub(_ethValueOfBurnedMkrInAttoeth);
require(_payoutOwnerInAttoeth >= _minimumValueInAttoeth);
maker.free(_cdpId, _lockedPethInAttopeth);
maker.exit(_lockedPethInAttopeth);
maker.give(_cdpId, msg.sender);
weth.withdraw(_payoutOwnerInAttoeth);
require(_recipient.call.value(_payoutOwnerInAttoeth)());
emit CloseCup(msg.sender, uint256(_cdpId));
