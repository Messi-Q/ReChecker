pragma solidity ^0.4.21;
 

  
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
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

 
contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;

   
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

 
 
 
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

   
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
     
     

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
    Transfer(burner, address(0), _value);
  }
} 
 
contract StandardToken is ERC20, BurnableToken {

  mapping (address => mapping (address => uint256)) allowed;

   
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

     
     

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) returns (bool) {

     
     
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

 
contract Ownable {
    
  address public owner;

   
  function Ownable() {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
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

   
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  
}

contract SUCoin is MintableToken {
    
    string public constant name = "SU Coin";
    
    string public constant symbol = "SUCoin";
    
    uint32 public constant decimals = 18;
    
}


contract SUTokenContract is Ownable  {
    using SafeMath for uint;
    
    event doiVerificationEvent(bytes32 _doiHash, bytes32 _hash);
    
    SUCoin public token = new SUCoin();
    bool ifInit = true; 
    uint public tokenDec = 1000000000000000000;  
    address manager;
    
    
    mapping (address => mapping (uint => bool)) idMap;
    mapping(bytes32 => bool) hashMap;
    mapping (uint => uint) mintInPeriod;
    uint public mintLimit = tokenDec.mul(10000);
    uint public period = 30 * 1 days;  
    uint public startTime = now;
    
    
    function SUTokenContract(){
        owner = msg.sender;
        manager = msg.sender;
        token = SUCoin(0x64734D2FEDCD1A208375b5Ea6dC14F4482b47D52);
    }
    
    function initMinting() onlyOwner returns (bool) {
        require(!ifInit);
        require(token.mint(address(this), tokenDec.mul(50000)));
        ifInit = true;
        return true;
    } 
    

    function transferTokenOwnership(address _newOwner) onlyOwner {   
        token.transferOwnership(_newOwner);
    }
    
    function mint(address _to, uint _value) onlyOwner {
        uint currPeriod = now.sub(startTime).div(period);
        require(mintLimit>= _value.add(mintInPeriod[currPeriod]));
        require(token.mint(_to, _value));
        mintInPeriod[currPeriod] = mintInPeriod[currPeriod].add(_value);
    }
    
    function burn(uint256 _value) onlyOwner {
        token.burn(_value);
    }
    
    function tokenTotalSupply() constant returns (uint256) {
        return token.totalSupply();
    }
      
    function tokenContractBalance() constant returns (uint256) {
        return token.balanceOf(address(this));
    }   
    
    function tokentBalance(address _address) constant returns (uint256) {
        return token.balanceOf(_address);
    }     
    
    
    function transferToken(address _to, uint _value) onlyOwner returns (bool) {
        return token.transfer(_to,  _value);
    }    
    
    function allowance( address _spender) constant returns (uint256 remaining) {
        return token.allowance(address(this),_spender);
    }
    
    function allowanceAdd( address _spender, uint _value ) onlyOwner  returns (bool) {
        uint currAllowance = allowance( _spender);
        require(token.approve( _spender, 0));
        require(token.approve( _spender, currAllowance.add(_value)));
        return true;
    } 
    
    function allowanceSub( address _spender, uint _value ) onlyOwner  returns (bool) {
        uint currAllowance = allowance( _spender);
        require(currAllowance>=_value);
        require(token.approve( _spender, 0));
        require(token.approve( _spender, currAllowance.sub(_value)));
        return true;
    }
    
    function allowanceSubId( address _spender, uint _value,   uint _id) onlyOwner  returns (bool) {
        uint currAllowance = allowance( _spender);
        require(currAllowance>=_value);
        require(token.approve( _spender, 0));
        require(token.approve( _spender, currAllowance.sub(_value)));
        idMap[_spender][_id] = true;
        return true;
    }    

  function storeId(address _address, uint _id) onlyOwner {
    idMap[_address][_id] = true;
  } 
  
  function storeHash(bytes32 _hash) onlyOwner {
    hashMap[_hash] = true;
  } 
  
  function storeDoi(bytes32 _doiHash, bytes32 _hash) onlyOwner {
    doiVerificationEvent( _doiHash, _hash);
    storeHash(_hash);
  }  
     
    
  function idVerification(address _address, uint _id) constant returns (bool) {
    return idMap[_address][_id];
  } 
  
  function hashVerification(bytes32 _hash) constant returns (bool) {
    return hashMap[_hash];
  } 
  
  function mintInPeriodCount(uint _period) constant returns (uint) {
    return mintInPeriod[_period];
  }   
  
  function mintInCurrPeriodCount() constant returns (uint) {
    uint currPeriod = now.sub(startTime).div(period);
    return mintInPeriod[currPeriod];
  }
  

}