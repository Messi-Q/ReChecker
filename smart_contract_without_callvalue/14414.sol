pragma solidity ^0.4.21;

 
 
contract Owned {
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function Owned() public {
        owner = msg.sender;
    }

    function changeOwner(address _newOwner) public onlyOwner{
        owner = _newOwner;
    }
}


 
 
library SafeMath {

  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
     
    uint c = a / b;
     
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

}

contract tokenRecipient {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}

contract ERC20Token {
     
     
    uint256 public totalSupply;

     
     
    function balanceOf(address _owner) constant public returns (uint256 balance);

     
     
     
     
    function transfer(address _to, uint256 _value) public returns (bool success);

     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

     
     
     
     
    function approve(address _spender, uint256 _value) public returns (bool success);

     
     
     
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract standardToken is ERC20Token {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;
    

    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

     
    function transfer(address _to, uint256 _value) 
        public 
        returns (bool success) 
    {
        require (balances[msg.sender] >= _value);            
        require (balances[_to] + _value >= balances[_to]);   
        balances[msg.sender] -= _value;                      
        balances[_to] += _value;                             
        emit Transfer(msg.sender, _to, _value);                   
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        allowances[msg.sender][_spender] = _value;           
        emit Approval(msg.sender, _spender, _value);              
        return true;
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);               
        approve(_spender, _value);                                       
        spender.receiveApproval(msg.sender, _value, this, _extraData);   
        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require (balances[_from] >= _value);                 
        require (balances[_to] + _value >= balances[_to]);   
        require (_value <= allowances[_from][msg.sender]);   
        balances[_from] -= _value;                           
        balances[_to] += _value;                             
        allowances[_from][msg.sender] -= _value;             
        emit Transfer(_from, _to, _value);                        
        return true;
    }

     
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

}

contract EOBIToken is standardToken,Owned {
    using SafeMath for uint;

    string public name="EOBI Token";
    string public symbol="EOBI";
    uint256 public decimals=18;
    
    uint256 public totalSupply = 0;
    uint256 public topTotalSupply = 35*10**8*10**decimals;
    uint256 public privateTotalSupply = percent(10);
    uint256 public privateSupply = 0;
    address public walletAddress;

    uint256 public exchangeRate = 10**5;
    
    bool public ICOStart;
    
     
    function() public payable {
        if(ICOStart){
            depositToken(msg.value);
        }
    }
    
     
    function EOBIToken() public {
        owner=msg.sender;
        ICOStart = true;
    }
    
     
    function percent(uint256 _percentage) internal view returns (uint256) {
        return _percentage.mul(topTotalSupply).div(100);
    }
    
     
    function depositToken(uint256 _value) internal {
        uint256 tokenAlloc = buyPriceAt() * _value;
        require(tokenAlloc != 0);
        privateSupply = privateSupply.add(tokenAlloc);
        require (privateSupply <= privateTotalSupply);
        mintTokens(msg.sender, tokenAlloc);
    }
    
     
    function mintTokens(address _to, uint256 _amount) internal {
        require (balances[_to] + _amount >= balances[_to]);      
        balances[_to] = balances[_to].add(_amount);              
        totalSupply = totalSupply.add(_amount);
        require(totalSupply <= topTotalSupply);
        emit Transfer(0x0, _to, _amount);                             
    }
    
     
    function buyPriceAt() internal constant returns(uint256) {
        return exchangeRate;
    }
    
     
    function changeExchangeRate(uint256 _rate) public onlyOwner {
        exchangeRate = _rate;
    }
    
     
    function setVaribles(string _name, string _symbol, uint256 _decimals) public onlyOwner {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        topTotalSupply = 35*10**8*10**decimals;
        require(totalSupply <= topTotalSupply);
        privateTotalSupply = percent(10);
        require(privateSupply <= privateTotalSupply);
    }
    
     
    function ICOState(bool _start) public onlyOwner {
        ICOStart = _start;
    }
    
     
    function withDraw(address _etherAddress) public payable onlyOwner {
        require (_etherAddress != address(0));
        address contractAddress = this;
        _etherAddress.transfer(contractAddress.balance);
    }
    
     
    function allocateTokens(address[] _owners, uint256[] _values) public onlyOwner {
        require (_owners.length == _values.length);
        for(uint256 i = 0; i < _owners.length ; i++){
            address owner = _owners[i];
            uint256 value = _values[i];
            mintTokens(owner, value);
        }
    }
}