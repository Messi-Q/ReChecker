pragma solidity ^0.4.22;

 

 
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
     
     
     
    return a / b;
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

 
contract Ownable {

  address public owner;

  address public newOwner;

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  constructor() public {
    owner = msg.sender;
  }

   
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
  
  event OwnershipTransferred(address oldOwner, address newOwner);
}

contract FUNToken is Ownable {  
  using SafeMath for uint;
   
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

   
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  string public constant symbol = "FUN";  
  string public constant name = "THEFORTUNEFUND";  
  uint8 public constant decimals = 18;  
   
  uint256 _totalSupply = 88888888 ether;

   
  mapping(address => uint256) balances;

   
  mapping(address => mapping (address => uint256)) allowed;

   
  function totalSupply() public view returns (uint256) {  
    return _totalSupply;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) { 
    return balances[_owner];
  }
  
   
  bool public locked = false;

   
  bool public canChangeLocked = true;

   
  function changeLockTransfer (bool _request) public onlyOwner {
    require(canChangeLocked);
    locked = _request;
  }

   
  function finalUnlockTransfer () public {
    require (canChangeLocked);
  
    locked = false;
    canChangeLocked = false;
  }
  
   
  function transfer(address _to, uint256 _amount) public returns (bool success) {
    require(this != _to);
    require (_to != address(0));
    require(!locked);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Transfer(msg.sender,_to,_amount);
    return true;
  }

   
  function transferFrom(address _from, address _to, uint256 _amount) public returns(bool success){
    require(this != _to);
    require (_to != address(0));
    require(!locked);
    balances[_from] = balances[_from].sub(_amount);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Transfer(_from,_to,_amount);
    return true;
  }
  
   
  function approve(address _spender, uint256 _amount)public returns (bool success) { 
    allowed[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

   
  function allowance(address _owner, address _spender)public view returns (uint256 remaining) {
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

   
  constructor () public {
    owner = 0x85BC7DC54c637Dd432e90B91FE803AaA7744E158;
    tokenHolder = 0x85BC7DC54c637Dd432e90B91FE803AaA7744E158;
    balances[tokenHolder] = _totalSupply;
  }

   
  address public tokenHolder;

   
  address public crowdsaleContract;

   
  function setCrowdsaleContract (address _address) public{
    require(crowdsaleContract == address(0));

    crowdsaleContract = _address;
  }

   
  uint public crowdsaleBalance = 77333333 ether;  
  
   
  function sendCrowdsaleTokens (address _address, uint _value) public {
    require(msg.sender == crowdsaleContract);

    balances[tokenHolder] = balances[tokenHolder].sub(_value);
    balances[_address] = balances[_address].add(_value);
    
    crowdsaleBalance = crowdsaleBalance.sub(_value);
    
    emit Transfer(tokenHolder,_address,_value);    
  }

   
  event Burn(address indexed burner, uint tokens);

   
  function burnTokens (uint _value) external {
    balances[msg.sender] = balances[msg.sender].sub(_value);

    _totalSupply = _totalSupply.sub(_value);

    emit Transfer(msg.sender, 0, _value);
    emit Burn(msg.sender, _value);
  } 
}