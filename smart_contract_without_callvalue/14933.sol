pragma solidity 0.4.23;

 
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

contract ERC20 {
  function totalSupply()public view returns (uint total_Supply);
  function balanceOf(address who)public view returns (uint256);
  function allowance(address owner, address spender)public view returns (uint);
  function transferFrom(address from, address to, uint value)public returns (bool ok);
  function approve(address spender, uint value)public returns (bool ok);
  function transfer(address to, uint value)public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract WGP is ERC20
{ using SafeMath for uint256;
     
    string public constant name = "W Green Pay";

     
    string public constant symbol = "WGP";
    uint8 public constant decimals = 18;
    uint public _totalsupply; 
    uint public maxCap_MInt = 60000000 * 10 ** 18;  
    address public ethFundMain = 0x67fd4721d490A5E609cF8e09FCE0a217b91F1546;  
    uint256 public mintedtokens;
    address public owner;
    uint256 public _price_tokn;
    uint256 no_of_tokens;
    bool stopped = false;
    uint256 public ico_startdate;
    uint256 public ico_enddate;
    uint256 public ETHcollected;
    bool public lockstatus; 
    bool public mintingFinished = false;
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    event Mint(address indexed from, address indexed to, uint256 amount);

    
     enum Stages {
        NOTSTARTED,
        ICO,
        PAUSED,
        ENDED
    }
    Stages public stage;
    
     modifier atStage(Stages _stage) {
        require (stage == _stage);
         _;
    }
    
     modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }
    
    constructor() public
    {
        owner = msg.sender;
        balances[owner] = 40000000 * 10 **18;   
        _totalsupply = balances[owner];
        lockstatus = true;
        stage = Stages.NOTSTARTED;
        emit Transfer(0, owner, balances[owner]);
    }
  
    function Manual_Mint(address receiver, uint256 tokenQuantity) external onlyOwner {
      
            require(!mintingFinished);
             require(mintedtokens + tokenQuantity <= maxCap_MInt && tokenQuantity > 0);
              mintedtokens = mintedtokens.add(tokenQuantity);
             _totalsupply = _totalsupply.add(tokenQuantity);
             balances[receiver] = balances[receiver].add(tokenQuantity);
             emit Mint(owner, receiver, tokenQuantity);
             emit Transfer(0, receiver, tokenQuantity);
    }

    function mintContract(address receiver, uint256 tokenQuantity) private {
            
             require(mintedtokens + tokenQuantity <= maxCap_MInt && tokenQuantity > 0);
              mintedtokens = mintedtokens.add(tokenQuantity);
             _totalsupply = _totalsupply.add(tokenQuantity);
             balances[receiver] = balances[receiver].add(tokenQuantity);
              emit Mint(address(this), receiver, tokenQuantity);
             emit Transfer(0, receiver, tokenQuantity);
    }
    
    function () public payable atStage(Stages.ICO)
    {
        require(!stopped && msg.sender != owner);
        require (now <= ico_enddate);
        _price_tokn = calcprice();
        no_of_tokens =((msg.value).mul(_price_tokn)).div(1000);
        ETHcollected = ETHcollected.add(msg.value);
        mintContract(msg.sender, no_of_tokens);
       
    }
    
    
    function calcprice() view private returns (uint){
         uint price_tokn;
         
        if(ETHcollected <= 246153 ether){
            price_tokn = 40625;    
        }
        else  if(ETHcollected > 246153 ether){
            price_tokn = 30111;    
        }
      
        return price_tokn;
    }
    
    
    
     function start_ICO() public onlyOwner atStage(Stages.NOTSTARTED)
      {
         
          stage = Stages.ICO;
          stopped = false;
          ico_startdate = now;
          ico_enddate = now + 35 days;
         
      }
    
    
       
    function CrowdSale_ModifyEndDate(uint256 addICODays) external onlyOwner atStage(Stages.ICO)
    {
        
        ico_enddate = ico_enddate.add(addICODays.mul(86400));

    }
    
     
    function CrowdSale_Halt() external onlyOwner atStage(Stages.ICO) {
        stopped = true;
        stage = Stages.PAUSED;
    }

     
    function CrowdSale_Resume() external onlyOwner atStage(Stages.PAUSED)
    {
        stopped = false;
        stage = Stages.ICO;
    }
    
     function CrowdSale_Finalize() external onlyOwner atStage(Stages.ICO)
     {
         require(now > ico_enddate);
         stage = Stages.ENDED;
         lockstatus = false;
         mintingFinished = true;
     }
     
   function CrowdSale_Change_ReceiveWallet(address New_Wallet_Address) external onlyOwner
    {
        require(New_Wallet_Address != 0x0);
        ethFundMain = New_Wallet_Address;
    }

     
     function totalSupply() public view returns (uint256 total_Supply) {
         total_Supply = _totalsupply;
     }
    
     
     function balanceOf(address _owner)public view returns (uint256 balance) {
         return balances[_owner];
     }
    
     
      
      
      
      
      
     function transferFrom( address _from, address _to, uint256 _amount )public returns (bool success) {
     require( _to != 0x0);
     require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
     balances[_from] = (balances[_from]).sub(_amount);
     allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_amount);
     balances[_to] = (balances[_to]).add(_amount);
    emit Transfer(_from, _to, _amount);
     return true;
         }
    
    
      
     function approve(address _spender, uint256 _amount)public returns (bool success) {
         require(!lockstatus);
         require( _spender != 0x0);
         allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender)public view returns (uint256 remaining) {
         require( _owner != 0x0 && _spender !=0x0);
         return allowed[_owner][_spender];
   }

      
     function transfer(address _to, uint256 _amount)public returns (bool success) {
         require(!lockstatus);
        require( _to != 0x0);
        require(balances[msg.sender] >= _amount && _amount >= 0);
        balances[msg.sender] = (balances[msg.sender]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
         }
    
   
  
     
	function CrowdSale_AssignOwnership(address newOwner)public onlyOwner
	{
	    require( newOwner != 0x0);
	    balances[newOwner] = (balances[newOwner]).add(balances[owner]);
	    balances[owner] = 0;
	    owner = newOwner;
	    emit Transfer(msg.sender, newOwner, balances[newOwner]);
	}

    
    function forwardFunds() external onlyOwner {
       
          address myAddress = this;
        ethFundMain.transfer(myAddress.balance);
    }
    
   function  forwardSomeFunds(uint256 ETHQuantity) external onlyOwner {
       uint256 fund = ETHQuantity * 10 ** 18;
       ethFundMain.transfer(fund);
    }
    
}