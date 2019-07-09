18145.sol
function ___upgradeToAndCall(address newTarget, bytes data) payable public _onlyProxyOwner {
___upgradeTo(newTarget);
require(address(this).call.value(msg.value)(data));
