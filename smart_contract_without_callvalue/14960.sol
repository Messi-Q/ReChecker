pragma solidity ^0.4.23;

 
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

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
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

 
contract EXOToken is StandardToken, Ownable {
    uint8 constant PERCENT_BOUNTY=1;
    uint8 constant PERCENT_TEAM=15;
    uint8 constant PERCENT_FOUNDATION=11;
    uint8 constant PERCENT_USER_REWARD=3;
    uint8 constant PERCENT_ICO=70;
    uint256 constant UNFREEZE_FOUNDATION  = 1546214400;
     
     
     
     
     
     
    mapping(address => bool) public frozenAccounts;

    string public  name;
    string public  symbol;
    uint8  public  decimals;
    uint256 public UNFREEZE_TEAM_BOUNTY = 1535760000;  

    address public accForBounty;
    address public accForTeam;
    address public accFoundation;
    address public accUserReward;
    address public accICO;


     
     
     
    event NewFreeze(address acc, bool isFrozen);
    event BatchDistrib(uint8 cnt , uint256 batchAmount);
    event Burn(address indexed burner, uint256 value);


     
    constructor(
        address _accForBounty, 
        address _accForTeam, 
        address _accFoundation, 
        address _accUserReward, 
        address _accICO) 
    public 
    {
        name = "EXOLOVER";
        symbol = "EXO";
        decimals = 18;
        totalSupply_ = 1000000000 * (10 ** uint256(decimals)); 
         
        balances[_accForBounty] = totalSupply()/100*PERCENT_BOUNTY;
        balances[_accForTeam]   = totalSupply()/100*PERCENT_TEAM;
        balances[_accFoundation]= totalSupply()/100*PERCENT_FOUNDATION;
        balances[_accUserReward]= totalSupply()/100*PERCENT_USER_REWARD;
        balances[_accICO]       = totalSupply()/100*PERCENT_ICO;
         
        accForBounty  = _accForBounty;
        accForTeam    = _accForTeam;
        accFoundation = _accFoundation;
        accUserReward = _accUserReward;
        accICO        = _accICO;
         
        emit Transfer(address(0), _accForBounty,  totalSupply()/100*PERCENT_BOUNTY);
        emit Transfer(address(0), _accForTeam,    totalSupply()/100*PERCENT_TEAM);
        emit Transfer(address(0), _accFoundation, totalSupply()/100*PERCENT_FOUNDATION);
        emit Transfer(address(0), _accUserReward, totalSupply()/100*PERCENT_USER_REWARD);
        emit Transfer(address(0), _accICO,        totalSupply()/100*PERCENT_ICO);

        frozenAccounts[accFoundation] = true;
        emit NewFreeze(accFoundation, true);
    }

    modifier onlyTokenKeeper() {
      require(msg.sender == accICO);
      _;
    } 


    function isFrozen(address _acc) internal view returns(bool frozen) {
        if (_acc == accFoundation && now < UNFREEZE_FOUNDATION) 
            return true;
        return (frozenAccounts[_acc] && now < UNFREEZE_TEAM_BOUNTY);    
    }

    function freezeUntil(address _acc, bool _isfrozen) external onlyOwner returns (bool success){
        require(now <= UNFREEZE_TEAM_BOUNTY); 
        frozenAccounts[_acc] = _isfrozen;
        emit NewFreeze(_acc, _isfrozen);
        return true;
    }

    
    function setBountyTeamUnfreezeTime(uint256 _newDate) external onlyOwner {
       UNFREEZE_TEAM_BOUNTY = _newDate;
    }

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

   
  function multiTransfer(address[] _investors, uint256[] _value )  
      public 
      onlyTokenKeeper 
      returns (uint256 _batchAmount)
  {
      uint8      cnt = uint8(_investors.length);
      uint256 amount = 0;
      require(cnt >0 && cnt <=255);
      require(_value.length == _investors.length);
      for (uint i=0; i<cnt; i++){
        amount = amount.add(_value[i]);
        require(_investors[i] != address(0));
        balances[_investors[i]] = balances[_investors[i]].add(_value[i]);
        emit Transfer(msg.sender, _investors[i], _value[i]);
      }
      require(amount <= balances[msg.sender]);
      balances[msg.sender] = balances[msg.sender].sub(amount);
      emit BatchDistrib(cnt, amount);
      return amount;
  }

     
    function transfer(address _to, uint256 _value) public  returns (bool) {
      require(!isFrozen(msg.sender));
      assert(msg.data.length >= 64 + 4); 
       
       
      if (msg.sender == accForBounty || msg.sender == accForTeam) {
          frozenAccounts[_to] = true;
          emit NewFreeze(_to, true);
      }
      return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool) {
      require(!isFrozen(_from));
      assert(msg.data.length >= 96 + 4);  
       if (_from == accForBounty || _from == accForTeam) {
          frozenAccounts[_to] = true;
          emit NewFreeze(_to, true);
      }
      return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public  returns (bool) {
      require(!isFrozen(msg.sender));
      return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public  returns (bool success) {
      require(!isFrozen(msg.sender));
      return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public  returns (bool success) {
      require(!isFrozen(msg.sender));
      return super.decreaseApproval(_spender, _subtractedValue);
    }

        
    
   
   
   
   
   
   
   

}