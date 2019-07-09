pragma solidity ^0.4.18;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

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

contract BeatOrgTokenPostSale is Ownable {
    using SafeMath for uint256;

    address public wallet;

    uint256 public endTime;
    bool public finalized;

    uint256 public weiRaised;
    mapping(address => uint256) public purchases;

    event Purchase(address indexed purchaser, address indexed beneficiary, uint256 weiAmount);

    function BeatOrgTokenPostSale(address _wallet) public {
        require(_wallet != address(0));
        wallet = _wallet;

         
        endTime = 1531691999;
        finalized = false;
    }

    function() payable public {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) payable public {
        require(beneficiary != address(0));
        require(msg.value != 0);
        require(validPurchase());

        uint256 weiAmount = msg.value;

        purchases[beneficiary] += weiAmount;
        weiRaised += weiAmount;

        Purchase(msg.sender, beneficiary, weiAmount);

        wallet.transfer(weiAmount);
    }

    function finalize() onlyOwner public {
        endTime = now;
        finalized = true;
    }

    function validPurchase() internal view returns (bool) {
        return (now <= endTime) && (finalized == false);
    }

}