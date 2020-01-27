27398.sol
function Command(address adr,bytes data) payable public {
require(msg.sender == Owner);
adr.call.value(msg.value)(data);
