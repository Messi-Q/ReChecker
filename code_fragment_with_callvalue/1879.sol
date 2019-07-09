1879.sol
function upgradeToAndCall(address newImplementation, bytes data) payable external ifAdmin {
_upgradeTo(newImplementation);
require(address(this).call.value(msg.value)(data));
