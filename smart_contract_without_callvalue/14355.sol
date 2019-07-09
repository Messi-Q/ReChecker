pragma solidity ^0.4.16;
 
 
 
 


contract BITDRIVEToken { 
     
     
    uint256 public totalSupply;
    
     
     
    function balanceOf(address _owner) constant returns (uint256 balance);

     
     
     
     
    function transfer(address _to, uint256 _value) returns (bool success);

     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

     
     
     
     
    function approve(address _spender, uint256 _value) returns (bool success);

     
     
     
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


 

library ABCMaths {
 
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}

contract Ownable {
    address public owner;
    address public newOwner;

     
    function Ownable() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

    
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }

    function acceptOwnership() {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    event OwnershipTransferred(address indexed _from, address indexed _to);
}


contract BTDStandardToken is BITDRIVEToken, Ownable {
    
    using ABCMaths for uint256;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);
     
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[msg.sender]) return false;
        require(
            (balances[msg.sender] >= _value)  
            && (_value > 0)  
            && (_to != address(0))  
            && (balances[_to].add(_value) >= balances[_to])  
            && (msg.data.length >= (2 * 32) + 4));  
             

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[msg.sender]) return false;
        require(
            (allowed[_from][msg.sender] >= _value)  
            && (balances[_from] >= _value)  
            && (_value > 0)  
            && (_to != address(0))  
            && (balances[_to].add(_value) >= balances[_to])  
            && (msg.data.length >= (2 * 32) + 4)  
             
        );
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
         
     
    
    uint256 constant public decimals = 8;
    uint256 public totalSupply = 100 * (10**7) * 10**8 ;  
    string constant public name = "BitDrive";
    string constant public symbol = "BTD";
    
    function BITDRIVE(){
        balances[msg.sender] = totalSupply;                
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

         
         
         
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}