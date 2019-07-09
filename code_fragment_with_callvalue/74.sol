74.sol
function upgradeToAndCall(uint256 version, address implementation, bytes data) payable public onlyProxyOwner {
upgradeTo(version, implementation);
require(address(this).call.value(msg.value)(data));
contract EternalStorageProxy is OwnedUpgradeabilityProxy, EternalStorage {}
