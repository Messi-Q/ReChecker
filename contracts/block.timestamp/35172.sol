pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

interface EthVestInterface {
    function investmentOf(address _beneficiary) public constant returns (uint256 _value, uint256 _date);
    function invest() public payable returns (bool);
    event Invest(address indexed _beneficiary, uint256 _value);
    function divest(uint256 _value) public returns (bool);
    function divest() public returns (bool);
    event Divest(address indexed _beneficiary, uint256 _value);
    function claim() public returns (bool);
    event Coupon(address indexed _beneficiary, uint256 _coupon, uint256 indexed _date);
}

contract Owned {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Owned() {
        owner = msg.sender;
    }

    function updateOwner(address _owner) public onlyOwner {
        owner = _owner;
    }
}

contract Stoppable is Owned {
    event Stop(bytes32 message);
    bool private stopped = false;

    modifier onlyNotStopped() {
        require(!stopped);
        _;
    }

    function stop(bytes32 message) external onlyOwner {
        _stop(message);
    }

    function _stop(bytes32 message) internal {
        stopped = true;
        Stop(message);
    }
}

contract Startable is Owned {
    event Start();
    bool private started = false;

    modifier onlyAfterStart() {
        require(started);
        _;
    }

    modifier onlyBeforeStart() {
        require(!started);
        _;
    }

    function start() external onlyOwner {
        started = true;
        Start();
    }
}

contract SafeArithmetic {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  
  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until 
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) 
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) 
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract EthVest is EthVestInterface, StandardToken, Owned, Stoppable, Startable, SafeArithmetic {
    event Mint(address indexed _to, uint256 _value);
    string public name = "EthVest";
    uint8 public decimals = 18;
    string public symbol = "VST";
    string public version = "1";

    struct Investment {
        uint256 value;
        uint256 date;
    }

    mapping(address => Investment) public investments;
    uint256 totalWorth;

    function EthVest() {
    }

    function mint(address _to, uint256 _value) external onlyOwner onlyBeforeStart returns (bool) {
        _mint(_to, _value);
    }

    function _mint(address _to, uint256 _value) private returns (bool) {
        totalSupply = totalSupply.add(_value);
        balances[_to] = balances[_to].add(_value);
        Mint(_to, _value);
        return true;
    }

    function investmentOf(address _beneficiary) public constant returns (uint256 _value, uint256 _date) {
        Investment storage _investment = investments[_beneficiary];
        return (_investment.value, _investment.date);
    }

    function invest() public payable onlyNotStopped onlyAfterStart returns (bool) {
        claim();
        Investment storage _investment = investments[msg.sender];
        _investment.value = add(_investment.value, msg.value);
        totalWorth = add(totalWorth, msg.value);
        if (this.balance != totalWorth) {
            _stop("leakDetected");
        }
        Invest(msg.sender, msg.value);
        return true;
    }

    function divest(uint256 _value) public onlyAfterStart returns (bool) {
        claim();
        Investment storage _investment = investments[msg.sender];
        uint256 _valueOld = _investment.value;
        uint256 _totalWorthOld = totalWorth;
        _investment.value = sub(_investment.value, _value);
        totalWorth = sub(totalWorth, _value);
        if (!msg.sender.send(_value)) {
            _investment.value = _valueOld;
            totalWorth = _totalWorthOld;
            return false;
        }
        if (_investment.value == 0) {
            delete investments[msg.sender];
        }
        Divest(msg.sender, _value);
        return true;
    }

    function divest() public onlyAfterStart returns (bool) {
        return divest(investments[msg.sender].value);
    }

    function claim() public onlyAfterStart returns (bool) {
        Investment storage _investment = investments[msg.sender];
        uint256 _term = sub(block.timestamp, _investment.date);
        _investment.date = block.timestamp;
        uint256 _coupon = mul(_investment.value, _term);
        if (_coupon == 0) {
            return false;
        }
        _mint(msg.sender, _coupon);
        Coupon(msg.sender, _coupon, _investment.date);
        return true;
    }

    function() payable {
        invest();
    }
}