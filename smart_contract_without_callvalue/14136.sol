pragma solidity ^0.4.18;

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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

 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

     
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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

contract QIUToken is StandardToken,Ownable {
    string public name = 'QIUToken';
    string public symbol = 'QIU';
    uint8 public decimals = 0;
    uint public INITIAL_SUPPLY = 5000000000;
    uint public eth2qiuRate = 10000;

    function() public payable { }  

    function QIUToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[owner] = INITIAL_SUPPLY / 10;
        balances[this] = INITIAL_SUPPLY - balances[owner];
    }

    function getOwner() public view returns (address) {
        return owner;
    }  
    
     
    function ownerTransferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(tx.origin == owner);  
        require(_to != address(0));
        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

       
    function originTransfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[tx.origin]);

         
        balances[tx.origin] = balances[tx.origin].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(tx.origin, _to, _value);
        return true;
    }

    event ExchangeForETH(address fromAddr,address to,uint qiuAmount,uint ethAmount);
    function exchangeForETH(uint qiuAmount) public returns (bool){
        uint ethAmount = qiuAmount * 1000000000000000000 / eth2qiuRate;  
        require(this.balance >= ethAmount);
        balances[this] = balances[this].add(qiuAmount);
        balances[msg.sender] = balances[msg.sender].sub(qiuAmount);
        msg.sender.transfer(ethAmount);
        ExchangeForETH(this,msg.sender,qiuAmount,ethAmount);
        return true;
    }

    event ExchangeForQIU(address fromAddr,address to,uint qiuAmount,uint ethAmount);
    function exchangeForQIU() payable public returns (bool){
        uint qiuAmount = msg.value * eth2qiuRate / 1000000000000000000;
        require(qiuAmount <= balances[this]);
        balances[this] = balances[this].sub(qiuAmount);
        balances[msg.sender] = balances[msg.sender].add(qiuAmount);
        ExchangeForQIU(this,msg.sender,qiuAmount,msg.value);
        return true;
    }

    function getETHBalance() public view returns (uint) {
        return this.balance;  
    }
}