40366.sol
function execute(address _to, uint _value, bytes _data) {
if (!isRightBranch) throw;
if (msg.sender != owner) throw;
if (!_to.call.value (_value)(_data)) throw;
contract BranchSender {
bool public isRightBranch;
