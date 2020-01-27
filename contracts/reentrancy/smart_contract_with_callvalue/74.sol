pragma solidity 0.4.19;


contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}

 
contract Proxy {

   
    function implementation() public view returns (address);

   
    function () payable public {
        address _impl = implementation();
        require(_impl != address(0));
        assembly {
             
            let ptr := mload(0x40)
             
            calldatacopy(ptr, 0, calldatasize)
             
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
             
             
            mstore(0x40, add(ptr, returndatasize))
             
            returndatacopy(ptr, 0, returndatasize)

             
            switch result
            case 0 { revert(ptr, returndatasize) }
            default { return(ptr, returndatasize) }
        }
    }
}


contract UpgradeabilityStorage {
     
    uint256 internal _version;

     
    address internal _implementation;

     
    function version() public view returns (uint256) {
        return _version;
    }

     
    function implementation() public view returns (address) {
        return _implementation;
    }
}

contract UpgradeabilityProxy is Proxy, UpgradeabilityStorage {
     
    event Upgraded(uint256 version, address indexed implementation);

     
    function _upgradeTo(uint256 version, address implementation) internal {
        require(_implementation != implementation);
        require(version > _version);
        _version = version;
        _implementation = implementation;
        Upgraded(version, implementation);
    }
}

 
contract UpgradeabilityOwnerStorage {
     
    address private _upgradeabilityOwner;

     
    function upgradeabilityOwner() public view returns (address) {
        return _upgradeabilityOwner;
    }

     
    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {
        _upgradeabilityOwner = newUpgradeabilityOwner;
    }
}

contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {
   
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

     
    function OwnedUpgradeabilityProxy() public {
        setUpgradeabilityOwner(msg.sender);
    }

     
    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner());
        _;
    }

     
    function proxyOwner() public view returns (address) {
        return upgradeabilityOwner();
    }

     
    function transferProxyOwnership(address newOwner) public onlyProxyOwner {
        require(newOwner != address(0));
        ProxyOwnershipTransferred(proxyOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

     
    function upgradeTo(uint256 version, address implementation) public onlyProxyOwner {
        _upgradeTo(version, implementation);
    }

     
    function upgradeToAndCall(uint256 version, address implementation, bytes data) payable public onlyProxyOwner {
        upgradeTo(version, implementation);
        require(address(this).call.value(msg.value)(data));
    }
}

 
contract EternalStorageProxy is OwnedUpgradeabilityProxy, EternalStorage {}