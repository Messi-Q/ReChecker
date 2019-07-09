pragma solidity ^0.4.19;

contract ERC20Token {

     
    function totalSupply() constant returns (uint supply) {}

     
     
    function balanceOf(address _owner) constant returns (uint balance) {}

     
     
     
     
    function transfer(address _to, uint _value) returns (bool success) {}

     
     
     
     
     
    function transferFrom(address _from, address _to, uint _value) returns (bool success) {}

     
     
     
     
    function approve(address _spender, uint _value) returns (bool success) {}

     
     
     
    function allowance(address _owner, address _spender) constant returns (uint remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract RegularToken is ERC20Token {

    function transfer(address _to, uint _value) returns (bool) {
         
        if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint _value) returns (bool) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint public totalSupply;
}

contract UnboundedRegularToken is RegularToken {

    uint constant MAX_UINT = 2**256 - 1;
    
     
     
     
     
     
    function transferFrom(address _from, address _to, uint _value)
        public
        returns (bool)
    {
        uint allowance = allowed[_from][msg.sender];
        if (balances[_from] >= _value
            && allowance >= _value
            && balances[_to] + _value >= balances[_to]
        ) {
            balances[_to] += _value;
            balances[_from] -= _value;
            if (allowance < MAX_UINT) {
                allowed[_from][msg.sender] -= _value;
            }
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }
}

contract WTO is UnboundedRegularToken {

    uint public totalSupply = 100*10**26;
    uint8 constant public decimals = 18;
    string constant public name = "WindTalk Token";
    string constant public symbol = "WTO";

    function WTO() {
        balances[msg.sender] = totalSupply;
        Transfer(address(0), msg.sender, totalSupply);
    }
}