919.sol
function upgradeToAndCall(string version, address implementation, bytes data) payable public onlyProxyOwner {
upgradeTo(version, implementation);
require(this.call.value(msg.value)(data));
contract EternalStorageProxyForStormMultisender is OwnedUpgradeabilityProxy, EternalStorage {
