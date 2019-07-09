pragma solidity ^0.4.18;

 
contract SafeMath {

    function safeMul(uint a, uint b)pure internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b)pure internal returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint a, uint b)pure internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b)pure internal returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
}

 
contract ERC20 {
    function balanceOf(address who) public view returns (uint);
    function allowance(address owner, address spender) public view returns (uint);
    function transfer(address to, uint value) public returns (bool ok);
    function transferFrom(address from, address to, uint value) public returns (bool ok);
    function approve(address spender, uint value) public returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract ERC223Interface {
    function transfer(address to, uint value, bytes data) public returns (bool ok);  
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

 
 
contract ContractReceiver {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

 
contract Ownable {
     
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public{
        require(newOwner != owner);
        require(newOwner != address(0));
        owner = newOwner;
    }

}

 
contract StandardToken is ERC20, SafeMath, ERC223Interface {

     
    mapping(address => uint) balances;
    uint public totalSupply;

     
    mapping (address => mapping (address => uint)) internal allowed;
     
    modifier onlyPayloadSize(uint size) {
        if(msg.data.length < size + 4) {
            revert();
        }
        _;
    }
     
    function transfer(address _to, uint _value, bytes _data)
    onlyPayloadSize(2 * 32) 
    public
    returns (bool success) 
    {
        require(_to != address(0));
        if (balances[msg.sender] >= _value && _value > 0) {
             
             
            uint codeLength;

            assembly {
             
            codeLength := extcodesize(_to)
            }
            balances[msg.sender] = safeSub(balances[msg.sender], _value);
            balances[_to] = safeAdd(balances[_to], _value);
            if(codeLength>0) {
                ContractReceiver receiver = ContractReceiver(_to);
                receiver.tokenFallback(msg.sender, _value, _data);
            }
            emit Transfer(msg.sender, _to, _value, _data);
            return true;
        }else{return false;}

    }
    
     
    function transfer(address _to, uint _value) 
    onlyPayloadSize(2 * 32) 
    public
    returns (bool success)
    {
        require(_to != address(0));
        if (balances[msg.sender] >= _value && _value > 0) {
            uint codeLength;
            bytes memory empty;
            assembly {
             
            codeLength := extcodesize(_to)
            }

            balances[msg.sender] = safeSub(balances[msg.sender], _value);
            balances[_to] = safeAdd(balances[_to], _value);
            if(codeLength>0) {
                ContractReceiver receiver = ContractReceiver(_to);
                receiver.tokenFallback(msg.sender, _value, empty);
            }
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }

    }

    function transferFrom(address _from, address _to, uint _value)
    public
    returns (bool success) 
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        uint _allowance = allowed[_from][msg.sender];
        balances[_to] = safeAdd(balances[_to], _value);
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(_allowance, _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) 
    public
    returns (bool success)
    {
        require(_spender != address(0));
         
         
         
         
         
        require(_value == 0 || allowed[msg.sender][_spender] == 0);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender], _addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = safeSub(oldValue, _subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}

contract CoSoundToken is StandardToken, Ownable {
    string public name;
    uint8 public decimals; 
    string public symbol;
    uint totalEthInWei;

    constructor() public{
        decimals = 18;      
        totalSupply = 1200000000 * 10 ** uint256(decimals);      
        balances[msg.sender] = totalSupply;     
        name = "Cosound";     
        symbol = "CSND";     
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) 
    public
    returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }

     
    function() payable public{
        revert();
    }

    function transferToCrowdsale(address _to, uint _value) 
    onlyPayloadSize(2 * 32) 
    onlyOwner
    public
    returns (bool success)
    {
        require(_to != address(0));
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = safeSub(balances[msg.sender], _value);
            balances[_to] = safeAdd(balances[_to], _value);
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        else { 
            return false; 
        }
    }
}