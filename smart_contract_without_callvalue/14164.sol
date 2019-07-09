pragma solidity ^0.4.23;

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
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

 
contract BasicToken is ERC20Basic, Ownable {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
   
  mapping(address => uint8) permissionsList;
  
  function SetPermissionsList(address _address, uint8 _sign) public onlyOwner{
    permissionsList[_address] = _sign; 
  }
  function GetPermissionsList(address _address) public constant onlyOwner returns(uint8){
    return permissionsList[_address]; 
  }  
  uint256 totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(permissionsList[msg.sender] == 0);
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(permissionsList[msg.sender] == 0);
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

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

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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


 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

 
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

 
contract MintableToken is PausableToken {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

   
  function mint(address _to, uint256 _amount) onlyOwner canMint whenNotPaused public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}
contract BurnableByOwner is BasicToken {

  event Burn(address indexed burner, uint256 value);
  function burn(address _address, uint256 _value) public onlyOwner{
    require(_value <= balances[_address]);
     
     

    address burner = _address;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value);
    emit Transfer(burner, address(0), _value);
  }
}

contract TRND is Ownable, MintableToken, BurnableByOwner {
  using SafeMath for uint256;    
  string public constant name = "Trends";
  string public constant symbol = "TRND";
  uint32 public constant decimals = 18;
  
  address public addressPrivateSale;
  address public addressAirdrop;
  address public addressPremineBounty;
  address public addressPartnerships;

  uint256 public summPrivateSale;
  uint256 public summAirdrop;
  uint256 public summPremineBounty;
  uint256 public summPartnerships;
  

  function TRND() public {
    addressPrivateSale   = 0x6701DdeDBeb3155B8c908D0D12985A699B9d2272;
    addressAirdrop       = 0xd176131235B5B8dC314202a8B348CC71798B0874;
    addressPremineBounty = 0xd176131235B5B8dC314202a8B348CC71798B0874;
    addressPartnerships  = 0x441B2B781a6b411f1988084a597e2ED4e0A7C352; 
	
    summPrivateSale   = 5000000 * (10 ** uint256(decimals)); 
    summAirdrop       = 4500000 * (10 ** uint256(decimals));  
    summPremineBounty = 1000000 * (10 ** uint256(decimals));  
    summPartnerships  = 2500000 * (10 ** uint256(decimals));  		    
     
    mint(addressPrivateSale, summPrivateSale);
    mint(addressAirdrop, summAirdrop);
    mint(addressPremineBounty, summPremineBounty);
    mint(addressPartnerships, summPartnerships);
  }
}

 
contract Crowdsale is Ownable {
  using SafeMath for uint256;
   
  uint softcap;
   
  uint256 hardcapPreICO; 
  uint256 hardcapMainSale;  
  TRND public token;
   
  mapping(address => uint) public balances;

   
   
     
  uint256 public startIcoPreICO;  
  uint256 public startIcoMainSale;  
     
  uint256 public endIcoPreICO; 
  uint256 public endIcoMainSale;   
   
  

  uint256 public totalSoldTokens;
  uint256 minPurchasePreICO;     
  uint256 minPurchaseMainSale;   
  
   
  uint256 public rateIcoPreICO;
  uint256 public rateIcoMainSale;

   
  uint256 public unconfirmedSum;
  mapping(address => uint) public unconfirmedSumAddr;
   
  address public wallet;
  
  
 
  event TokenProcurement(address indexed contributor, address indexed beneficiary, uint256 value, uint256 amount);
  
  function Crowdsale() public {
    token = createTokenContract();
     
    softcap            = 20000000 * 1 ether; 
    hardcapPreICO      =  5000000 * 1 ether; 
    hardcapMainSale    = 80000000 * 1 ether; 
	
     
    minPurchasePreICO      = 100000000000000000;
    minPurchaseMainSale    = 100000000000000000;
     
     
     
    startIcoPreICO   = 1527843600;  
    endIcoPreICO     = 1530435600;  
    startIcoMainSale = 1530435600;  
    endIcoMainSale   = 1533891600;  

     
    rateIcoPreICO = 5600;
     
    rateIcoMainSale = 2800;

     
    wallet = 0xca5EdAE100d4D262DC3Ec2dE96FD9943Ea659d04;
  }
  
  function setStartIcoPreICO(uint256 _startIcoPreICO) public onlyOwner  { 
    uint256 delta;
    require(now < startIcoPreICO);
	if (startIcoPreICO > _startIcoPreICO) {
	  delta = startIcoPreICO.sub(_startIcoPreICO);
	  startIcoPreICO   = _startIcoPreICO;
	  endIcoPreICO     = endIcoPreICO.sub(delta);
      startIcoMainSale = startIcoMainSale.sub(delta);
      endIcoMainSale   = endIcoMainSale.sub(delta);
	}
	if (startIcoPreICO < _startIcoPreICO) {
	  delta = _startIcoPreICO.sub(startIcoPreICO);
	  startIcoPreICO   = _startIcoPreICO;
	  endIcoPreICO     = endIcoPreICO.add(delta);
      startIcoMainSale = startIcoMainSale.add(delta);
      endIcoMainSale   = endIcoMainSale.add(delta);
	}	
  }
  
  function setRateIcoPreICO(uint256 _rateIcoPreICO) public onlyOwner  {
    rateIcoPreICO = _rateIcoPreICO;
  }   
  function setRateIcoMainSale(uint _rateIcoMainSale) public onlyOwner  {
    rateIcoMainSale = _rateIcoMainSale;
  }     
   
  function () external payable {
    procureTokens(msg.sender);
  }
  
  function createTokenContract() internal returns (TRND) {
    return new TRND();
  }
  
  function getRateIcoWithBonus() public view returns (uint256) {
    uint256 bonus;
	uint256 rateICO;
     
    if (now >= startIcoPreICO && now < endIcoPreICO){
      rateICO = rateIcoPreICO;
    }  

     
    if (now >= startIcoMainSale  && now < endIcoMainSale){
      rateICO = rateIcoMainSale;
    }  

     
    if (now >= startIcoPreICO && now < startIcoPreICO.add( 2 * 7 * 1 days )){
      bonus = 10;
    }  
    if (now >= startIcoPreICO.add(2 * 7 * 1 days) && now < startIcoPreICO.add(4 * 7 * 1 days)){
      bonus = 8;
    } 
    if (now >= startIcoPreICO.add(4 * 7 * 1 days) && now < startIcoPreICO.add(6 * 7 * 1 days)){
      bonus = 6;
    } 
    if (now >= startIcoPreICO.add(6 * 7 * 1 days) && now < startIcoPreICO.add(8 * 7 * 1 days)){
      bonus = 4;
    } 
    if (now >= startIcoPreICO.add(8 * 7 * 1 days) && now < startIcoPreICO.add(10 * 7 * 1 days)){
      bonus = 2;
    } 

    return rateICO + rateICO.mul(bonus).div(100);
  }    
   
  function procureTokens(address beneficiary) public payable {
    uint256 tokens;
    uint256 weiAmount = msg.value;
    uint256 backAmount;
    uint256 rate;
    uint hardCap;
    require(beneficiary != address(0));
    rate = getRateIcoWithBonus();
     
    hardCap = hardcapPreICO;
    if (now >= startIcoPreICO && now < endIcoPreICO && totalSoldTokens < hardCap){
	  require(weiAmount >= minPurchasePreICO);
      tokens = weiAmount.mul(rate);
      if (hardCap.sub(totalSoldTokens) < tokens){
        tokens = hardCap.sub(totalSoldTokens); 
        weiAmount = tokens.div(rate);
        backAmount = msg.value.sub(weiAmount);
      }
    }  
     
    hardCap = hardcapMainSale.add(hardcapPreICO);
    if (now >= startIcoMainSale  && now < endIcoMainSale  && totalSoldTokens < hardCap){
	  require(weiAmount >= minPurchaseMainSale);
      tokens = weiAmount.mul(rate);
      if (hardCap.sub(totalSoldTokens) < tokens){
        tokens = hardCap.sub(totalSoldTokens); 
        weiAmount = tokens.div(rate);
        backAmount = msg.value.sub(weiAmount);
      }
    }     
    require(tokens > 0);
    totalSoldTokens = totalSoldTokens.add(tokens);
    balances[msg.sender] = balances[msg.sender].add(weiAmount);
    token.mint(msg.sender, tokens);
	unconfirmedSum = unconfirmedSum.add(tokens);
	unconfirmedSumAddr[msg.sender] = unconfirmedSumAddr[msg.sender].add(tokens);
	token.SetPermissionsList(beneficiary, 1);
    if (backAmount > 0){
      msg.sender.transfer(backAmount);    
    }
    emit TokenProcurement(msg.sender, beneficiary, weiAmount, tokens);
  }

  function refund() public{
    require(totalSoldTokens.sub(unconfirmedSum) < softcap && now > endIcoMainSale);
    require(balances[msg.sender] > 0);
    uint value = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(value);
  }
  
  function transferEthToMultisig() public onlyOwner {
    address _this = this;
    require(totalSoldTokens.sub(unconfirmedSum) >= softcap && now > endIcoMainSale);  
    wallet.transfer(_this.balance);
  } 
  
  function refundUnconfirmed() public{
    require(now > endIcoMainSale);
    require(balances[msg.sender] > 0);
    require(token.GetPermissionsList(msg.sender) == 1);
    uint value = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(value);
    
    uint uvalue = unconfirmedSumAddr[msg.sender];
    unconfirmedSumAddr[msg.sender] = 0;
    token.burn(msg.sender, uvalue );
    
  } 
  
  function SetPermissionsList(address _address, uint8 _sign) public onlyOwner{
      uint8 sign;
      sign = token.GetPermissionsList(_address);
      token.SetPermissionsList(_address, _sign);
      if (_sign == 0){
          if (sign != _sign){  
			unconfirmedSum = unconfirmedSum.sub(unconfirmedSumAddr[_address]);
			unconfirmedSumAddr[_address] = 0;
          }
      }
   }
   
   function GetPermissionsList(address _address) public constant onlyOwner returns(uint8){
     return token.GetPermissionsList(_address); 
   }   
   
   function pause() onlyOwner public {
     token.pause();
   }

   function unpause() onlyOwner public {
     token.unpause();
   }
    
}