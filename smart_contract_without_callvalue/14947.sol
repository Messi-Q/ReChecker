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

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
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

contract DeepCloudToken is StandardToken {  
  using SafeMath for uint;

  string public constant symbol = "DEEP";
  string public constant name = "DeepCloud";

  uint8 public constant decimals = 18;
  
  address public tokenHolder = 0x8f9294A3187942B40d805962058b81974bC77146;

  constructor () public {
     
    totalSupply_ = 200000000 ether;
    emit Transfer(address(this), tokenHolder, totalSupply_);
    
    balances[0xAFa6552fde8eaa29f8941A4578ac95a64de4A1f9] = 40000000 ether;
    emit Transfer(tokenHolder, 0xAFa6552fde8eaa29f8941A4578ac95a64de4A1f9, 40000000 ether);

    balances[0xFAeE73F6aBC8f67d5e03E0eC7D2fAb893c72E869] = 30000000 ether;
    emit Transfer(tokenHolder, 0xFAeE73F6aBC8f67d5e03E0eC7D2fAb893c72E869, 30000000 ether);

    balances[0x98dF271112907A9c812F9B0a2335bd23565BF8f6] = 24000000 ether;
    emit Transfer(tokenHolder, 0x98dF271112907A9c812F9B0a2335bd23565BF8f6, 24000000 ether);
    
    balances[0xf34Ef789204C990E4eC296aD6AF2FA3205747523] = 16000000 ether;
    emit Transfer(tokenHolder, 0xf34Ef789204C990E4eC296aD6AF2FA3205747523, 16000000 ether);

    balances[0x5288f8627137D3B0d0454A7bBA08692e0fBC7BB7] = 10000000 ether;
    emit Transfer(tokenHolder, 0x5288f8627137D3B0d0454A7bBA08692e0fBC7BB7, 10000000 ether);

    balances[tokenHolder] = 80000000 ether;
  }

  event Burn(address indexed burner, uint256 value);

  function burn(uint _value) public {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);

    emit Burn(msg.sender, _value);
    emit Transfer(msg.sender, address(0), _value);
  }
}