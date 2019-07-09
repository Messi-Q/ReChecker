pragma solidity ^0.4.13;

 

contract ValidationUtil {
    function requireNotEmptyAddress(address value) internal{
        require(isAddressValid(value));
    }

    function isAddressValid(address value) internal constant returns (bool result){
        return value != 0;
    }
}

 

 
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function getOwner() returns(address){
    return owner;
  }

   
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

   
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    var _allowance = allowed[_from][msg.sender];

     
     

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) returns (bool) {

     
     
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  
   
  function increaseApproval (address _spender, uint _addedValue) 
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) 
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

 
contract BurnableToken is StandardToken, Ownable, ValidationUtil {
    using SafeMath for uint;

    address public tokenOwnerBurner;

     
    event Burned(address burner, uint burnedAmount);

    function setOwnerBurner(address _tokenOwnerBurner) public onlyOwner invalidOwnerBurner{
         
        requireNotEmptyAddress(_tokenOwnerBurner);

        tokenOwnerBurner = _tokenOwnerBurner;
    }

     
    function burnOwnerTokens(uint burnAmount) public onlyTokenOwnerBurner validOwnerBurner{
        burnTokens(tokenOwnerBurner, burnAmount);
    }

     
    function burnTokens(address _address, uint burnAmount) public onlyTokenOwnerBurner validOwnerBurner{
        balances[_address] = balances[_address].sub(burnAmount);

         
        Burned(_address, burnAmount);
    }

     
    function burnAllOwnerTokens() public onlyTokenOwnerBurner validOwnerBurner{
        uint burnAmount = balances[tokenOwnerBurner];
        burnTokens(tokenOwnerBurner, burnAmount);
    }

     
    modifier onlyTokenOwnerBurner() {
        require(msg.sender == tokenOwnerBurner);

        _;
    }

    modifier validOwnerBurner() {
         
        requireNotEmptyAddress(tokenOwnerBurner);

        _;
    }

    modifier invalidOwnerBurner() {
         
        require(!isAddressValid(tokenOwnerBurner));

        _;
    }
}

 

contract CrowdsaleToken is StandardToken, Ownable {

     
    string public name;

    string public symbol;

    uint public decimals;

    address public mintAgent;

     
    event UpdatedTokenInformation(string newName, string newSymbol);

     
    event TokenMinted(uint amount, address toAddress);

     
    function CrowdsaleToken(string _name, string _symbol, uint _decimals) {
        owner = msg.sender;

        name = _name;
        symbol = _symbol;

        decimals = _decimals;
    }

     
    function mintToAddress(uint amount, address toAddress) onlyMintAgent{
         
        balances[toAddress] = amount;

         
        TokenMinted(amount, toAddress);
    }

     
    function setTokenInformation(string _name, string _symbol) onlyOwner {
        name = _name;
        symbol = _symbol;

         
        UpdatedTokenInformation(name, symbol);
    }

     
    function setMintAgent(address _address) onlyOwner {
        mintAgent =  _address;
    }

    modifier onlyMintAgent(){
        require(msg.sender == mintAgent);

        _;
    }
}

 
contract BurnableCrowdsaleToken is BurnableToken, CrowdsaleToken {

    function BurnableCrowdsaleToken(string _name, string _symbol, uint _decimals) CrowdsaleToken(_name, _symbol, _decimals) BurnableToken(){

    }
}