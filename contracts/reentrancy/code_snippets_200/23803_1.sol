23803_1.sol
function () payable {
if (!founder.call.value(msg.value)()) revert();
