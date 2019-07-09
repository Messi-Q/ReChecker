31565.sol
function reject(address _participant) onlyOwner public {
uint256 weiAmount = deposited[_participant];
require(weiAmount > 0);
deposited[_participant] = 0;
Rejected(_participant);
require(_participant.call.value(weiAmount)());
function rejectMany(address[] _participants) onlyOwner public {
for (uint256 i = 0; i < _participants.length; i++) {
reject(_participants[i]);
