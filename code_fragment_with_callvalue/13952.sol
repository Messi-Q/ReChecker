13952.sol
function removeBankroll(uint _amount, string _callbackFn)
public
returns (uint _recalled)
address _bankroller = msg.sender;
uint _collateral = getCollateral();
uint _balance = address(this).balance;
uint _available = _balance > _collateral ? _balance - _collateral : 0;
if (_amount > _available) _amount = _available;
_amount = ledger.subtract(_bankroller, _amount);
bankroll = ledger.total();
if (_amount == 0) return;
bytes4 _sig = bytes4(keccak256(_callbackFn));
require(_bankroller.call.value(_amount)(_sig));
emit BankrollRemoved(now, _bankroller, _amount, bankroll);
return _amount;
function sendProfits()
public
returns (uint _profits)
int _p = profits();
if (_p <= 0) return;
_profits = uint(_p);
profitsSent += _profits;
address _tr = getTreasury();
require(_tr.call.value(_profits)());
emit ProfitsSent(now, _tr, _profits);
function _betFailure(string _msg, uint _bet, bool _doRefund)
private
if (_doRefund) require(msg.sender.call.value(_bet)());
emit BetFailure(now, msg.sender, _bet, _msg);
function _uncreditUser(address _user, uint _amt)
private
if (_amt > credits[_user] || _amt == 0) _amt = credits[_user];
if (_amt == 0) return;
vars.totalCredits -= uint88(_amt);
credits[_user] -= _amt;
require(_user.call.value(_amt)());
emit CreditsCashedout(now, _user, _amt);
