pragma solidity ^0.4.21;

 
 
 
 
 
 

contract NetkillerAdvancedTokenAirDrop {
    address public owner;
     
    string public name;
    string public symbol;
    uint public decimals;
     
    uint256 public totalSupply;
    
     
    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Burn(address indexed from, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    mapping (address => bool) public frozenAccount;

     
    event FrozenFunds(address indexed target, bool frozen);

    bool public lock = false;                    
    bool public airdropStatus = false;           
    uint256 public airdropTotalSupply;           
    uint256 public airdropCurrentTotal;    	     
    uint256 public airdropAmount;        		 
    mapping(address => bool) public touched;     
    
    event AirDrop(address indexed target, uint256 value);

     
    function NetkillerAdvancedTokenAirDrop(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        uint decimalUnits
    ) public {
        owner = msg.sender;
        name = tokenName;                                    
        symbol = tokenSymbol; 
        decimals = decimalUnits;
        totalSupply = initialSupply * 10 ** uint256(decimals);   
        balances[msg.sender] = totalSupply;                 
        airdropAmount = 1 * 10 ** uint256(decimals);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier isLock {
        require(!lock);
        _;
    }
    
    function setLock(bool _lock) onlyOwner public returns (bool status){
        lock = _lock;
        return lock;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    function balanceOf(address _address) public returns (uint256 balance) {
        return getBalance(_address);
    }
    
     
    function _transfer(address _from, address _to, uint _value) isLock internal {
        initialize(_from);

        require (_to != 0x0);                                
        require (balances[_from] >= _value);                
        require (balances[_to] + _value > balances[_to]);  
        require(!frozenAccount[_from]);                      
        require(!frozenAccount[_to]);                        
        balances[_from] -= _value;                          
        balances[_to] += _value;                            
        emit Transfer(_from, _to, _value);
    }

     
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowed[_from][msg.sender]);      
        allowed[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
     
    function burn(uint256 _value) onlyOwner public returns (bool success) {
        require(balances[msg.sender] >= _value);    
        balances[msg.sender] -= _value;             
        totalSupply -= _value;                       
        emit Burn(msg.sender, _value);
        return true;
    }

     
    function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success) {
        require(balances[_from] >= _value);                 
        require(_value <= allowed[_from][msg.sender]);     
        balances[_from] -= _value;                          
        allowed[_from][msg.sender] -= _value;              
        totalSupply -= _value;                               
        emit Burn(_from, _value);
        return true;
    }

     
     
     
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        uint256 _amount = mintedAmount * 10 ** uint256(decimals);
        balances[target] += _amount;
        totalSupply += _amount;
        emit Transfer(this, target, _amount);
    }

     
     
     
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
     
    function mintAirdropToken(uint256 _mintedAmount) onlyOwner public {
        uint256 _amount = _mintedAmount * 10 ** uint256(decimals);
        totalSupply += _amount;
        airdropTotalSupply += _amount;
    }

    function setAirdropStatus(bool _status) onlyOwner public returns (bool status){
        require(airdropTotalSupply > 0);
        airdropStatus = _status;
        return airdropStatus;
    }
    function setAirdropAmount(uint256 _amount) onlyOwner public{
        airdropAmount = _amount * 10 ** uint256(decimals);
    }
     
    function initialize(address _address) internal returns (bool success) {
        if (airdropStatus && !touched[_address] && airdropCurrentTotal < airdropTotalSupply) {
            touched[_address] = true;
            airdropCurrentTotal += airdropAmount;
            balances[_address] += airdropAmount;
            emit AirDrop(_address, airdropAmount);
        }
        return true;
    }

    function getBalance(address _address) internal returns (uint256) {
        if (airdropStatus && !touched[_address] && airdropCurrentTotal < airdropTotalSupply) {
            balances[_address] += airdropAmount;
        }
        return balances[_address];
    }
}