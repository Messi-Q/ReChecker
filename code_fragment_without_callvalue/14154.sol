14154.sol
function reinvest() onlyStronghands() public
uint256 _dividends = myDividends(false);
address _customerAddress = msg.sender;
payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
_dividends += referralBalance_[_customerAddress];
referralBalance_[_customerAddress] = 0;
uint256 _tokens = purchaseTokens(_dividends, 0x0);
onReinvestment(_customerAddress, _dividends, _tokens);
function withdraw() onlyStronghands() public
address _customerAddress = msg.sender;
uint256 _dividends = myDividends(false);
payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
_dividends += referralBalance_[_customerAddress];
referralBalance_[_customerAddress] = 0;
_customerAddress.transfer(_dividends);
onWithdraw(_customerAddress, _dividends);
function sell(uint256 _amountOfTokens) onlyBagholders() public
address _customerAddress = msg.sender;
require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
uint256 _tokens = _amountOfTokens;
uint256 _ethereum = tokensToEthereum_(_tokens);
uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
payoutsTo_[_customerAddress] -= _updatedPayouts;
if (tokenSupply_ > 0) {
profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
onTokenSell(_customerAddress, _tokens, _taxedEthereum);