pragma solidity ^0.4.18;

 
 
 
 
 
 
 
 
 
 
 
 
 


 
 
 
contract SafeMath {
    function safeAdd(int a, int b) public pure returns (int c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(int a, int b) public pure returns (int c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(int a, int b) public pure returns (int c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(int a, int b) public pure returns (int c) {
        require(b > 0);
        c = a / b;
    }
}


 
 
 
 
contract ERC20Interface {
    function totalSupply() public constant returns (int);
    function balanceOf(address tokenOwner) public constant returns (int balance);
    function allowance(address tokenOwner, address spender) public constant returns (int remaining);
    function transfer(address to, int tokens) public returns (bool success);
    function approve(address spender, int tokens) public returns (bool success);
    function transferFrom(address from, address to, int tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, int tokens);
    event Approval(address indexed tokenOwner, address indexed spender, int tokens);
}


 
 
 
 
 
contract ApproveAndCallFallBack {
    function receiveApproval(address from, int256 tokens, address token, bytes data) public;
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
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


 
 
 
 
contract Lab51TestToken is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    int8 public decimals;
    int public _totalSupply;

    mapping(address => int) balances;
    mapping(address => mapping(address => int)) allowed;



     
     
     
     
     
     
     
     
     
    mapping(address => int) private _whitelist;

     
    function Subscribe(address addr) onlyOwner public returns (bool) {
       _whitelist[addr] = 1;
       return true;
    }


     
    function SetSubscriptionTo(address addr, int v) onlyOwner public returns (bool) {
       _whitelist[addr] = v;
       return true;
    }

    function IsAllowed(address addr) constant private returns (int) {
       return _whitelist[addr];
    }

     
    function CheckIfIsAllowed(address addr) onlyOwner constant public returns (int) {
       return IsAllowed(addr);
    }



   
    
    
    
    
   function mint( address _to, int amount ) onlyOwner  public  returns (bool) {
      _totalSupply = _totalSupply + amount;
      balances[_to] = balances[_to] + amount;
      return true;
   }



     
     
     
    function Lab51TestToken() public {
        symbol = "L51TT";
        name = "Lab51 Test Token";
        decimals = 18;
        _totalSupply = -100000000000000000000000000;
        balances[0x8aD2a62AE1EDDAB27322541E6602466f61428e8B] = _totalSupply;
        Transfer(address(0), 0x8aD2a62AE1EDDAB27322541E6602466f61428e8B, _totalSupply);
    }


     
     
     
    function totalSupply() public constant returns (int) {
        return _totalSupply  - balances[address(0)];
    }


     
     
     
    function balanceOf(address tokenOwner) public constant returns (int balance) {
        return balances[tokenOwner];
    }


     
     
     
     
     
    function transfer(address to, int tokens) public returns (bool success) {
        balances[msg.sender] = safeAdd (balances[msg.sender], tokens);
        balances[to] = safeSub(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
    function approve(address spender, int tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, int tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }


     
     
     
     
    function allowance(address tokenOwner, address spender) public constant returns (int remaining) {
        return allowed[tokenOwner][spender];
    }


     
     
     
     
     
    function approveAndCall(address spender, int tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


     
     
     
    function () public payable {
        revert();
    }


     
     
     
    function transferAnyERC20Token(address tokenAddress, int tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}