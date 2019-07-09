pragma solidity ^0.4.18;

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

contract CloverCoin {
  using SafeMath for uint256;

  string public name = "CloverCoin";
  string public symbol = "CVC";
  uint public decimals = 18;
  uint256 public totalSupply;
  uint256 public commission;
  uint256 public denominator;
  address public cvcOwner;
  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;
  
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function CloverCoin(address _cvcOwner) public {
    totalSupply = 10000000000e18;

     
    commission = 5;  
    denominator = 1000;  
    
    cvcOwner = _cvcOwner;
    balances[_cvcOwner] = totalSupply;  
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value.sub(_value.mul(commission).div(denominator)));
    balances[cvcOwner] = balances[cvcOwner].add(_value.mul(commission).div(denominator));
    Transfer(msg.sender, _to, _value.sub(_value.mul(commission).div(denominator)));
    Transfer(msg.sender, cvcOwner, _value.mul(commission).div(denominator));
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value.sub(_value.mul(commission).div(denominator)));
    balances[cvcOwner] = balances[cvcOwner].add(_value.mul(commission).div(denominator));
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value.sub(_value.mul(commission).div(denominator)));
    Transfer(_from, cvcOwner, _value.mul(commission).div(denominator));
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