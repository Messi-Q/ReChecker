pragma solidity ^0.4.18;


 

 
 
 
 
 
 
 



 

 

 

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function div(uint a, uint b) internal pure returns (uint c) {

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

    function Owned() public {

        owner = msg.sender;

    }


    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

}



 

 

 

 

contract DWEToken is ERC20Interface, Owned {

    using SafeMath for uint;


    string public symbol;

    string public  name;

    uint8 public decimals;

    uint public _totalSupply;


    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;



     

     

     

    function DWEToken() public {

        symbol = "DWE";

        name = "Digital World Exchange";

        decimals = 18;

        _totalSupply = 65000000 * 10**uint(decimals);

        balances[owner] = _totalSupply;

        Transfer(address(0), owner, _totalSupply);

    }



     

     

     

    function totalSupply() public constant returns (uint) {

        return _totalSupply  - balances[address(0)];

    }



     

     

     

    function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return balances[tokenOwner];

    }



     

     

     

     

     

    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        Transfer(msg.sender, to, tokens);

        return true;

    }



     

     

     

     

     

     

     

     

    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        return true;

    }



     

     

     

     

     

     

     

     

     

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        Transfer(from, to, tokens);

        return true;

    }



     

     

     

     

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }


     

     

     

    function () public payable {


    }


     
     
     
    function withdraw() public onlyOwner returns (bool result) {
        
        return owner.send(this.balance);
        
    }
    
     

     

     

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }

}