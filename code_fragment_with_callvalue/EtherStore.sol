EtherStore.sol
function withdrawFunds (uint256 _weiToWithdraw) public {
require(balances[msg.sender] >= _weiToWithdraw);
require(_weiToWithdraw <= withdrawalLimit);
require(now >= lastWithdrawTime[msg.sender] + 1 weeks);
require(msg.sender.call.value(_weiToWithdraw)());
balances[msg.sender] -= _weiToWithdraw;
lastWithdrawTime[msg.sender] = now;
