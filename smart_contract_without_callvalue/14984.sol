pragma solidity 0.4.21;

 
 
 

 
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

 
contract SafeApprove is StandardBurnableToken {

    
  function approve(address _spender, uint256 _value) public  returns (bool) {
     
     
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    return super.approve(_spender, _value);
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

 
contract AdvancedOwnable is Ownable {

  address public saleAgent;
  address internal managerAgent;

   
  function AdvancedOwnable() public {
    saleAgent=owner;
    managerAgent=owner;
  }
  modifier onlyOwnerOrManagerAgent {
    require(owner == msg.sender || managerAgent == msg.sender);
    _;
  }
  modifier onlyOwnerOrSaleAgent {
    require(owner == msg.sender || saleAgent == msg.sender);
    _;
  }
  function setSaleAgent(address newSaleAgent) public onlyOwner {
    require(newSaleAgent != address(0));
    saleAgent = newSaleAgent;
  }
  function setManagerAgent(address newManagerAgent) public onlyOwner {
    require(newManagerAgent != address(0));
    managerAgent = newManagerAgent;
  }

}

 
contract BlackList is AdvancedOwnable {

    mapping (address => bool) internal blacklist;
    event BlacklistedAddressAdded(address indexed _address);
    event BlacklistedAddressRemoved(address indexed _address);

    
   modifier notInBlackList() {
     require(!blacklist[msg.sender]);
     _;
   }

    
   modifier onlyIfNotInBlackList(address _address) {
     require(!blacklist[_address]);
     _;
   }
    
   modifier onlyIfInBlackList(address _address) {
     require(blacklist[_address]);
     _;
   }
  
   function addAddressToBlacklist(address _address) public onlyOwnerOrManagerAgent onlyIfNotInBlackList(_address) returns(bool) {
     blacklist[_address] = true;
     emit BlacklistedAddressAdded(_address);
     return true;
   }
  
  function removeAddressFromBlacklist(address _address) public onlyOwnerOrManagerAgent onlyIfInBlackList(_address) returns(bool) {
    blacklist[_address] = false;
    emit BlacklistedAddressRemoved(_address);
    return true;
  }
}

 
contract BlackListToken is BlackList,SafeApprove {

  function transfer(address _to, uint256 _value) public notInBlackList returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public notInBlackList returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public notInBlackList returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public notInBlackList returns (bool) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public notInBlackList returns (bool) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }

  function burn(uint256 _value) public notInBlackList {
   super.burn( _value);
  }

  function burnFrom(address _from, uint256 _value) public notInBlackList {
   super.burnFrom( _from, _value);
  }

}

 
contract Pausable is AdvancedOwnable {
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

   
   modifier onlyWhenNotPaused() {
     if(owner != msg.sender && saleAgent != msg.sender) {
       require (!paused);
     }
    _;
   }

   
  function pause() onlyOwnerOrSaleAgent whenNotPaused public {
    paused = true;
    emit Pause();
  }

   
  function unpause() onlyOwnerOrSaleAgent whenPaused public {
    paused = false;
    emit Unpause();
  }
}

 
contract PausableToken is Pausable,BlackListToken {

  function transfer(address _to, uint256 _value) public onlyWhenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public onlyWhenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public onlyWhenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public onlyWhenNotPaused returns (bool) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public onlyWhenNotPaused returns (bool) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }

  function burn(uint256 _value) public onlyWhenNotPaused {
   super.burn( _value);
  }

  function burnFrom(address _from, uint256 _value) public onlyWhenNotPaused {
   super.burnFrom( _from, _value);
  }

}

 
contract SafeCheckToken is PausableToken {


    function transfer(address _to, uint256 _value) public returns (bool) {
       
      require(_to != address(this));
       
      require(msg.data.length >= 68);
       
      require(_value != 0);

      return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
       
      require(_to != address(this));
       
      require(msg.data.length >= 68);
       
      require(_from != address(0));
       
      require(_value != 0);

      return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
       
      require(msg.data.length >= 68);
      return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
       
      require(msg.data.length >= 68);
      return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
       
      require(msg.data.length >= 68);
      return super.decreaseApproval(_spender, _subtractedValue);
    }

    function burn(uint256 _value) public {
       
      require(_value != 0);
      super.burn( _value);
    }

    function burnFrom(address _from, uint256 _value) public {
       
      require(msg.data.length >= 68);
       
      require(_value != 0);
      super.burnFrom( _from, _value);
    }

}

 
interface accidentallyERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
}

 
contract AccidentallyTokens is Ownable {

    function transferAnyERC20Token(address tokenAddress,address _to, uint _value) public onlyOwner returns (bool) {
      require(_to != address(this));
      require(tokenAddress != address(0));
      require(_to != address(0));
      return accidentallyERC20(tokenAddress).transfer(_to,_value);
    }
}

 
contract MainToken is SafeCheckToken,AccidentallyTokens {

  address public TokenWalletHolder;

  string public constant name = "EQI Token";
  string public constant symbol = "EQI";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 880000000 * (10 ** uint256(decimals));

   
  function MainToken(address _TokenWalletHolder) public {
    require(_TokenWalletHolder != address(0));
    TokenWalletHolder = _TokenWalletHolder;
    totalSupply_ = INITIAL_SUPPLY;
    balances[TokenWalletHolder] = INITIAL_SUPPLY;
    emit Transfer(address(this), msg.sender, INITIAL_SUPPLY);
  }

   
  function () public payable {
    revert();
  }

}