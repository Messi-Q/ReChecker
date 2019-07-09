pragma solidity ^0.4.21;

 
library SafeMath {

     
    function multiply(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function division(uint256 a, uint256 b) internal pure returns(uint256) {
         
        uint256 c = a / b;
         
        return c;
    }

     
    function subtract(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

     
    function plus(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract owned {
    address public owner;

    function owned() public {
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



 
contract ERC20Basic {
    function totalSupply() public view returns(uint256);

    function balanceOf(address who) public view returns(uint256);

    function transfer(address to, uint256 value) public returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}



 

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns(uint256);

    function transferFrom(address from, address to, uint256 value) public returns(bool);

    function approve(address spender, uint256 value) public returns(bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
contract BasicToken is ERC20Basic {
    using SafeMath
    for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

     
    function totalSupply() public view returns(uint256) {
        return totalSupply_;
    }


     
     


     
    function _transfer(address _from, address _to, uint _value) internal {

         
        require(_to != 0x0);
         
        require(balances[_from] >= _value);
         
        require(balances[_to].plus(_value) > balances[_to]);
         
        uint previousBalances = balances[_from].plus(balances[_to]);
         
        balances[_from] = balances[_from].subtract(_value);
         
        balances[_to] = balances[_to].plus(_value);
        emit Transfer(_from, _to, _value);
         
        assert(balances[_from].plus(balances[_to]) == previousBalances);

    }

     
    function transfer(address _to, uint256 _value) public returns(bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }


     
    function balanceOf(address _owner) public view returns(uint256 balance) {
        return balances[_owner];
    }
}


 
contract StandardToken is ERC20, BasicToken {

    mapping(address => mapping(address => uint256)) internal allowed;

     
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].subtract(_value);
        balances[_to] = balances[_to].plus(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].subtract(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(address _owner, address _spender) public view returns(uint256) {
        return allowed[_owner][_spender];
    }

     
    function increaseApproval(address _spender, uint _addedValue) public returns(bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].plus(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.subtract(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

 
contract LBCoinJ is owned, StandardToken {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    uint256 public sellPrice;
    uint256 public buyPrice;

    bool public emergencyStop;

    mapping(address => bool) public frozenAccount;

     
    event FrozenFunds(address target, bool frozen);

    event Emergency(bool stop);
     
    event Burn(address indexed from, uint256 value);


    
     
    function LBCoinJ(string tokenName, string tokenSymbol, uint256 initialSupply) public {
        name = tokenName;
        symbol = tokenSymbol;
        totalSupply_ = initialSupply * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply_;
        emit Transfer(0x0, msg.sender, totalSupply_);
    }
    
    
     
    


     
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);  
        require(balances[_from] >= _value);  
        require(balances[_to].plus(_value) >= balances[_to]);  
        require(!frozenAccount[_from]);  
        require(!frozenAccount[_to]);  
        require(!emergencyStop);  

         
        balances[_from] = balances[_from].subtract(_value);
        balances[_to] = balances[_to].plus(_value);
        emit Transfer(_from, _to, _value);
    }

     
     
     
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balances[target] = balances[target].plus(mintedAmount);
        totalSupply_ = totalSupply_.plus(mintedAmount);
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }

     
     
     
    function burn(uint256 _value) public returns(bool success) {
        require(balances[msg.sender] >= _value);  
        balances[msg.sender] = balances[msg.sender].subtract(_value);  
        totalSupply_ = totalSupply_.subtract(_value);  
        emit Burn(msg.sender, _value);
        return true;
    }

     
     
     
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

     
     
     
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

     
    function emergency(bool stop) onlyOwner public {
        emergencyStop = stop;
        emit Emergency(emergencyStop);
    }
}