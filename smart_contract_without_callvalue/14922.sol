pragma solidity ^0.4.13;

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
    Transfer(msg.sender, _to, _value);
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
    Transfer(_from, _to, _value);
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

contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract VideoTrusted is
    Ownable
  {

   
  address[] public trustedContracts;

   
   
  event TrustedContractAdded(address newTrustedContract);

   
   
  event TrustedContractRemoved(address oldTrustedContract);

   
   
  modifier onlyTrustedContracts() {
    require(msg.sender == owner ||
            findTrustedContract(msg.sender) >= 0);
    _;
  }

   
   
  function findTrustedContract(address _address) public view returns (int) {
    for (uint i = 0; i < trustedContracts.length; i++) {
      if (_address == trustedContracts[i]) {
        return int(i);
      }
    }
    return -1;
  }

   
   
   
  function addTrustedContract(address _newTrustedContract) public onlyOwner {
    require(findTrustedContract(_newTrustedContract) < 0);
    trustedContracts.push(_newTrustedContract);
    TrustedContractAdded(_newTrustedContract);
  }

   
   
   
  function removeTrustedContract(address _oldTrustedContract) public onlyOwner {
    int i = findTrustedContract(_oldTrustedContract);
    require(i >= 0);
    delete trustedContracts[uint(i)];
    TrustedContractAdded(_oldTrustedContract);
  }

   
  function getTrustedContracts() external view onlyTrustedContracts returns (address[]) {
    return trustedContracts;
  }

}

contract BitVideoCoin is DetailedERC20, StandardToken, VideoTrusted {

  using SafeMath for uint256;

   
  function BitVideoCoin() DetailedERC20('BitVideo Coin', 'BTVC', 6) public {
    totalSupply_ = 100000000;
    balances[msg.sender] = totalSupply_;
  }

   
  event Mint(address indexed to, uint256 amount);

   
  function mintTrusted(address _to, uint256 _amount)
      public
      onlyTrustedContracts
      returns (bool) {
     
    require(msg.sender != owner);
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

   
  event Burn(address indexed burner, uint256 value);

   
  function burnTrusted(address _who, uint256 _value) public onlyTrustedContracts {
    require(_value <= balances[_who]);
     
    require(msg.sender != owner);
     
     

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(_who, _value);
    Transfer(_who, address(0), _value);
  }

}