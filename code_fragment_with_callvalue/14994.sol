14994.sol
function collectOwedDividends() public returns (uint _amount) {
_updateCreditedPoints(msg.sender);
_amount = creditedPoints[msg.sender] / POINTS_PER_WEI;
creditedPoints[msg.sender] = 0;
dividendsCollected += _amount;
emit CollectedDividends(now, msg.sender, _amount);
require(msg.sender.call.value(_amount)());
