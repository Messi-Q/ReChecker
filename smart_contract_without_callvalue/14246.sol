pragma solidity ^0.4.24;

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) 
  {
    if (a == 0 || b == 0) 
    {
      return 0;
    }
    c = a * b;
    require(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) 
  {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    require(c >= a && c >=b);
    return c;
  }
}

 
contract LSHContract {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);

}

contract LSHToken is LSHContract{

  using SafeMath for uint256;
  address public  owner;
  uint256 private totalSupply_;
  bool    public  mintingFinished = false;
  
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);
  event Burn(address indexed burner, uint256 value);
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;
  modifier canMint() {require(!mintingFinished);_;}
  modifier hasMintPermission() { require(msg.sender == owner); _;}
  modifier onlyOwner() { require(msg.sender == owner);_;}

  constructor() public {owner = msg.sender;}

   
  function transferOwnership(address newOwner) public onlyOwner 
  {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

   
  function renounceOwnership() public onlyOwner 
  {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

   
  function totalSupply() public view returns (uint256) 
  {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) 
  {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256) 
  {
    return balances[_owner];
  }
  
   
  function transferFrom(address _from,address _to,uint256 _value) public returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) 
  {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner,address _spender) public view returns (uint256)
  {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender,uint _addedValue) public returns (bool)
  {
    allowed[msg.sender][_spender] = (
    allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender,uint _subtractedValue) public returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function burn(uint256 _value) public 
  {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal 
  {
    require(_value <= balances[_who]);
     
     

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }

  
  function burnFrom(address _from, uint256 _value) public 
  {
    require(_value <= allowed[_from][msg.sender]);
     
     
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _burn(_from, _value);
  }

   
  function mint(address _to,uint256 _amount) hasMintPermission canMint public returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner canMint public returns (bool) 
  {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }

}

contract LSHCoin is LSHToken {
    string public symbol = "LSH";
    string public  name = "LSH COIN";
    uint8 public decimals = 8;
}