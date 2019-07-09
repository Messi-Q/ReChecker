pragma solidity ^0.4.24;

 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

 
contract TokenController {
     
     
     
     
     
     
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

     
     
     
     
     
     
     
    function onApprove(address _owner, address _spender, uint _amount_old, uint _amount_new) public returns(bool);
}

 
contract AHF_TokenController is Owned, TokenController {
     
     
     
     
     
     
    function onTransfer(address _from, address _to, uint _amount) public returns(bool) {
        return true;
    }

     
     
     
     
     
     
     
    function onApprove(address _owner, address _spender, uint _amount_old, uint _amount_new) public returns(bool) {
         
         
         
         
        require((_amount_new == 0) || (_amount_old == 0));
        return true;
    }
}