pragma solidity ^0.4.21;

 
library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
     
    uint c = a / b;
    assert(a == b * c + a % b);  
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

}


 
contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant public returns (uint);
  function transfer(address to, uint value) public;
  event Transfer(address indexed from, address indexed to, uint value);
}


 
contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

   
  modifier onlyPayloadSize(uint size) {
     assert(msg.data.length >= size + 4);
      
      
      
     _;
  }

   
  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32)  public {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
  }

   
  function balanceOf(address _owner) constant public returns (uint balance) {
    return balances[_owner];
  }

}


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant  public returns (uint);
  function transferFrom(address from, address to, uint value)  public;
  function approve(address spender, uint value)  public;
  event Approval(address indexed owner, address indexed spender, uint value);
}


 
contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;


   
  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32)  public {
    uint _allowance;
    _allowance = allowed[_from][msg.sender];

     
     
    require(_allowance >= _value);

    allowed[_from][msg.sender] = _allowance.sub(_value);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(_from, _to, _value);
  }

   
  function approve(address _spender, uint _value)  public {

     
     
     
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
  }

   
  function allowance(address _owner, address _spender) constant public returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}


 
contract Ownable {
  address public owner;


   
  constructor()  public {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) onlyOwner  public {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


 

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint value);
  event MintFinished();

  bool public mintingFinished = false;
  uint public totalSupply = 0;


  modifier canMint() {
     
    require(!mintingFinished);
    _;
  }

   
  function mint(address _to, uint _amount) onlyOwner canMint  public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner  public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
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

   
  modifier whenPaused {
     
    require(paused);
    _;
  }

   
  function pause() onlyOwner whenNotPaused  public returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

   
  function unpause() onlyOwner whenPaused  public returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}


 

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint _value) whenNotPaused  public {
    super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) whenNotPaused  public {
    super.transferFrom(_from, _to, _value);
  }
}


 
contract TokenTimelock {

   
  ERC20Basic token;

   
  address public beneficiary;

   
  uint public releaseTime;

  constructor(ERC20Basic _token, address _beneficiary, uint _releaseTime)  public {
    require(_releaseTime > now);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

   
  function claim()  public {
    require(msg.sender == beneficiary);
    require(now >= releaseTime);

    uint amount = token.balanceOf(this);
    require(amount > 0);

    token.transfer(beneficiary, amount);
  }
}


 
contract FactsToken is PausableToken, MintableToken {
  using SafeMath for uint256;

  string public name = "F4Token";
  string public symbol = "FFFF";
  uint public decimals = 18;

   
  function mintTimelocked(address _to, uint256 _amount, uint256 _releaseTime) public
    onlyOwner canMint returns (TokenTimelock) {

    TokenTimelock timelock = new TokenTimelock(this, _to, _releaseTime);
    mint(timelock, _amount);

    return timelock;
  }

  mapping (address => string) public  keys;
  event LogRegister (address user, string key);
   
   
   
  function register(string key) public {
      assert(bytes(key).length <= 64);
      keys[msg.sender] = key;
      emit LogRegister(msg.sender, key);
    }
}