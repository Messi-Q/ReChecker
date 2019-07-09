pragma solidity ^0.4.21;

pragma solidity ^0.4.10;


 
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
pragma solidity ^0.4.21;

 
contract Ownable {
	address public owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	 
	function Ownable()public {
		owner = msg.sender;
	}

	 
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	 
	function transferOwnership(address newOwner)public onlyOwner {
		require(newOwner != address(0));
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}

}

 
contract BonusScheme is Ownable {
	using SafeMath for uint256;

	 
	uint256 startOfFirstBonus = 1526021400;
	uint256 endOfFirstBonus = (startOfFirstBonus - 1) + 5 minutes;	
	uint256 startOfSecondBonus = (startOfFirstBonus + 1) + 5 minutes;
	uint256 endOfSecondBonus = (startOfSecondBonus - 1) + 5 minutes;
	uint256 startOfThirdBonus = (startOfSecondBonus + 1) + 5 minutes;
	uint256 endOfThirdBonus = (startOfThirdBonus - 1) + 5 minutes;
	uint256 startOfFourthBonus = (startOfThirdBonus + 1) + 5 minutes;
	uint256 endOfFourthBonus = (startOfFourthBonus - 1) + 5 minutes;
	uint256 startOfFifthBonus = (startOfFourthBonus + 1) + 5 minutes;
	uint256 endOfFifthBonus = (startOfFifthBonus - 1) + 5 minutes;
	
	 
	uint256 firstBonus = 35;
	uint256 secondBonus = 30;
	uint256 thirdBonus = 20;
	uint256 fourthBonus = 10;
	uint256 fifthBonus = 5;

	event BonusCalculated(uint256 tokenAmount);

    function BonusScheme() public {
        
    }

	 
	function getBonusTokens(uint256 _tokenAmount)onlyOwner public returns(uint256) {
		if (block.timestamp >= startOfFirstBonus && block.timestamp <= endOfFirstBonus) {
			_tokenAmount = _tokenAmount.mul(firstBonus).div(100);
		} else if (block.timestamp >= startOfSecondBonus && block.timestamp <= endOfSecondBonus) {
			_tokenAmount = _tokenAmount.mul(secondBonus).div(100);
		} else if (block.timestamp >= startOfThirdBonus && block.timestamp <= endOfThirdBonus) {
			_tokenAmount = _tokenAmount.mul(thirdBonus).div(100);
		} else if (block.timestamp >= startOfFourthBonus && block.timestamp <= endOfFourthBonus) {
			_tokenAmount = _tokenAmount.mul(fourthBonus).div(100);
		} else if (block.timestamp >= startOfFifthBonus && block.timestamp <= endOfFifthBonus) {
			_tokenAmount = _tokenAmount.mul(fifthBonus).div(100);
		} else _tokenAmount=0;
		emit BonusCalculated(_tokenAmount);
		return _tokenAmount;
	}
}