pragma solidity ^0.4.23;

 
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

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}


 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

   
  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }

   
  function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }

   
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value);
  function approve(address spender, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint256)) allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) {
    var _allowance = allowed[_from][msg.sender];

     
     

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }

   
  function approve(address _spender, uint256 _value) {

     
     
     
     
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
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
    if (msg.sender != owner) {
      throw;
    }
    _;
  }


   
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


 

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 value);
  event MintFinished();

  bool public mintingFinished = false;
  uint256 public totalSupply = 0;


  modifier canMint() {
    if(mintingFinished) throw;
    _;
  }

   
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract TimeLockToken is Ownable, MintableToken{
  using SafeMath for uint256;
  struct LockedBalance {  
    uint256 releaseTime; 
    uint256 amount;
  }

  event MintLock(address indexed to, uint256 releaseTime, uint256 value);
  mapping(address => LockedBalance) lockedBalances;
   
  function mintTimelocked(address _to, uint256 _releaseTime, uint256 _amount)
    onlyOwner canMint returns (bool){
    require(_releaseTime > now);
    require(_amount > 0);
    LockedBalance exist = lockedBalances[_to];
    require(exist.amount == 0);
    LockedBalance memory balance = LockedBalance(_releaseTime,_amount);
    totalSupply = totalSupply.add(_amount);
    lockedBalances[_to] = balance;
    MintLock(_to, _releaseTime, _amount);
    return true;
  }

   
  function claim() {
    LockedBalance balance = lockedBalances[msg.sender];
    require(balance.amount > 0);
    require(now >= balance.releaseTime);
    uint256 amount = balance.amount;
    delete lockedBalances[msg.sender];
    balances[msg.sender] = balances[msg.sender].add(amount);
    Transfer(0, msg.sender, amount);
  }

   
  function lockedBalanceOf(address _owner) constant returns (uint256 lockedAmount) {
    return lockedBalances[_owner].amount;
  }

   
  function releaseTimeOf(address _owner) constant returns (uint256 releaseTime) {
    return lockedBalances[_owner].releaseTime;
  }
  
}


 
contract BMBToken is TimeLockToken {
  using SafeMath for uint256;
  event Freeze(address indexed to, uint256 value);
  event Unfreeze(address indexed to, uint256 value);
  event Burn(address indexed to, uint256 value);
  mapping (address => uint256) public freezeOf;
  string public name = "BitmoreToken";
  string public symbol = "BMB";
  uint public decimals = 8;


  function burn(address _to,uint256 _value) onlyOwner returns (bool success) {
    require(_value >= 0);
    require(balances[_to] >= _value);
    
    balances[_to] = balances[_to].sub(_value);                       
    totalSupply = totalSupply.sub(_value);                                 
    Burn(_to, _value);
    return true;
  }
  
  function freeze(address _to,uint256 _value) onlyOwner returns (bool success) {
    require(_value >= 0);
    require(balances[_to] >= _value);
    balances[_to] = balances[_to].sub(_value);                       
    freezeOf[_to] = freezeOf[_to].add(_value);                                 
    Freeze(_to, _value);
    return true;
  }
  
  function unfreeze(address _to,uint256 _value) onlyOwner returns (bool success) {
    require(_value >= 0);
    require(freezeOf[_to] >= _value);
    freezeOf[_to] = freezeOf[_to].sub(_value);                       
    balances[_to] = balances[_to].add(_value);
    Unfreeze(_to, _value);
    return true;
  }

}