pragma solidity ^0.4.23;
 
 
 

 
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

 

contract ERC223ReceivingContract { 
 
    function tokenFallback(address _from, uint256 _value, bytes _data);
}

 

contract ERC223Interface {
    uint256 public totalSupply;
    function balanceOf(address who) constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool success);
    function transfer(address to, uint256 value, bytes data) public returns (bool success);
	function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
 
 
contract ERC223Token is ERC223Interface {
     using SafeMath for uint256;

     mapping(address => uint256) balances;  
	 mapping (address => mapping (address => uint256)) internal allowed;
	
	
	
	 string public name = "COOPAY COIN TEST";
     string public symbol = "COOTEST";
     uint8 public decimals = 18;
     uint256 public totalSupply = 265200000 * (10**18);
	
	
	 function ERC223Token()
     {
       balances[msg.sender] = totalSupply;
     }
  
  
	   
	  function name() constant returns (string _name) {
		  return name;
	  }
	   
	  function symbol() constant returns (string _symbol) {
		  return symbol;
	  }
	   
	  function decimals() constant returns (uint8 _decimals) {
		  return decimals;
	  }
	   
	  function totalSupply() constant returns (uint256 _totalSupply) {
		  return totalSupply;
	  }
  
	
    
     
    function transfer(address _to, uint256 _value, bytes _data) returns (bool success) {
        
		require(_value > 0);
		require(_to != 0x0);
		require(balances[msg.sender] > 0);
		
        uint256 codeLength;

        assembly {
             
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    
     
    function transfer(address _to, uint256 _value) returns (bool success) {
	
	    require(_value > 0);
		require(_to != 0x0);
		require(balances[msg.sender] > 0);
		
        uint256 codeLength;
        bytes memory empty;

        assembly {
             
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        emit Transfer(msg.sender, _to, _value, empty);
        return true;
    }
	
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
     require(_to != address(0));
     require(_value <= balances[_from]);
     require(_value <= allowed[_from][msg.sender]);
     bytes memory empty;
     balances[_from] = balances[_from].sub(_value);
     balances[_to] = balances[_to].add(_value);
     allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
     emit Transfer(_from, _to, _value,empty);
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

    
     
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
}