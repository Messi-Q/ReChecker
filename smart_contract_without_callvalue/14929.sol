pragma solidity 0.4.23;

 

contract ICOEngineInterface {

     
    function started() public view returns(bool);

     
    function ended() public view returns(bool);

     
    function startTime() public view returns(uint);

     
    function endTime() public view returns(uint);

     
     
     

     
     
     

     
    function totalTokens() public view returns(uint);

     
     
    function remainingTokens() public view returns(uint);

     
    function price() public view returns(uint);
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

 

 
contract KYCBase {
    using SafeMath for uint256;

    mapping (address => bool) public isKycSigner;
    mapping (uint64 => uint256) public alreadyPayed;

    event KycVerified(address indexed signer, address buyerAddress, uint64 buyerId, uint maxAmount);

    function KYCBase(address [] kycSigners) internal {
        for (uint i = 0; i < kycSigners.length; i++) {
            isKycSigner[kycSigners[i]] = true;
        }
    }

     
    function releaseTokensTo(address buyer, address signer) internal returns(bool);

     
    function senderAllowedFor(address buyer)
        internal view returns(bool)
    {
        return buyer == msg.sender;
    }

    function buyTokensFor(address buyerAddress, uint64 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s)
        public payable returns (bool)
    {
        require(senderAllowedFor(buyerAddress));
        return buyImplementation(buyerAddress, buyerId, maxAmount, v, r, s);
    }

    function buyTokens(uint64 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s)
        public payable returns (bool)
    {
        return buyImplementation(msg.sender, buyerId, maxAmount, v, r, s);
    }

    function buyImplementation(address buyerAddress, uint64 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s)
        private returns (bool)
    {
         
        bytes32 hash = sha256("Eidoo icoengine authorization", this, buyerAddress, buyerId, maxAmount);
        address signer = ecrecover(hash, v, r, s);
        if (!isKycSigner[signer]) {
            revert();
        } else {
            uint256 totalPayed = alreadyPayed[buyerId].add(msg.value);
            require(totalPayed <= maxAmount);
            alreadyPayed[buyerId] = totalPayed;
            KycVerified(signer, buyerAddress, buyerId, maxAmount);
            return releaseTokensTo(buyerAddress, signer);
        }
    }

     
    function () public {
        revert();
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
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

 

 
contract CappedToken is MintableToken {

  uint256 public cap;

  function CappedToken(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

   
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
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

 

 
contract StandardBurnableToken is BurnableToken, StandardToken {

   
  function burnFrom(address _from, uint256 _value) public {
    require(_value <= allowed[_from][msg.sender]);
     
     
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _burn(_from, _value);
  }
}

 

 
 
contract ORSToken is CappedToken, StandardBurnableToken, PausableToken {

    string public name = "ORS Token";
    string public symbol = "ORS";
    uint8 public decimals = 18;

     
     
    constructor(uint _cap) public CappedToken(_cap) {
        pause();   
    }

}

 

 
 
contract ORSTokenSale is KYCBase, ICOEngineInterface, Ownable {

    using SafeMath for uint;

     
     
     
     
    uint constant public PRESALE_CAP = 222247844e18;           
    uint constant public MAINSALE_CAP = 281945791e18;          
     
     
    uint constant public BONUS_CAP = 60266365e18;              

     
    uint constant public COMPANY_SHARE = 127206667e18;         
    uint constant public TEAM_SHARE = 83333333e18;             
    uint constant public ADVISORS_SHARE = 58333333e18;         

     
    uint public presaleRemaining = PRESALE_CAP;
    uint public mainsaleRemaining = MAINSALE_CAP;
    uint public bonusRemaining = BONUS_CAP;

     
    address public companyWallet;
    address public advisorsWallet;
    address public bountyWallet;

    ORSToken public token;

     
    uint public rate;

     
    uint public openingTime;
    uint public closingTime;

     
    address public wallet;

     
    address public eidooSigner;

    bool public isFinalized = false;

     
     
    event RateChanged(uint newRate);

     
     
     
     
    event TokenPurchased(address indexed buyer, uint value, uint tokens);

     
     
     
    event BuyerRefunded(address indexed buyer, uint value);

     
    event Finalized();

     
     
     
     
     
     
     
     
     
     
    constructor(
        ORSToken _token,
        uint _rate,
        uint _openingTime,
        uint _closingTime,
        address _wallet,
        address _companyWallet,
        address _advisorsWallet,
        address _bountyWallet,
        address[] _kycSigners
    )
        public
        KYCBase(_kycSigners)
    {
        require(_token != address(0x0));
        require(_token.cap() == PRESALE_CAP + MAINSALE_CAP + BONUS_CAP + COMPANY_SHARE + TEAM_SHARE + ADVISORS_SHARE);
        require(_rate > 0);
        require(_openingTime > now && _closingTime > _openingTime);
        require(_wallet != address(0x0));
        require(_companyWallet != address(0x0) && _advisorsWallet != address(0x0) && _bountyWallet != address(0x0));
        require(_kycSigners.length >= 2);

        token = _token;
        rate = _rate;
        openingTime = _openingTime;
        closingTime = _closingTime;
        wallet = _wallet;
        companyWallet = _companyWallet;
        advisorsWallet = _advisorsWallet;
        bountyWallet = _bountyWallet;

        eidooSigner = _kycSigners[0];
    }

     
     
    function setRate(uint newRate) public onlyOwner {
        require(newRate > 0);

        if (newRate != rate) {
            rate = newRate;

            emit RateChanged(newRate);
        }
    }

     
     
     
    function distributePresale(address[] investors, uint[] tokens) public onlyOwner {
        require(!isFinalized);
        require(tokens.length == investors.length);

        for (uint i = 0; i < investors.length; ++i) {
            presaleRemaining = presaleRemaining.sub(tokens[i]);

            token.mint(investors[i], tokens[i]);
        }
    }

     
    function finalize() public onlyOwner {
        require(ended() && !isFinalized);
        require(presaleRemaining == 0);

         
        token.mint(companyWallet, COMPANY_SHARE + TEAM_SHARE);
        token.mint(advisorsWallet, ADVISORS_SHARE);

         
         
         
        if (bonusRemaining > 0) {
            token.mint(bountyWallet, bonusRemaining);
            bonusRemaining = 0;
        }

         
        token.finishMinting();
        token.unpause();

        isFinalized = true;

        emit Finalized();
    }

     
     
     
    function started() public view returns (bool) {
        return now >= openingTime;
    }

     
     
     
    function ended() public view returns (bool) {
         
         
        return now > closingTime || mainsaleRemaining == 0;
    }

     
     
     
    function startTime() public view returns (uint) {
        return openingTime;
    }

     
     
     
    function endTime() public view returns (uint) {
        return closingTime;
    }

     
     
     
    function totalTokens() public view returns (uint) {
        return MAINSALE_CAP;
    }

     
     
     
     
     
    function remainingTokens() public view returns (uint) {
        return mainsaleRemaining;
    }

     
     
     
    function price() public view returns (uint) {
        return rate;
    }

     
     
     
     
    function releaseTokensTo(address buyer, address signer) internal returns (bool) {
        require(started() && !ended());

        uint value = msg.value;
        uint refund = 0;

        uint tokens = value.mul(rate);
        uint bonus = 0;

         
        if (tokens > mainsaleRemaining) {
            uint valueOfRemaining = mainsaleRemaining.div(rate);

            refund = value.sub(valueOfRemaining);
            value = valueOfRemaining;
            tokens = mainsaleRemaining;
             
             
             
             
             
             
             
        }

         
        if (signer == eidooSigner) {
            bonus = tokens.div(20);
        }

        mainsaleRemaining = mainsaleRemaining.sub(tokens);
        bonusRemaining = bonusRemaining.sub(bonus);

        token.mint(buyer, tokens.add(bonus));
        wallet.transfer(value);
        if (refund > 0) {
            buyer.transfer(refund);

            emit BuyerRefunded(buyer, refund);
        }

        emit TokenPurchased(buyer, value, tokens.add(bonus));

        return true;
    }

}