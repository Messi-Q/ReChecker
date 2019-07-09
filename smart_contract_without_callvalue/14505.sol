pragma solidity ^0.4.18;


 







 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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



contract IprontoToken is StandardToken {

   
  string public constant name = "iPRONTO";

   
  string public constant symbol = "IPR";

   
  uint8 public constant decimals = 18;

   
  uint256 public constant INITIAL_SUPPLY = 45000000 * (1 ether / 1 wei);

  address public owner;

   
  mapping (address => bool) public validKyc;

  function IprontoToken() public{
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function approveKyc(address[] _addrs)
        public
        onlyOwner
        returns (bool)
    {
        uint len = _addrs.length;
        while (len-- > 0) {
            validKyc[_addrs[len]] = true;
        }
        return true;
    }

  function isValidKyc(address _addr) public constant returns (bool){
    return validKyc[_addr];
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    require(isValidKyc(msg.sender));
    return super.approve(_spender, _value);
  }

  function() public{
    throw;
  }
}


contract CrowdsaleiPRONTOLiveICO{
  using SafeMath for uint256;
  address public owner;

   
  IprontoToken public token;

   
  uint256 public rate = 500;  
  uint256 public discountRatePreIco = 588;  
  uint256 public discountRateIco = 555;  

   
  uint256 public weiRaised;

   
   
  uint256 public constant PROMOTORS_POOL = 18000000 * (1 ether / 1 wei);
  uint256 public constant PRIVATE_SALE_POOL = 3600000 * (1 ether / 1 wei);
  uint256 public constant PRE_ICO_POOL = 6300000 * (1 ether / 1 wei);
  uint256 public constant ICO_POOL = 17100000 * (1 ether / 1 wei);

   
  uint256 public promotorSale = 0;
  uint256 public privateSale = 0;
  uint256 public preicoSale = 0;
  uint256 public icoSale = 0;

   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

   
  function CrowdsaleiPRONTOLiveICO() public{
    token = createTokenContract();
    owner = msg.sender;
  }

   
  function createTokenContract() internal returns (IprontoToken) {
    return new IprontoToken();
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function validPurchase(uint256 weiAmount, address beneficiary) internal view returns (bool) {
    bool nonZeroPurchase = weiAmount != 0;
    bool validAddress = beneficiary != address(0);
    return nonZeroPurchase && validAddress;
  }

   
  function availableTokenBalance(uint256 token_needed, uint8 mode)  internal view returns (bool){

    if (mode == 1) {  
      return ((promotorSale + token_needed) <= PROMOTORS_POOL );
    }
    else if (mode == 2) {  
      return ((privateSale + token_needed) <= PRIVATE_SALE_POOL);
    }
    else if (mode == 3) {  
      return ((preicoSale + token_needed) <= PRE_ICO_POOL);
    }
    else if (mode == 4) {  
      return ((icoSale + token_needed) <= ICO_POOL);
    }
    else {
      return false;
    }
  }

   
  function () public payable {
    throw;
  }

   
  function transferToken(address beneficiary, uint256 tokens, uint8 mode) onlyOwner public {
     
    require(validPurchase(tokens, beneficiary));
    require(availableTokenBalance(tokens, mode));
     
    if(mode == 1){
      promotorSale = promotorSale.add(tokens);
    } else if(mode == 2) {
      privateSale = privateSale.add(tokens);
    } else if(mode == 3) {
      preicoSale = preicoSale.add(tokens);
    } else if(mode == 4) {
      icoSale = icoSale.add(tokens);
    } else {
      throw;
    }
    token.transfer(beneficiary, tokens);
    TokenPurchase(beneficiary, beneficiary, tokens, tokens);
  }

   
  function balanceOf(address _addr) public view returns (uint256 balance) {
    return token.balanceOf(_addr);
  }

  function setTokenPrice(uint256 _rate,uint256 _discountRatePreIco,uint256 _discountRateIco) onlyOwner public returns (bool){
    rate = _rate;  
    discountRatePreIco = _discountRatePreIco;  
    discountRateIco = _discountRateIco;  
    return true;
  }
}