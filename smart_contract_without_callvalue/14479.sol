pragma solidity ^0.4.11;

 

 
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
     
    uint256 c = a / b;
     
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

 

 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

 

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

     
     

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

   
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

 

 
pragma solidity ^0.4.11;


contract FTV is StandardToken {

     
    bool public presaleFinished = false;

    uint256 public soldTokens;

    string public constant name = "FTV Coin Deluxe";

    string public constant symbol = "FTV";

    uint8 public constant decimals = 18;

    mapping(address => bool) public whitelist;

    mapping(address => address) public referral;

    address public reserves;

    address public stateControl;

    address public whitelistControl;

    address public tokenAssignmentControl;

    uint256 constant pointMultiplier = 1e18;  

    uint256 public constant maxTotalSupply = 100000000 * pointMultiplier;  

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


     
    function FTV(
        address _stateControl
      , address _whitelistControl
      , address _tokenAssignmentControl
      , address _reserves
    ) public
    {
        stateControl = _stateControl;
        whitelistControl = _whitelistControl;
        tokenAssignmentControl = _tokenAssignmentControl;
        totalSupply = maxTotalSupply;
        soldTokens = 0;
        reserves = _reserves;
        balances[reserves] = totalSupply;
        Mint(reserves, totalSupply);
        Transfer(0x0, reserves, totalSupply);
        finishMinting();
    }

    event Whitelisted(address addr);

    event Referred(address parent, address child);

    modifier onlyWhitelist() {
        require(msg.sender == whitelistControl);
        _;
    }

    modifier onlyStateControl() {
        require(msg.sender == stateControl);
        _;
    }

    modifier onlyTokenAssignmentControl() {
        require(msg.sender == tokenAssignmentControl);
        _;
    }

    modifier requirePresale() {
        require(presaleFinished == false);
        _;
    }

     
    function() payable public
    {
        revert();
    }

    function issueTokensToUser(address beneficiary, uint256 amount)
    internal
    {
        uint256 soldTokensAfterInvestment = soldTokens.add(amount);
        require(soldTokensAfterInvestment <= maxTotalSupply);

        balances[beneficiary] = balances[beneficiary].add(amount);
        balances[reserves] = balances[reserves].sub(amount);
        soldTokens = soldTokensAfterInvestment;
        Transfer(reserves, beneficiary, amount);
    }

    function issueTokensWithReferral(address beneficiary, uint256 amount)
    internal
    {
        issueTokensToUser(beneficiary, amount);
        if (referral[beneficiary] != 0x0) {
             
            issueTokensToUser(referral[beneficiary], amount.mul(5).div(100));
        }
    }

    function addPresaleAmount(address beneficiary, uint256 amount)
    public
    onlyTokenAssignmentControl
    requirePresale
    {
        issueTokensWithReferral(beneficiary, amount);
    }

    function finishMinting()
    internal
    {
        mintingFinished = true;
        MintFinished();
    }

    function finishPresale()
    public
    onlyStateControl
    {
        presaleFinished = true;
    }

    function addToWhitelist(address _whitelisted)
    public
    onlyWhitelist
    {
        whitelist[_whitelisted] = true;
        Whitelisted(_whitelisted);
    }


    function addReferral(address _parent, address _child)
    public
    onlyWhitelist
    {
        require(_parent != _child);
        require(whitelist[_parent] == true && whitelist[_child] == true);
        require(referral[_child] == 0x0);
        referral[_child] = _parent;
        Referred(_parent, _child);
    }

     
    function rescueToken(ERC20Basic _foreignToken, address _to)
    public
    onlyTokenAssignmentControl
    {
        _foreignToken.transfer(_to, _foreignToken.balanceOf(this));
    }
}