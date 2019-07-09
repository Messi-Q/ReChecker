pragma solidity ^0.4.21;

 

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

 

contract BonusStrategy {
    using SafeMath for uint;

    uint public defaultAmount = 1*10**18;
    uint public limit = 300*1000*10**18;  
    uint public currentAmount = 0;
    uint[] public startTimes;
    uint[] public endTimes;
    uint[] public amounts;

    constructor(
        uint[] _startTimes,
        uint[] _endTimes,
        uint[] _amounts
        ) public 
    {
        require(_startTimes.length == _endTimes.length && _endTimes.length == _amounts.length);
        startTimes = _startTimes;
        endTimes = _endTimes;
        amounts = _amounts;
    }

    function isStrategy() external pure returns (bool) {
        return true;
    }

    function getCurrentBonus() public view returns (uint bonus) {
        if (currentAmount >= limit) {
            currentAmount = currentAmount.add(defaultAmount);
            return defaultAmount;
        }
        for (uint8 i = 0; i < amounts.length; i++) {
            if (now >= startTimes[i] && now <= endTimes[i]) {
                bonus = amounts[i];
                currentAmount = currentAmount.add(bonus);
                return bonus;
            }
        }
        currentAmount = currentAmount.add(defaultAmount);
        return defaultAmount;
    }

}