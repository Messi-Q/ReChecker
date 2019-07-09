pragma solidity ^0.4.17;

pragma solidity ^0.4.16;

pragma solidity ^0.4.17;



interface TokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}


contract ERC20 {

     
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8  public decimals;     


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns(bool);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);

}


contract TokenERC20 is ERC20 {

     
    mapping (address => uint256) balances;
     
    mapping (address => mapping (address => uint256)) allowances;


     
    event Burn(address indexed from, uint256 value);


     
    constructor(uint256 _initialSupply, string _tokenName, string _tokenSymbol, uint8 _decimals) public {
        name = _tokenName;                                    
        symbol = _tokenSymbol;                                
        decimals = _decimals;

        totalSupply = _initialSupply * 10 ** uint256(decimals);   
        balances[msg.sender] = totalSupply;                 
    }

    function balanceOf(address _owner) public view returns(uint256) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }

     
    function _transfer(address _from, address _to, uint _value) internal returns(bool) {
         
        require(_to != 0x0);
         
        require(balances[_from] >= _value);
         
        require(balances[_to] + _value > balances[_to]);
         
        uint previousBalances = balances[_from] + balances[_to];
         
        balances[_from] -= _value;
         
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
         
        assert(balances[_from] + balances[_to] == previousBalances);

        return true;
    }

     
    function transfer(address _to, uint256 _value) public returns(bool) {
        return _transfer(msg.sender, _to, _value);
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_value <= allowances[_from][msg.sender]);      
        allowances[_from][msg.sender] -= _value;
        return _transfer(_from, _to, _value);
    }

     
    function approve(address _spender, uint256 _value) public returns(bool) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns(bool) {
        if (approve(_spender, _value)) {
            TokenRecipient spender = TokenRecipient(_spender);
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
        return false;
    }

     
    function burn(uint256 _value) public returns(bool) {
        require(balances[msg.sender] >= _value);    
        balances[msg.sender] -= _value;             
        totalSupply -= _value;                       
        emit Burn(msg.sender, _value);
        return true;
    }

     
    function burnFrom(address _from, uint256 _value) public returns(bool) {
        require(balances[_from] >= _value);                 
        require(_value <= allowances[_from][msg.sender]);     
        balances[_from] -= _value;                          
        allowances[_from][msg.sender] -= _value;              
        totalSupply -= _value;                               
        emit Burn(_from, _value);
        return true;
    }

     
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
         
        require(allowances[msg.sender][_spender] + _addedValue > allowances[msg.sender][_spender]);

        allowances[msg.sender][_spender] += _addedValue;
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowances[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowances[msg.sender][_spender] = 0;
        } else {
            allowances[msg.sender][_spender] = oldValue - _subtractedValue;
        }
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }


}


contract CaiToken is TokenERC20(21000000000, "Cai Token", "CAI", 18) {

    constructor() public {

    }
}