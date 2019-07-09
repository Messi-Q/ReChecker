pragma solidity ^0.4.18;


 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract PropertyClubICO is Ownable {
    uint256 public constant minLimit = 0.4 ether;
    bool public isFinished;
    mapping (address => uint256) public balanceOf;
    uint256 public totalRaised;
    
    
    event Deposit(address indexed _from, uint _value);
    
    constructor() public {
        isFinished = false;
    }
    
    function () public payable {
        deposit();
    }
    
    function deposit() public payable {
        require(msg.value >= minLimit && !isFinished);
        
        owner.transfer(msg.value);
        balanceOf[msg.sender] += msg.value;
        totalRaised += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    function finishICO() onlyOwner public {
        isFinished = true;
    }
    
}