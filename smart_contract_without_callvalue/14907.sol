pragma solidity 0.4.23;

 
 
 
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





 
contract Ownable {
  address public owner;
  address public newOwnerTemp;

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
    newOwnerTemp = newOwner;
  }
  
  function acceptOwnership() public {
        require(msg.sender == newOwnerTemp);
        emit OwnershipTransferred(owner, newOwnerTemp);
        owner = newOwnerTemp;
        newOwnerTemp = address(0x0);
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

   
  function balanceOf(address _owner) public view returns (uint256) {
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

 
 
 
 
contract HeliosToken is StandardToken, Ownable {
	 
    string  public constant name = "Helios Token";
    string  public constant symbol = "HLS";
    uint8   public constant decimals = 18;
	
	uint256 public constant INITIAL_SUPPLY = 300000000 * (10 ** uint256(decimals));
	uint256 public constant YEAR_TWO_SUPPLY = 30000000 * (10 ** uint256(decimals));
	uint256 public constant YEAR_THREE_SUPPLY = 20000000 * (10 ** uint256(decimals));
	
	bool public yearTwoClaimed;
	bool public yearThreeClaimed;
	
	 
	uint256 public startTime = 1519862400;


     
     
     
    constructor() public {
        yearTwoClaimed = false;
		yearThreeClaimed = false;
		
        totalSupply_ = INITIAL_SUPPLY + YEAR_TWO_SUPPLY + YEAR_THREE_SUPPLY;
        
		 
		balances[owner] = INITIAL_SUPPLY;
		emit Transfer(0x0, owner, INITIAL_SUPPLY);
		
    }

	 
     
     
	function teamClaim(uint256 year) public onlyOwner returns (bool success) {
		if(year == 2)
		{
			require (block.timestamp > (startTime + 31536000)  && yearTwoClaimed == false);
			balances[owner] = balances[owner].add(YEAR_TWO_SUPPLY);
			emit Transfer(0x0, owner, YEAR_TWO_SUPPLY);
			yearTwoClaimed = true;
		}
		if(year == 3)
		{
			require (block.timestamp > (startTime + 63072000) && yearThreeClaimed == false);
			balances[owner] = balances[owner].add(YEAR_THREE_SUPPLY);
			emit Transfer(0x0, owner, YEAR_THREE_SUPPLY);
			yearThreeClaimed = true;
		}
		return true;
	}
	

     
    function() public{
        revert();
    }

}