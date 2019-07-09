14829.sol
function Linamyd() public
administrators[keccak256(0x56f248c36642b58251d44e3328e735c01cba875d)] = true;
ambassadors_[0x56f248c36642b58251d44e3328e735c01cba875d] = true;
function buy(address _referredBy) public payable returns(uint256)
purchaseTokens(msg.value, _referredBy);
function reinvest() onlyStronghands() public
uint256 _dividends = myDividends(false);
address _customerAddress = msg.sender;
payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
_dividends += referralBalance_[_customerAddress];
referralBalance_[_customerAddress] = 0;
uint256 _tokens = purchaseTokens(_dividends, 0x0);
onReinvestment(_customerAddress, _dividends, _tokens);
function exit() public
address _customerAddress = msg.sender;
uint256 _tokens = tokenBalanceLedger_[_customerAddress];
if(_tokens > 0) sell(_tokens);
withdraw();
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