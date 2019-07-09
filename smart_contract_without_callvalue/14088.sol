pragma solidity ^0.4.23;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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

contract ERC20 {
    uint256 public totalSupply;

    bool public transfersEnabled;

    function balanceOf(address _owner) public constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC223Basic {
    uint256 public totalSupply;

    bool public transfersEnabled;

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function transfer(address to, uint256 value, bytes data) public;

    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

}

contract ERC223ReceivingContract {
     
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

contract ERC223Token is ERC223Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;  

     
    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords * 32 + 4);
        _;
    }

     
    function transfer(address _to, uint _value, bytes _data) public onlyPayloadSize(3) {
         
         
        uint codeLength;
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(transfersEnabled);

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
    }

     
    function transfer(address _to, uint _value) public onlyPayloadSize(2) returns(bool) {
        uint codeLength;
        bytes memory empty;
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(transfersEnabled);

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


     
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
}

contract StandardToken is ERC20, ERC223Token {

    mapping(address => mapping(address => uint256)) internal allowed;

     
    function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3) returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(transfersEnabled);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(address _owner, address _spender) public onlyPayloadSize(2) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

     
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract RaiseYourBet is StandardToken {

    string public constant name = "RaiseYourBet";
    string public constant symbol = "RAISE";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 75*10**7 * (10**uint256(decimals));
    address public owner;

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) public {
        totalSupply = INITIAL_SUPPLY;
        owner = _owner;
         
        balances[owner] = INITIAL_SUPPLY;
        transfersEnabled = true;
    }

     
    function() payable public {
        revert();
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _newOwner) onlyOwner public returns (bool){
        require(_newOwner != address(0));
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
        return true;
    }

    function enableTransfers(bool _transfersEnabled) onlyOwner public {
        transfersEnabled = _transfersEnabled;
    }

}