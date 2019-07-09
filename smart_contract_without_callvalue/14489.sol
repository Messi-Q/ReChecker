pragma solidity 0.4.23;

 
contract Ownable {
  address public owner;

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);

    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract Proxied is Ownable {
    address public target;
    mapping (address => bool) public initialized;

    event EventUpgrade(address indexed newTarget, address indexed oldTarget, address indexed admin);
    event EventInitialized(address indexed target);

    function upgradeTo(address _target) public;
}

contract Proxy is Proxied {
     
    constructor(address _target) public {
        upgradeTo(_target);
    }

     
    function upgradeTo(address _target) public onlyOwner {
        assert(target != _target);

        address oldTarget = target;
        target = _target;

        emit EventUpgrade(_target, oldTarget, msg.sender);
    }

     
    function upgradeTo(address _target, bytes _data) public onlyOwner {
        upgradeTo(_target);
        assert(target.delegatecall(_data));
    }

     
    function () payable public {
        bytes memory data = msg.data;
        address impl = target;

        assembly {
            let result := delegatecall(gas, impl, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize

            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}