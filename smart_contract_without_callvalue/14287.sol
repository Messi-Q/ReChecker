pragma solidity 0.4.23;

 


 
contract AbstractToken {
	function balanceOf(address owner) public view returns (uint256 balance);
	function transfer(address to, uint256 value) public returns (bool success);
	function transferFrom(address from, address to, uint256 value) public returns (bool success);
	function approve(address spender, uint256 value) public returns (bool success);
	function allowance(address owner, address spender) public view returns (uint256 remaining);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

 
 
contract SafeMath {
	 
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

	 
	function pow(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a ** b;
		assert(c >= a);
		return c;
	}
}

 
contract StandardToken is AbstractToken, Owned, SafeMath {

	 
	mapping (address => uint256) internal balances;
	mapping (address => mapping (address => uint256)) internal allowed;

	 
	 
	 
	 
	function transfer(address _to, uint256 _value) public returns (bool success) {
		return _transfer(msg.sender, _to, _value);
	}

	 
	 
	 
	 
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(allowed[_from][msg.sender] >= _value);
		allowed[_from][msg.sender] -= _value;

		return _transfer(_from, _to, _value);
	}

	 
	 
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}

	 
	 
	 
	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	 
	 
	 
	 
	function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}

	 
	function _transfer(address _from, address _to, uint256 _value) private returns (bool success) {
		require(_to != address(0));
		require(balances[_from] >= _value);
		balances[_from] -= _value;
		balances[_to] = add(balances[_to], _value);
		emit Transfer(_from, _to, _value);
		return true;
	}
}

 
contract eMangirToken is StandardToken {

	 
	uint256 public creationTime;
    
	string constant public name = 'eMangir';
	string constant public symbol = 'EMG';
	uint8  public decimals = 18;
	uint256 public totalSupply = 1000000000e18;

	constructor() public {
		 
		creationTime = now;
		balances[msg.sender] = totalSupply;
	}

	 
	function transferERC20Token(AbstractToken _token, address _to, uint256 _value)
		public
		onlyOwner
		returns (bool success)
	{
		require(_token.balanceOf(address(this)) >= _value);
		uint256 receiverBalance = _token.balanceOf(_to);
		require(_token.transfer(_to, _value));

		uint256 receiverNewBalance = _token.balanceOf(_to);
		assert(receiverNewBalance == add(receiverBalance, _value));

		return true;
	}

	 
	function increaseApproval(address _spender, uint256 _value) public returns (bool success) {
		allowed[msg.sender][_spender] = add(allowed[msg.sender][_spender], _value);
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

	 
	function decreaseApproval(address _spender, uint256 _value) public returns (bool success) {
		uint256 oldValue = allowed[msg.sender][_spender];
		if (_value > oldValue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = sub(oldValue, _value);
		}
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

}