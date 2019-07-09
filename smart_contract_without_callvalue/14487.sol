pragma solidity ^0.4.23;

 
 
 
 
 
 
 
 
 
 


 
 
 
contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function zeroSub(uint a, uint b) internal pure returns (uint c) {
        if (a >= b) {
            c = safeSub(a, b);
        } else {
            c = 0;
        }
    }

    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) internal pure returns (uint c) {
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


 
 
 
 
 
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
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


 
 
 
 
contract ZooblinToken is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    uint public startDate;

    uint public preSaleAmount;
    uint private preSaleFrom;
    uint private preSaleUntil;

    uint public roundOneAmount;
    uint private roundOneFrom;
    uint private roundOneUntil;

    uint public roundTwoAmount;
    uint private roundTwoFrom;
    uint private roundTwoUntil;

    uint public roundThreeAmount;
    uint private roundThreeFrom;
    uint private roundThreeUntil;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


     
     
     
    constructor() public {
        symbol = "ZBN";
        name = "Zooblin Token";
        decimals = 18;
        _totalSupply = 300000000000000000000000000;

        balances[0x9D926842F6D40c3AF314992f7865Bc5be17e8676] = _totalSupply;
        emit Transfer(address(0), 0x9D926842F6D40c3AF314992f7865Bc5be17e8676, _totalSupply);

        startDate       = 1525564800;  

        preSaleAmount   = 20000000000000000000000000;
        roundOneAmount  = 150000000000000000000000000;
        roundTwoAmount  = 80000000000000000000000000;
        roundThreeAmount= 50000000000000000000000000;

        preSaleFrom     = 1527811200;  
        preSaleUntil    = 1531699199;  

        roundOneFrom    = 1533081600;  
        roundOneUntil   = 1535759999;  

        roundTwoFrom    = 1535760000;  
        roundTwoUntil   = 1538351999;  

        roundThreeFrom  = 1538352000;  
        roundThreeUntil = 1541030399;  
    }


     
     
     
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

     
     
     
    function isPreSalePeriod(uint date) public constant returns (bool) {
        return date >= preSaleFrom && date <= preSaleUntil && preSaleAmount > 0;
    }

     
     
     
    function isRoundOneSalePeriod(uint date) public constant returns (bool) {
        return date >= roundOneFrom && date <= roundOneUntil && roundOneAmount > 0;
    }

     
     
     
    function isRoundTwoSalePeriod(uint date) public constant returns (bool) {
        return date >= roundTwoFrom && date <= roundTwoUntil && roundTwoAmount > 0;
    }

     
     
     
    function isRoundThreeSalePeriod(uint date) public constant returns (bool) {
        return date >= roundThreeFrom && date <= roundThreeUntil && roundThreeAmount > 0;
    }

     
     
     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


     
     
     
     
     
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


     
     
     
     
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


     
     
     
     
     
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

     
     
     
    function () public payable {
        require(now >= startDate && msg.value >= 1000000000000000000);

        uint tokens = 0;

        if (isPreSalePeriod(now)) {
            tokens = msg.value * 13000;
            preSaleAmount = zeroSub(preSaleAmount, tokens);
        }

        if (isRoundOneSalePeriod(now)) {
            tokens = msg.value * 11500;
            roundOneAmount = zeroSub(roundOneAmount, tokens);
        }

        if (isRoundTwoSalePeriod(now)) {
            tokens = msg.value * 11000;
            roundTwoAmount = zeroSub(roundTwoAmount, tokens);
        }

        if (isRoundThreeSalePeriod(now)) {
            tokens = msg.value * 10500;
            roundThreeAmount = zeroSub(roundThreeAmount, tokens);
        }

        require(tokens > 0);
        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
        _totalSupply = safeAdd(_totalSupply, tokens);
        emit Transfer(address(0), msg.sender, tokens);
        owner.transfer(msg.value);
    }

     
     
     
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}