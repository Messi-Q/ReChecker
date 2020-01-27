pragma solidity ^ 0.4.17;

 

 
 
 
library SafeMath {
	function mul(uint256 a, uint256 b) internal constant returns(uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal constant returns(uint256) {
		 
		uint256 c = a / b;
		 
		return c;
	}

	function sub(uint256 a, uint256 b) internal constant returns(uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal constant returns(uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

 
 
contract ERC20Interface {
	function totalSupply() public constant returns(uint256 totalSupplyReturn);

	function balanceOf(address _owner) public constant returns(uint256 balance);

	function transfer(address _to, uint256 _value) public returns(bool success);

	function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);

	function approve(address _spender, uint256 _value) public returns(bool success);

	function allowance(address _owner, address _spender) public constant returns(uint256 remaining);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract Noxon is ERC20Interface {
	using SafeMath for uint;

	string public constant symbol = "NOXON";
	string public constant name = "NOXON";
	uint8 public constant decimals = 0;  
	uint256 _totalSupply = 0;
	uint256 _burnPrice;
	uint256 _emissionPrice;
	uint256 initialized;
	
	bool public emissionlocked = false;
	 
	address public owner;
	address public manager;

	 
	mapping(address => uint256) balances;

	 
	mapping(address => mapping(address => uint256)) allowed;

	 
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	address newOwner;
	address newManager;
	 
	function changeOwner(address _newOwner) public onlyOwner {
		newOwner = _newOwner;
	}

	 
	function acceptOwnership() public {
		if (msg.sender == newOwner) {
			owner = newOwner;
			newOwner = address(0);
		}
	}


	function changeManager(address _newManager) public onlyOwner {
		newManager = _newManager;
	}


	function acceptManagership() public {
		if (msg.sender == newManager) {
			manager = newManager;
            newManager = address(0);
		}
	}

	 
	
	function Noxon() public {
        require(_totalSupply == 0);
		owner = msg.sender;
		manager = owner;
        
	}
	function NoxonInit() public payable onlyOwner returns (bool) {
		require(_totalSupply == 0);
		require(initialized == 0);
		require(msg.value > 0);
		Transfer(0, msg.sender, 1);
		balances[owner] = 1;  
		_totalSupply = balances[owner];
		_burnPrice = msg.value;
		_emissionPrice = _burnPrice.mul(2);
		initialized = block.timestamp;
		return true;
	}

	 
	function lockEmission() public onlyOwner {
		emissionlocked = true;
	}

	function unlockEmission() public onlyOwner {
		emissionlocked = false;
	}

	function totalSupply() public constant returns(uint256) {
		return _totalSupply;
	}

	function burnPrice() public constant returns(uint256) {
		return _burnPrice;
	}

	function emissionPrice() public constant returns(uint256) {
		return _emissionPrice;
	}

	 
	function balanceOf(address _owner) public constant returns(uint256 balance) {
		return balances[_owner];
	}

	 
	function transfer(address _to, uint256 _amount) public returns(bool success) {

		 
		if (_to == address(this)) {
			return burnTokens(_amount);
		} else {

			if (balances[msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
				balances[msg.sender] = balances[msg.sender].sub(_amount);
				balances[_to] = balances[_to].add(_amount);
				Transfer(msg.sender, _to, _amount);
				return true;
			} else {
				return false;
			}

		}
	}

	function burnTokens(uint256 _amount) private returns(bool success) {

		_burnPrice = getBurnPrice();
		uint256 _burnPriceTmp = _burnPrice;

		if (balances[msg.sender] >= _amount && _amount > 0) {

			 
			balances[msg.sender] = balances[msg.sender].sub(_amount);
			_totalSupply = _totalSupply.sub(_amount);

			 
			assert(_totalSupply >= 1);

			 
			msg.sender.transfer(_amount.mul(_burnPrice));

			 
			_burnPrice = getBurnPrice();

			 
			assert(_burnPrice >= _burnPriceTmp);

			 
			TokenBurned(msg.sender, _amount.mul(_burnPrice), _burnPrice, _amount);
			return true;
		} else {
			return false;
		}
	}

	event TokenBought(address indexed buyer, uint256 ethers, uint _emissionedPrice, uint amountOfTokens);
	event TokenBurned(address indexed buyer, uint256 ethers, uint _burnedPrice, uint amountOfTokens);

	function () public payable {
	     

		 
		 
		uint256 _burnPriceTmp = _burnPrice;

		require(emissionlocked == false);
		require(_burnPrice > 0 && _emissionPrice > _burnPrice);
		require(msg.value > 0);

		 
		uint256 amount = msg.value / _emissionPrice;

		 
		require(balances[msg.sender] + amount > balances[msg.sender]);

		 
		balances[msg.sender] = balances[msg.sender].add(amount);
		_totalSupply = _totalSupply.add(amount);

        uint mg = msg.value / 2;
		 
		manager.transfer(mg);
		TokenBought(msg.sender, msg.value, _emissionPrice, amount);

		 
		_burnPrice = getBurnPrice();
		_emissionPrice = _burnPrice.mul(2);

		 
		assert(_burnPrice >= _burnPriceTmp);
	}
    
	function getBurnPrice() public returns(uint) {
		return this.balance / _totalSupply;
	}

	event EtherReserved(uint etherReserved);
	 

	function addToReserve() public payable returns(bool) {
	    uint256 _burnPriceTmp = _burnPrice;
		if (msg.value > 0) {
			_burnPrice = getBurnPrice();
			_emissionPrice = _burnPrice.mul(2);
			EtherReserved(msg.value);
			
			 
		    assert(_burnPrice >= _burnPriceTmp);
			return true;
		} else {
			return false;
		}
	}

	 
	 
	 
	 
	 
	 
	function transferFrom(
		address _from,
		address _to,
		uint256 _amount
	) public returns(bool success) {
		if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to] && _to != address(this)  
		) {
			balances[_from] = balances[_from].sub(_amount);
			allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
			balances[_to] = balances[_to].add(_amount);
			Transfer(_from, _to, _amount);
			return true;
		} else {
			return false;
		}
	}

	 
	 
	function approve(address _spender, uint256 _amount) public returns(bool success) {
		allowed[msg.sender][_spender] = _amount;
		Approval(msg.sender, _spender, _amount);
		return true;
	}

	function allowance(address _owner, address _spender) public constant returns(uint256 remaining) {
		return allowed[_owner][_spender];
	}

	function transferAnyERC20Token(address tokenAddress, uint amount)
	public
	onlyOwner returns(bool success) {
		return ERC20Interface(tokenAddress).transfer(owner, amount);
	}

	function burnAll() external returns(bool) {
		return burnTokens(balances[msg.sender]);
	}
    
    
}

contract TestProcess {
    Noxon main;
    
    function TestProcess() payable {
        main = new Noxon();
    }
   
    function () payable {
        
    }
     
    function init() returns (uint) {
       
        if (!main.NoxonInit.value(12)()) throw;     
        if (!main.call.value(24)()) revert();  
 
        assert(main.balanceOf(address(this)) == 2); 
        
        if (main.call.value(23)()) revert();  
        assert(main.balanceOf(address(this)) == 2); 
    }
    
    
    
    function test1() returns (uint) {
        if (!main.call.value(26)()) revert();  
        assert(main.balanceOf(address(this)) == 3); 
        assert(main.emissionPrice() == 24);  
        return main.balance;
    }
    
    function test2() returns (uint){
        if (!main.call.value(40)()) revert();  
        assert(main.balanceOf(address(this)) == 4); 
         
         
    } 
    
    function test3() {
        if (!main.transfer(address(main),2)) revert();
        assert(main.burnPrice() == 14);
    } 
    
}