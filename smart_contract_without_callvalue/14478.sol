pragma solidity ^0.4.18;

 
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

   
  function transferOwnership(address newOwner) public onlyOwner returns (bool) {
    require(newOwner != address(0));
    owner = newOwner;
    OwnershipTransferred(owner, newOwner);
    return true;
  }

}


pragma solidity ^0.4.18;

 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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


pragma solidity ^0.4.18;


 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


pragma solidity ^0.4.18;


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.4.18;

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  
   
  mapping(address => uint256) balances;

  uint256 public totalSupply;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply;
  } 

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

pragma solidity ^0.4.18;

 
contract CustomToken is ERC20, BasicToken, Ownable {

  mapping (address => mapping (address => uint256)) internal allowed;

   
  bool public enableTransfer = true;

   
  modifier whenTransferEnabled() {
    require(enableTransfer);
    _;
  }

  event Burn(address indexed burner, uint256 value);
  event EnableTransfer(address indexed owner, uint256 timestamp);
  event DisableTransfer(address indexed owner, uint256 timestamp);

  
   
  function transfer(address _to, uint256 _value) whenTransferEnabled public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function transferFrom(address _from, address _to, uint256 _value) whenTransferEnabled public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);


    if (msg.sender!=owner) {
      require(_value <= allowed[_from][msg.sender]);
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
    }  else {
      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
    }

    Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) whenTransferEnabled public returns (bool) {
     
     
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function approveAndCallAsContract(address _spender, uint256 _value, bytes _extraData) onlyOwner public returns (bool success) {
     
     
     

    allowed[this][_spender] = _value;
    Approval(this, _spender, _value);

     
     
     
    require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), this, _value, this, _extraData));
    return true;
  }

   
  function approveAndCall(address _spender, uint256 _value, bytes _extraData) whenTransferEnabled public returns (bool success) {
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);

     
     
     
    require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) whenTransferEnabled public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender, uint _subtractedValue) whenTransferEnabled public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }


   
  function burn(address _burner, uint256 _value) onlyOwner public returns (bool) {
    require(_value <= balances[_burner]);
     
     

    balances[_burner] = balances[_burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(_burner, _value);
    return true;
  }
    
  function enableTransfer() onlyOwner public returns (bool) {
    enableTransfer = true;
    EnableTransfer(owner, now);
    return true;
  }

   
  function disableTransfer() onlyOwner whenTransferEnabled public returns (bool) {
    enableTransfer = false;
    DisableTransfer(owner, now);
    return true;
  }
}

pragma solidity ^0.4.18;

 
contract Identify is CustomToken {

  string public constant name = "IDENTIFY";
  string public constant symbol = "IDF"; 
  uint8 public constant decimals = 6;

  uint256 public constant INITIAL_SUPPLY = 49253333333 * (10 ** uint256(decimals));

   
  function Identify() public {
    totalSupply = INITIAL_SUPPLY;
    balances[this] = INITIAL_SUPPLY;
    Transfer(0x0, this, INITIAL_SUPPLY);
  }

}


pragma solidity ^0.4.18;

 
contract Whitelist is Ownable {
    using SafeMath for uint256;

     
    bool public paused = false;

     
    uint256 public participantAmount;

     
    mapping (address => bool) public isParticipant;
    
     
    mapping (address => bool) public isAdmin;

    event AddParticipant(address _participant);
    event AddAdmin(address _admin, uint256 _timestamp);
    event RemoveParticipant(address _participant);
    event Paused(address _owner, uint256 _timestamp);
    event Resumed(address _owner, uint256 _timestamp);
  
     
    event ClaimedTokens(address indexed owner, address claimtoken, uint amount);
  
     
    modifier notPaused() {
        require(!paused);
        _;
    }

     
    modifier onlyAdmin() {
        require(isAdmin[msg.sender] || msg.sender == owner);
        _;
    }

     
    function () payable public {
         
        msg.sender.transfer(msg.value);
    }

     
    function Whitelist() public {
        require(addAdmin(msg.sender));
    }

     
    function isParticipant(address _participant) public view returns (bool) {
        require(address(_participant) != 0);
        return isParticipant[_participant];
    }

     
    function addParticipant(address _participant) public notPaused onlyAdmin returns (bool) {
        require(address(_participant) != 0);
        require(isParticipant[_participant] == false);

        isParticipant[_participant] = true;
        participantAmount++;
        AddParticipant(_participant);
        return true;
    }

     
    function removeParticipant(address _participant) public onlyAdmin returns (bool) {
        require(address(_participant) != 0);
        require(isParticipant[_participant]);
        require(msg.sender != _participant);

        delete isParticipant[_participant];
        participantAmount--;
        RemoveParticipant(_participant);
        return true;
    }

     
    function addAdmin(address _admin) public onlyAdmin returns (bool) {
        require(address(_admin) != 0);
        require(!isAdmin[_admin]);

        isAdmin[_admin] = true;
        AddAdmin(_admin, now);
        return true;
    }

     
    function removeAdmin(address _admin) public onlyAdmin returns (bool) {
        require(address(_admin) != 0);
        require(isAdmin[_admin]);
        require(msg.sender != _admin);

        delete isAdmin[_admin];
        return true;
    }

     
    function pauseWhitelist() public onlyAdmin returns (bool) {
        paused = true;
        Paused(msg.sender,now);
        return true;
    }

         
    function resumeWhitelist() public onlyAdmin returns (bool) {
        paused = false;
        Resumed(msg.sender,now);
        return true;
    }


      
    function addMultipleParticipants(address[] _participants ) public onlyAdmin returns (bool) {
        
        for ( uint i = 0; i < _participants.length; i++ ) {
            require(addParticipant(_participants[i]));
        }

        return true;
    }

      
    function addFiveParticipants(address participant1, address participant2, address participant3, address participant4, address participant5) public onlyAdmin returns (bool) {
        require(addParticipant(participant1));
        require(addParticipant(participant2));
        require(addParticipant(participant3));
        require(addParticipant(participant4));
        require(addParticipant(participant5));
        return true;
    }

      
    function addTenParticipants(address participant1, address participant2, address participant3, address participant4, address participant5,
     address participant6, address participant7, address participant8, address participant9, address participant10) public onlyAdmin returns (bool) 
     {
        require(addParticipant(participant1));
        require(addParticipant(participant2));
        require(addParticipant(participant3));
        require(addParticipant(participant4));
        require(addParticipant(participant5));
        require(addParticipant(participant6));
        require(addParticipant(participant7));
        require(addParticipant(participant8));
        require(addParticipant(participant9));
        require(addParticipant(participant10));
        return true;
    }

     
    function claimTokens(address _claimtoken) onlyAdmin public returns (bool) {
        if (_claimtoken == 0x0) {
            owner.transfer(this.balance);
            return true;
        }

        ERC20 claimtoken = ERC20(_claimtoken);
        uint balance = claimtoken.balanceOf(this);
        claimtoken.transfer(owner, balance);
        ClaimedTokens(_claimtoken, owner, balance);
        return true;
    }

}


pragma solidity ^0.4.18;

 
contract Presale is Ownable {
  using SafeMath for uint256;

   
  Identify public token;
   
  address public tokenAddress;

   
  uint256 public startTime;
  uint256 public endTime;

   
  address public wallet;

   
  Whitelist public whitelist;

   
  uint256 public rate = 420000;

   
  uint256 public weiRaised;  
  
   
  uint256 public tokenRaised;

   
   
  uint256 public capWEI;
   
  uint256 public capTokens;
   
  uint256 public bonusPercentage = 125;
   
  uint256 public minimumWEI;
   
  uint256 public maximumWEI;
   
  bool public paused = false;
   
  bool public isFinalized = false;

   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  
   
  event ClaimedTokens(address indexed owner, address claimtoken, uint amount);
  
   
  event Paused(address indexed owner, uint256 timestamp);
  
   
  event Resumed(address indexed owner, uint256 timestamp);

   
  modifier isInWhitelist(address beneficiary) {
     
    require(whitelist.isParticipant(beneficiary));
    _;
  }

   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
   
  modifier whenNotFinalized() {
    require(!isFinalized);
    _;
  }
   
  modifier onlyMultisigWallet() {
    require(msg.sender == wallet);
    _;
  }


   
  function Presale(uint256 _startTime, address _wallet, address _token, address _whitelist, uint256 _capETH, uint256 _capTokens, uint256 _minimumETH, uint256 _maximumETH) public {
  
    require(_startTime >= now);
    require(_wallet != address(0));
    require(_token != address(0));
    require(_whitelist != address(0));
    require(_capETH > 0);
    require(_capTokens > 0);
    require(_minimumETH > 0);
    require(_maximumETH > 0);

    startTime = _startTime;
    endTime = _startTime.add(19 weeks);
    wallet = _wallet;
    tokenAddress = _token;
    token = Identify(_token);
    whitelist = Whitelist(_whitelist);
    capWEI = _capETH * (10 ** uint256(18));
    capTokens = _capTokens * (10 ** uint256(6));
    minimumWEI = _minimumETH * (10 ** uint256(18));
    maximumWEI = _maximumETH * (10 ** uint256(18));
  }

   
  function () external payable {
    buyTokens(msg.sender);
  }

   
  function buyTokens(address beneficiary) isInWhitelist(beneficiary) whenNotPaused whenNotFinalized public payable returns (bool) {
    require(beneficiary != address(0));
    require(validPurchase());
    require(!hasEnded());
    require(!isContract(msg.sender));

    uint256 weiAmount = msg.value;

     
    uint256 tokens = getTokenAmount(weiAmount);
    require(tokenRaised.add(tokens) <= capTokens);
     
    weiRaised = weiRaised.add(weiAmount);
    tokenRaised = tokenRaised.add(tokens);

    require(token.transferFrom(tokenAddress, beneficiary, tokens));
    
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
    return true;
  }

   
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= capWEI;
    bool capTokensReached = tokenRaised >= capTokens;
    bool ended = now > endTime;
    return (capReached || capTokensReached) || ended;
  }



   
  function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
     
    uint256 bonusIntegrated = weiAmount.div(1000000000000).mul(rate).mul(bonusPercentage).div(100);
    return bonusIntegrated;
  }

   
  function forwardFunds() internal returns (bool) {
    wallet.transfer(msg.value);
    return true;
  }


   
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    bool underMaximumWEI = msg.value <= maximumWEI;
    bool withinCap = weiRaised.add(msg.value) <= capWEI;
    bool minimumWEIReached;
     
    if ( capWEI.sub(weiRaised) < minimumWEI) {
      minimumWEIReached = true;
    } else {
      minimumWEIReached = msg.value >= minimumWEI;
    }
    return (withinPeriod && nonZeroPurchase) && (withinCap && (minimumWEIReached && underMaximumWEI));
  }

   
  function transferOwnershipToken(address newOwner) onlyMultisigWallet public returns (bool) {
    require(token.transferOwnership(newOwner));
    return true;
  }

    
  function transferOwnership(address newOwner) onlyMultisigWallet public returns (bool) {
    require(newOwner != address(0));
    owner = newOwner;
    OwnershipTransferred(owner, newOwner);
    return true;
  }

      
   function finalize() onlyMultisigWallet whenNotFinalized public returns (bool) {
    require(hasEnded());

     
    if (!(capWEI == weiRaised)) {
       
      uint256 remainingTokens = capTokens.sub(tokenRaised);
       
      require(token.burn(tokenAddress, remainingTokens));    
    }
    require(token.transferOwnership(wallet));
    isFinalized = true;
    return true;
  }

   
   
   

   
  function isContract(address _addr) constant internal returns (bool) {
    if (_addr == 0) { 
      return false; 
    }
    uint256 size;
    assembly {
        size := extcodesize(_addr)
     }
    return (size > 0);
  }


   
  function claimTokens(address _claimtoken) onlyOwner public returns (bool) {
    if (_claimtoken == 0x0) {
      owner.transfer(this.balance);
      return true;
    }

    ERC20 claimtoken = ERC20(_claimtoken);
    uint balance = claimtoken.balanceOf(this);
    claimtoken.transfer(owner, balance);
    ClaimedTokens(_claimtoken, owner, balance);
    return true;
  }

   
  function pausePresale() onlyOwner public returns (bool) {
    paused = true;
    Paused(owner, now);
    return true;
  }

     
  function resumePresale() onlyOwner public returns (bool) {
    paused = false;
    Resumed(owner, now);
    return true;
  }


}