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

 

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

 

 
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

   
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
     
     

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

 

contract InfoBurnableToken is BurnableToken, StandardToken {
    string message = "No sufficient funds";
    address public manager;

    event NoFunds(address _who, string _message);

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    constructor(address _manager) public {
        require(address(_manager) != 0);
        manager = _manager;
    }

    function burn(uint256 _value) public {
        if (balances[msg.sender] < _value){
            emit NoFunds(msg.sender, message);
        }else {
            _burn(msg.sender, _value);
        }
    }

    function burnPassportToken(address _from, uint256 _value) onlyManager public returns (bool) {
        if (_value <= balances[_from]){
            _burn(_from, _value);
            return true;
        }
        emit NoFunds(_from, message);
        return false;
    }

    function transferManager(address _newManager) onlyManager public returns (bool) {
        require(address(_newManager) != 0);
        manager = _newManager;
        return true;
    }

}

 

contract DecenturionToken is InfoBurnableToken {
    using SafeMath for uint;

    string constant public name = "Decenturion Token";
    string constant public symbol = "DCNT";
    uint constant public decimals = 18;
    uint constant public deployerAmount = 20 * (10 ** 6) * (10 ** decimals);  
    uint constant public managerAmount = 10 * (10 ** 6) * (10 ** decimals);  

    constructor(address _manager) InfoBurnableToken(_manager) public {
        totalSupply_ = 30 * (10 ** 6) * (10 ** decimals);  
        balances[msg.sender] = deployerAmount;
        balances[manager] = managerAmount;
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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

 

contract TokenManager is Ownable, Pausable {
    using SafeMath for uint;

    uint public totalRegistrationBonusAmount = 0;
    uint public emissionTime;
    uint public tokensForBurn = 1*10**18; 
    string public alreadyRegisteredMessage = "user already registered";
    string public nullBonusMessage = "registration bonus = 0";

    mapping (address=>bool) isRegistered;
    mapping (address=>bool) isTokensDistributed;

    BonusStrategy public bonusStrategy;
    DecenturionToken public token;

    event UserAlreadyRegistered(address user, string message);
    event TokensAlreadyDistributed(address user);

    constructor(BonusStrategy _bonusStrategy, uint _emissionTime) public {
        require(_bonusStrategy.isStrategy());
        require(_emissionTime > now);
        bonusStrategy = _bonusStrategy;
        emissionTime = _emissionTime;
    }

    function() public payable { }

    function setTokenAddress(DecenturionToken _token) onlyOwner public returns (bool){
        require(address(_token) != 0);
        token = _token;
        return true;
    }

    function distributeRegistrationBonus(address _recepient) onlyOwner whenNotPaused public returns (bool) {
        if (!isRegistered[_recepient]) {
            _distributeRegistrationBonus(_recepient);
            isRegistered[_recepient] = true;
        }else {
            emit UserAlreadyRegistered(_recepient, alreadyRegisteredMessage);
            return false;
        }
        return true;
    }

    function _distributeRegistrationBonus(address _recepient) internal returns (bool) {
        uint registrationBonus = bonusStrategy.getCurrentBonus();
        totalRegistrationBonusAmount = totalRegistrationBonusAmount.add(registrationBonus);  
        token.transfer(_recepient, registrationBonus);
        return true;
    }

    function distributeTokens(address _address, uint _totalEthBalance) onlyOwner whenNotPaused public returns (bool) {
        require(now >= emissionTime);
        if (isTokensDistributed[_address]){
            emit TokensAlreadyDistributed(_address);
            return false;
        }
        uint decimals = 10**18;
        uint precision = 10**3;
        uint balance = _address.balance;
        uint stake = balance.div(_totalEthBalance);
        uint total = token.managerAmount().sub(totalRegistrationBonusAmount);
        uint emission = stake.mul(total).div(decimals).mul(precision);
        token.transfer(_address, emission);
        isTokensDistributed[_address] = true;
        return true;
    }

    function setEmissionTime(uint _time) onlyOwner whenNotPaused public returns (bool) {
        require(now <= _time);
        emissionTime = _time;
        return true;
    }

    function register(address _who) onlyOwner whenNotPaused public returns (bool) {
        if (isRegistered[_who]) {
            emit UserAlreadyRegistered(_who, alreadyRegisteredMessage);
            return false;
        }
        _distributeRegistrationBonus(_who);

        bool isBurned = token.burnPassportToken(_who, tokensForBurn);
        if (isBurned) {
            isRegistered[_who] = true;
            return true;
        }else{
            return false;
        }
    }

    function sendTokensTo(address[] _users, uint _amount) onlyOwner whenNotPaused public {
        uint maxLength = 10;
        if (_users.length < maxLength) {
            maxLength = _users.length;
        }
        for (uint i = 0; i < maxLength; i++){
            token.transfer(_users[i], _amount);
        }
    }

    function substituteManagerContract(address _newManager) onlyOwner whenNotPaused public {
        token.transferManager(_newManager);
    }

}