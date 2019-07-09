contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
  function Ownable() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract AccountLevels {
   
   
   
   
  function accountLevel(address user) constant returns(uint) {}
}

contract AccountLevelsTest is AccountLevels, Ownable {
  mapping (address => uint) public accountLevels;

  function setAccountLevel(address user, uint level) onlyOwner {
    accountLevels[user] = level;
  }

  function accountLevel(address user) constant returns(uint) {
    return accountLevels[user];
  }
}