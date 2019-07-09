pragma solidity ^0.4.17;

 
contract Ownable {
    
    address public owner;

     
    function Ownable()public {
        owner = msg.sender;
    }
    
     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
   
     
    function transferOwnership(address newOwner)public onlyOwner {
        require(newOwner != address(0));      
        owner = newOwner;
    }
}

 
contract ERC20Basic is Ownable {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value)public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender)public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value)public returns(bool);
    function approve(address spender, uint256 value)public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure  returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure  returns (uint256) {
         
        uint256 c = a / b;
         
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure  returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure  returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

 
contract BasicToken is ERC20Basic {
    
    using SafeMath for uint256;
    
    mapping(address => uint256) balances;

     
    function transfer(address _to, uint256 _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    
     
    function balanceOf(address _owner)public constant returns (uint256 balance) {
        return balances[_owner];
    }
}

 
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;
    
     
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_value <= allowed[_from][msg.sender]);
        var _allowance = allowed[_from][msg.sender];
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    
     
    function approve(address _spender, uint256 _value) public returns (bool) {
        require((_value > 0)&&(_value <= balances[msg.sender]));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
     
    function allowance(address _owner, address _spender)public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

 
contract MintableToken is StandardToken {
    
    event Mint(address indexed to, uint256 amount);
    
    event MintFinished();

    bool public mintingFinished = false;
    
     
    modifier canMint() {
        require(!mintingFinished);
        _;
    }
    
     
    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }
    
     
    function finishMinting() public onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}

 
contract BurnableToken is MintableToken {
    
    using SafeMath for uint;
    
     
    function burn(uint _value) public returns (bool success) {
        require((_value > 0) && (_value <= balances[msg.sender]));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        return true;
    }
 
     
    function burnFrom(address _from, uint _value) public returns (bool success) {
        require((balances[_from] > _value) && (_value <= allowed[_from][msg.sender]));
        var _allowance = allowed[_from][msg.sender];
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Burn(_from, _value);
        return true;
    }

    event Burn(address indexed burner, uint indexed value);
}

 
contract BitcoinCityCoin is BurnableToken {
    
    string public constant name = "Bitcoin City";
    
    string public constant symbol = "BCKEY";
    
    uint32 public constant decimals = 8;
    
    address private contractAddress;
    
    
     
    function SimpleTokenCoin()public {
       balances[0xb2DeC9309Ca7047a6257fC83a95fcFc23Ab821DC] = 500000000 * 10**decimals;
    }
    
    
      
    function setContractAddress (address _address) public onlyOwner {
        contractAddress = _address;
    }
    
     
    function approveAndCall(uint tokens, bytes data) public returns (bool success) {
        approve(contractAddress, tokens);
        ApproveAndCallFallBack(contractAddress).receiveApproval(msg.sender, tokens, data);
        return true;
    }
}

interface ApproveAndCallFallBack { function receiveApproval(address from, uint256 tokens, bytes data) external; }