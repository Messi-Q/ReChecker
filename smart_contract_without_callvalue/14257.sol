pragma solidity ^0.4.23;

 
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

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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


 
contract CommitGoodToken is StandardToken, Ownable {
    using SafeMath for uint256;

    string public symbol = "GOOD";
    string public name = "GOOD";
    uint8 public decimals = 18;

    uint256 public maxSupply = 200000000 * (10 ** uint256(decimals));
    mapping (address => bool) public mintAgents;
    bool public mintingFinished = false;

    event MintAgentChanged(address indexed addr, bool state);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    modifier onlyMintAgent() {
        require(mintAgents[msg.sender]);
        _;
    }

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0));
        require(_addr != address(this));
        _;
    }

     
    function setMintAgent(address _addr, bool _state) public onlyOwner validAddress(_addr) {
        mintAgents[_addr] = _state;
        emit MintAgentChanged(_addr, _state);
    }

     
    function mint(address _addr, uint256 _amount) public onlyMintAgent canMint validAddress(_addr) returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_addr] = balances[_addr].add(_amount);
        emit Mint(_addr, _amount);
        emit Transfer(address(0), _addr, _amount);
        return true;
    }

     
    function finishMinting() public onlyMintAgent canMint returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}

 
contract Crowdsale {
  using SafeMath for uint256;

   
  ERC20 public token;

   
  address public wallet;

   
  uint256 public rate;

   
  uint256 public weiRaised;

   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

   
  constructor(uint256 _rate, address _wallet, ERC20 _token) public {
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
    emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

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

 
contract WhiteListRegistry is Ownable {

    mapping (address => WhiteListInfo) public whitelist;

    struct WhiteListInfo {
        bool whiteListed;
        uint minCap;
    }

    event AddedToWhiteList(address contributor, uint minCap);

    event RemovedFromWhiteList(address _contributor);

    function addToWhiteList(address _contributor, uint _minCap) public onlyOwner {
        require(_contributor != address(0));
        whitelist[_contributor] = WhiteListInfo(true, _minCap);
        emit AddedToWhiteList(_contributor, _minCap);
    }

    function removeFromWhiteList(address _contributor) public onlyOwner {
        require(_contributor != address(0));
        delete whitelist[_contributor];
        emit RemovedFromWhiteList(_contributor);
    }

    function isWhiteListed(address _contributor) public view returns(bool) {
        return whitelist[_contributor].whiteListed;
    }

    function isAmountAllowed(address _contributor, uint _amount) public view returns(bool) {
        return whitelist[_contributor].minCap <= _amount && isWhiteListed(_contributor);
    }
}

contract CommitGoodCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;

    uint256 public cap;
    uint256 public openingTime;
    uint256 public closingTime;

    address public whiteListAddress;

     
    constructor(uint256 _openingTime, uint256 _closingTime, uint256 _rate, address _wallet, uint256 _cap, CommitGoodToken _token, address _whiteListAddress) public Crowdsale(_rate, _wallet, _token) {
		 
		 
        require(_cap > 0);
		 
        require(_openingTime >= now);
        require(_closingTime >= _openingTime);

        openingTime = _openingTime;
        closingTime = _closingTime;
        cap = _cap;
        whiteListAddress = _whiteListAddress;
    }

	 
    function capReached() public view returns (bool) {
        return weiRaised >= cap;
    }

	 
    function hasClosed() public view returns (bool) {
         
        return block.timestamp > closingTime;
    }

     
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        super._preValidatePurchase(_beneficiary, _weiAmount);
         
        require(now >= openingTime && now <= closingTime);
        require(weiRaised.add(_weiAmount) <= cap);
        require(WhiteListRegistry(whiteListAddress).isAmountAllowed(_beneficiary, _weiAmount));
    }

     
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        require(CommitGoodToken(token).mint(_beneficiary, _tokenAmount));
    }
}