pragma solidity ^0.4.18;
 
 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
 
 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
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

  function div(uint256 a, uint256 b) internal pure  returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure  returns (uint256) {
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
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
 
   
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
 
}
 
 
contract StandardToken is ERC20, BasicToken {
 
  mapping (address => mapping (address => uint256)) allowed;
 
   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    var _allowance = allowed[_from][msg.sender];
 
     
     
 
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
 
   
  function approve(address _spender, uint256 _value) public returns (bool) {
 
     
     
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
 
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
 
   
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
 
}
 
 
contract Ownable {
    
  address public owner;
 
   
  function Ownable() public {
    owner = msg.sender;
  }
 
   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
 
   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }
 
}
 
 
 
contract MintableToken is StandardToken, Ownable {
    
  event Mint(address indexed to, uint256 amount);
  
  event MintFinished();
 
  bool public mintingFinished = false;
 
  address public saleAgent;
  
   modifier canMint() {
   require(!mintingFinished);
    _;
  }
  
   modifier onlySaleAgent() {
   require(msg.sender == saleAgent);
    _;
  }

  function setSaleAgent(address newSaleAgent) public onlyOwner {
   saleAgent = newSaleAgent;
  }

   
  function mint(address _to, uint256 _amount) public onlySaleAgent canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }
 
   
  function finishMinting() public onlySaleAgent returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  
}
 
contract AgroTechFarmToken is MintableToken {
    
    string public constant name = "Agro Tech Farm";
    
    string public constant symbol = "ATF";
    
    uint32 public constant decimals = 18;
}
 





contract PrivateSale is Ownable {    
    using SafeMath for uint;        
    AgroTechFarmToken public token;
    bool public PrivateSaleFinished = false;          
    address public multisig;
    address public preSale = 0x02Dcc61022771015b1408323D29C790066CBe2e4;
    address public preSale1 = 0xfafbb19945fc2d79828e4c5813a619d5683074ba;
    address public preSale2 = 0x62451D37Ca2EC1f0499996Bc3C7e2BAF258E9729;
    address public preSale3 = 0x72636c350431895fc6ee718b92bcc5b4fbd70304;
	address public preSale4 = 0xE2615137c379910897D4c662345a5A1D0B91f719;
	address public preSale5 = 0x25190dca5d174f08205F7376A36CAdDF14072732;
    uint public rate;
    uint public start;
    uint public end;
    uint public hardcap;
    address public restricted;
	uint public restrictedPercent;

    function PrivateSale() public {        
	    token = AgroTechFarmToken(0xa55ffAeA5c8cf32B550F663bf17d4F7b739534ff); 
		multisig = 0x227917ac3C1F192874d43031cF4D40fd40Ae6127;
		rate = 83333333333000000000; 
		start = 1525150800;
        end = 1527829200; 
	    hardcap = 500000000000000000000;
	    restricted = 0xbcCd749ecCCee5B4898d0E38D2a536fa84Ea9Ef6;   
	    restrictedPercent = 35;
          
    }
 
   modifier saleIsOn() {
    	require(now > start && now < end);
    	_;
    }
	
    modifier isUnderHardCap() {
      require(this.balance <= hardcap);
        _;
    } 


  function balancePrivateSale() public constant returns (uint) {
     return this.balance;
    }

 
  function finishPrivateSale() public onlyOwner returns (bool)  {
        if(now > end || this.balance >= hardcap) {                     
         multisig.transfer(this.balance);
         PrivateSaleFinished = true;
         return true;
         } else return false;     
      }
 
   function createTokens() public isUnderHardCap saleIsOn payable {
        uint tokens = rate.mul(msg.value).div(1 ether);           
        uint bonusTokens = tokens.mul(30).div(100);       
        tokens += bonusTokens;     
        token.mint(msg.sender, tokens);
       
	    uint restrictedTokens = tokens.mul(restrictedPercent).div(100); 
        token.mint(restricted, restrictedTokens);        
        
    }
 

    function() external payable {
        createTokens();
    } 
}