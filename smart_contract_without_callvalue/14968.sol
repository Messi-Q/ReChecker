pragma solidity ^0.4.21;

contract Token {

     
    function totalSupply() constant returns (uint256 supply) {}

     
     
    function balanceOf(address _owner) constant returns (uint256 balance) {}

     
     
     
     
    function transfer(address _to, uint256 _value) returns (bool success) {}

     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

     
     
     
     
    function approve(address _spender, uint256 _value) returns (bool success) {}

     
     
     
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
         
         
         
         
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
         
         
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract Shefo is StandardToken {  

     

     
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H1.3'; 
    uint256 public unitsOneEthCanBuy;      
    uint256 public totalEthInWei;          
    address public fundsWallet;            
	uint256 public preIcoEnd;
	uint256 public icoEnd;
	uint256 public icoBalance;

     
     
    function Shefo() {
        balances[msg.sender] = 60000000000000000000000000000;                
        totalSupply = 60000000000000000000000000000;                         
        name = "Shefo";                                    
        decimals = 18;                                                 
        symbol = "SFX";                                              
        unitsOneEthCanBuy = 25000000;                                    
        fundsWallet = msg.sender;                                      
		preIcoEnd = 1528243000;
		icoEnd = 1531530000;
		icoBalance = 60000000000000000000000000000;
		 
		 
    }

    function() payable{
        totalEthInWei = totalEthInWei + msg.value;
		icoBalance = balanceOf(0x80A74A7d853AaaF2a52292A9cdAc4E420Eb3a2f4);
		if (now < preIcoEnd && icoBalance > 50000000000000000000000000000){
			unitsOneEthCanBuy = 25000000;  
		}
		if (now > preIcoEnd && now < icoEnd && icoBalance > 30000000000000000000000000000){
			unitsOneEthCanBuy = 22500000;  
		}
		if (now > preIcoEnd && now < icoEnd && icoBalance <= 30000000000000000000000000000 && icoBalance > 25000000000000000000000000000){ 
			unitsOneEthCanBuy = 20000000;  
		}
		if (now > preIcoEnd && now < icoEnd && icoBalance <= 25000000000000000000000000000 && icoBalance > 20000000000000000000000000000){ 
			unitsOneEthCanBuy = 17500000;  
		}
		if (icoBalance <= 20000000000000000000000000000){
			return;
		}
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);

        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        Transfer(fundsWallet, msg.sender, amount);  

         
        fundsWallet.transfer(msg.value);                               
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

         
         
         
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}