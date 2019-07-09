pragma solidity 0.4.21;

 
 
 
 
 
 
 
 
 
 


 
 
 
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
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


 
 
 
 
 
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
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


 
 
 
 
contract EpsBonus is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
  

    uint256 public sellPrice;
    uint256 public buyPrice;


    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;
    mapping (address => bool) public frozenAccount;

      
    event FrozenFunds(address target, bool frozen);

      
    event Burn(address indexed from, uint256 value);
     
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    } 


     
     
     
    function EpsBonus() public {
        symbol = "EPSBC";
        name = "EPS BONUS";
        decimals = 18;
        _totalSupply = 10000000;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }


     
     
     
    function totalSupply() public view returns (uint) {
        return safeSub(_totalSupply , balances[address(0)]);
    }


     
     
     
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

   


     
     
     
     
     
    function transfer(address to, uint tokens) onlyPayloadSize(safeMul(2,32)) public  returns (bool success) {
        _transfer(msg.sender, to, tokens);               
        return true;
    }


     
     
     
     
     
     
     
     
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens)  onlyPayloadSize(safeMul(3,32)) public returns (bool success) {

        require (to != 0x0);                                
        require (balances[from] >= tokens);                
        require (safeAdd(balances[to] , tokens) >= balances[to]);  
        require(!frozenAccount[from]);                      
        require(!frozenAccount[to]);                        

        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


     
     
     
     
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


     
     
     
     
     
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }



      
     
     
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balances[target] = safeAdd(balances[target], mintedAmount);    
        _totalSupply = safeAdd(_totalSupply, mintedAmount);
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }

      
     
     
    function freezeAccount(address from, bool freeze) onlyOwner public {
        frozenAccount[from] = freeze;
        emit FrozenFunds(from, freeze);
    }
    

     
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                                
        require (balances[_from] >= _value);                
        require (safeAdd(balances[_to] , _value) >= balances[_to]);  
        require(!frozenAccount[_from]);                      
        require(!frozenAccount[_to]);                        
        
        balances[_from] = safeSub(balances[_from], _value);
        balances[_to] = safeAdd(balances[_to], _value);              
        emit Transfer(_from, _to, _value);
    }


     
     
     
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

     
    function buy() payable public {
        uint amount = safeDiv(msg.value , buyPrice);                
        _transfer(this, msg.sender, amount);               
    }

     
     
    function sell(uint256 amount) public {
        require(address(this).balance >= safeMul(amount ,sellPrice));       
        _transfer(msg.sender, this, amount);               
        msg.sender.transfer(safeMul(amount ,sellPrice));           
    }

     
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);    
        balances[msg.sender] = safeSub(balances[msg.sender], _value);  
        _totalSupply = safeSub(_totalSupply, _value);  
                     
        emit Burn(msg.sender, _value);
        return true;
    }

     
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);                 
        require(_value <= allowed[_from][msg.sender]);     
        balances[_from] = safeSub(balances[_from], _value);  
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);  
        _totalSupply = safeSub(_totalSupply, _value);   
        emit Burn(_from, _value);
        return true;
    }


     
     
     
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}