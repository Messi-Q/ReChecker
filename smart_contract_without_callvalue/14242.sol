pragma solidity ^0.4.19;

 
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

 
 
 
 
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

 
 
 
 

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


contract DanatCoin is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    
    uint lastBlock;
    uint circulatedTokens = 0;
    uint _rewardedTokens = 0;
    uint _rewardTokenValue = 5;
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    mapping (address => bool) public frozenAccount;
    
    
    event FrozenFunds(address target, bool frozen);  
  
     
    function DanatCoin() public {
        symbol = "DNC";
        name = "Danat Coin";
        decimals = 18;
        _totalSupply = 100000000 * 10 ** uint(decimals);     
        balances[msg.sender] = _totalSupply;                 
        emit Transfer(address(0), msg.sender, _totalSupply);      
    }

     
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

     
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               			 
        require (balances[_from] >= _value);               			     
        require (balances[_to] + _value > balances[_to]); 			     
        require(!frozenAccount[_from]);                     			 
        require(!frozenAccount[_to]);                       			 
        uint previousBalances = balances[_from] + balances[_to];		 
		balances[_from] = safeSub(balances[_from],_value);    			 
        balances[_to] = safeAdd(balances[_to],_value);        			 
        emit Transfer(_from, _to, _value);									 
		assert(balances[_from] + balances[_to] == previousBalances);     
    }
    
   
     

    function transfer(address to, uint tokens) public returns (bool success) {
       _transfer(msg.sender, to, tokens);
        return true;
    }

     
  
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        
        require(tokens <= allowed[from][msg.sender]);  
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);    
        _transfer(from, to, tokens);
        return true;
    }
    
     
     
    function approve(address spender, uint tokens) public returns (bool success) {
         
         
         
         
        require((tokens == 0) || (allowed[msg.sender][spender] == 0));
        
        allowed[msg.sender][spender] = tokens;  
        emit Approval(msg.sender, spender, tokens);  
        return true;
    }

     

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

     
     
     
     
     
     
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
         
         
        
        require(approve(spender, tokens));  
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

     
     
     
    function () public payable {
        revert();
    }

     

    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

     
     
     
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}