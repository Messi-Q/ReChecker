pragma solidity 0.4.23;

 

 
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
    Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
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
    Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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

 

 
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

   
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
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
    Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

 

 
contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

 

 
contract REBToken is PausableToken, MintableToken {
    string public name = "REBGLO Token";
    string public symbol = "REB";
    uint8 public decimals = 18;

     
    function REBToken() public {
        pause();
    }

     
    function checkBalanceTier(address holderAddress) public view returns(string) {
        uint256 holderBalance = balanceOf(holderAddress);

        if (holderBalance >= 1000000e18) {
            return "Platinum tier";
        } else if (holderBalance >= 700000e18) {
            return "Gold tier";
        } else if (holderBalance >= 300000e18) {
            return "Titanium tier";
        } else if (holderBalance == 0) {
            return "Possess no REB";
        }

        return "Free tier";
    }
}

 

 
contract LockTokenAllocation is Ownable {
    using SafeMath for uint;
    uint256 public unlockedAt;
    uint256 public canSelfDestruct;
    uint256 public tokensCreated;
    uint256 public allocatedTokens;
    uint256 public totalLockTokenAllocation;

    mapping (address => uint256) public lockedAllocations;

    REBToken public REB;

     
    function LockTokenAllocation
        (
            REBToken _token,
            uint256 _unlockedAt,
            uint256 _canSelfDestruct,
            uint256 _totalLockTokenAllocation
        )
        public
    {
        require(_token != address(0));

        REB = REBToken(_token);
        unlockedAt = _unlockedAt;
        canSelfDestruct = _canSelfDestruct;
        totalLockTokenAllocation = _totalLockTokenAllocation;
    }

     
    function addLockTokenAllocation(address beneficiary, uint256 allocationValue)
        external
        onlyOwner
        returns(bool)
    {
        require(lockedAllocations[beneficiary] == 0 && beneficiary != address(0));  

        allocatedTokens = allocatedTokens.add(allocationValue);
        require(allocatedTokens <= totalLockTokenAllocation);

        lockedAllocations[beneficiary] = allocationValue;
        return true;
    }


     
    function unlock() external {
        require(REB != address(0));
        assert(now >= unlockedAt);

         
        if (tokensCreated == 0) {
            tokensCreated = REB.balanceOf(this);
        }

        uint256 transferAllocation = lockedAllocations[msg.sender];
        lockedAllocations[msg.sender] = 0;

         
        require(REB.transfer(msg.sender, transferAllocation));
    }

     
    function kill() public onlyOwner {
        require(now >= canSelfDestruct);
        uint256 balance = REB.balanceOf(this);

        if (balance > 0) {
            REB.transfer(msg.sender, balance);
        }

        selfdestruct(owner);
    }
}

 

 

contract Crowdsale {
  using SafeMath for uint256;

   
  ERC20 public token;

   
  address public wallet;

   
  uint256 public rate;

   
  uint256 public weiRaised;

   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

   
  function Crowdsale(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

   
   
   

   
  function () external payable {
    buyTokens(msg.sender);
  }

   
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

     
    uint256 tokens = _getTokenAmount(weiAmount);

     
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

   
   
   

   
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

   
  function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
     
  }

   
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.transfer(_beneficiary, _tokenAmount);
  }

   
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

   
  function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
     
  }

   
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(rate);
  }

   
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

 

 
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

   
  modifier onlyWhileOpen {
    require(now >= openingTime && now <= closingTime);
    _;
  }

   
  function TimedCrowdsale(uint256 _openingTime, uint256 _closingTime) public {
    require(_openingTime >= now);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

   
  function hasClosed() public view returns (bool) {
    return now > closingTime;
  }

   
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyWhileOpen {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

 

 
contract FinalizableCrowdsale is TimedCrowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

   
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasClosed());

    finalization();
    Finalized();

    isFinalized = true;
  }

   
  function finalization() internal {
  }
}

 

 
contract WhitelistedCrowdsale is Crowdsale, Ownable {

  mapping(address => bool) public whitelist;

   
  modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary]);
    _;
  }

   
  function addToWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = true;
  }

   
  function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
    }
  }

   
  function removeFromWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = false;
  }

   
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal isWhitelisted(_beneficiary) {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

 

 
contract REBCrowdsale is FinalizableCrowdsale, WhitelistedCrowdsale, Pausable {
    uint256 constant public BOUNTY_SHARE =               125000000e18;    
    uint256 constant public TEAM_SHARE =                 2800000000e18;   
    uint256 constant public ADVISOR_SHARE =              1750000000e18;   

    uint256 constant public AIRDROP_SHARE =              200000000e18;    
    uint256 constant public TOTAL_TOKENS_FOR_CROWDSALE = 5125000000e18;   

    uint256 constant public PUBLIC_CROWDSALE_SOFT_CAP =  800000000e18;   

    address public bountyWallet;
    address public teamReserve;
    address public advisorReserve;
    address public airdrop;

     
     
    address public remainderPurchaser;
    uint256 public remainderAmount;

     

    event MintedTokensFor(address indexed investor, uint256 tokensPurchased);
    event TokenRateChanged(uint256 previousRate, uint256 newRate);

     
    function REBCrowdsale
        (
            uint256 _openingTime,
            uint256 _closingTime,
            REBToken _token,
            uint256 _rate,
            address _wallet,
            address _bountyWallet
        )
        public
        FinalizableCrowdsale()
        Crowdsale(_rate, _wallet, _token)
        TimedCrowdsale(_openingTime, _closingTime)
    {
        require(_bountyWallet != address(0));
        bountyWallet = _bountyWallet;

        require(REBToken(token).paused());
         
    }

     
    function setRate(uint256 newRate) external onlyOwner {
        require(newRate != 0);

        TokenRateChanged(rate, newRate);
        rate = newRate;
    }

     
    function mintTokensFor(address beneficiaryAddress, uint256 amountOfTokens)
        public
        onlyOwner
    {
        require(beneficiaryAddress != address(0));
        require(token.totalSupply().add(amountOfTokens) <= TOTAL_TOKENS_FOR_CROWDSALE);

        _deliverTokens(beneficiaryAddress, amountOfTokens);
        MintedTokensFor(beneficiaryAddress, amountOfTokens);
    }

     
    function setTeamAndAdvisorAndAirdropAddresses
        (
            address _teamReserve,
            address _advisorReserve,
            address _airdrop
        )
        public
        onlyOwner
    {
         
        require(teamReserve == address(0x0) && advisorReserve == address(0x0) && airdrop == address(0x0));
         
        require(_teamReserve != address(0x0) && _advisorReserve != address(0x0) && _airdrop != address(0x0));

        teamReserve = _teamReserve;
        advisorReserve = _advisorReserve;
        airdrop = _airdrop;
    }

     
     
    function hasClosed() public view returns (bool) {
        if (token.totalSupply() > PUBLIC_CROWDSALE_SOFT_CAP) {
            return true;
        }

        return super.hasClosed();
    }

     
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        require(MintableToken(token).mint(_beneficiary, _tokenAmount));
    }

     
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
        internal
        isWhitelisted(_beneficiary)
        whenNotPaused
    {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
        require(token.totalSupply() < TOTAL_TOKENS_FOR_CROWDSALE);
    }

     
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 tokensAmount = _weiAmount.mul(rate);

         
        if (token.totalSupply().add(tokensAmount) > TOTAL_TOKENS_FOR_CROWDSALE) {
            tokensAmount = TOTAL_TOKENS_FOR_CROWDSALE.sub(token.totalSupply());
            uint256 _weiAmountLocalScope = tokensAmount.div(rate);

             
            remainderPurchaser = msg.sender;
            remainderAmount = _weiAmount.sub(_weiAmountLocalScope);

             
            if (weiRaised > _weiAmount.add(_weiAmountLocalScope))
                weiRaised = weiRaised.sub(_weiAmount.add(_weiAmountLocalScope));
        }

        return tokensAmount;
    }

     
    function finalization() internal {
         
        require(teamReserve != address(0x0) && advisorReserve != address(0x0) && airdrop != address(0x0));

        if (TOTAL_TOKENS_FOR_CROWDSALE > token.totalSupply()) {
            uint256 remainingTokens = TOTAL_TOKENS_FOR_CROWDSALE.sub(token.totalSupply());
            _deliverTokens(wallet, remainingTokens);
        }

         
        _deliverTokens(bountyWallet, BOUNTY_SHARE);
        _deliverTokens(teamReserve, TEAM_SHARE);
        _deliverTokens(advisorReserve, ADVISOR_SHARE);
        _deliverTokens(airdrop, AIRDROP_SHARE);

        REBToken(token).finishMinting();
        REBToken(token).unpause();
        super.finalization();
    }
}