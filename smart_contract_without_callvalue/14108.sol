contract Delegatable {
  address empty1;  
  address empty2;  
  address empty3;   
  address public owner;   
  address public delegation;  

  event DelegationTransferred(address indexed previousDelegate, address indexed newDelegation);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferDelegation(address newDelegation) public onlyOwner {
    require(newDelegation != address(0));
    emit DelegationTransferred(delegation, newDelegation);
    delegation = newDelegation;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract DelegateProxy {

     
    function delegatedFwd(address _dst, bytes _calldata) internal {
        assembly {
            let result := delegatecall(sub(gas, 10000), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
            let size := returndatasize

            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

             
             
            switch result case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}

contract Proxy is Delegatable, DelegateProxy {

   
  function () public {
    delegatedFwd(delegation, msg.data);
  }

   
  function initialize(address _controller, uint256 _cap) public {
    require(owner == 0);
    owner = msg.sender;
    delegation = _controller;
    delegatedFwd(_controller, msg.data);
  }

}