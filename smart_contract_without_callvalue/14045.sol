pragma solidity ^0.4.18;

 
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
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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


contract StandardToken is ERC20 {
  using SafeMath for uint256;

  uint256 public totalSupply;

  mapping(address => uint256) balances;
  mapping(address => mapping (address => uint256)) allowed;

     
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

   
  function _transfer(address _from, address _to, uint _value) internal {
    require(_value > 0);
    require(balances[_from] >= _value);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(_from, _to, _value);
  }
  
   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    _transfer(msg.sender, _to, _value);
    return true;
  }

   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require (_value <= allowed[_from][msg.sender]);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
     
     
     
     
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}



contract SEXNTestToken is StandardToken, Ownable {
  using SafeMath for uint256;

  string public constant name = "Sex Test Chain";
  string public constant symbol = "ST";
  uint8 public constant decimals = 18;

  struct lockInfo {
    uint256 amount;             
    uint256 start;              
    uint256 transfered;         
    uint256 duration;           
    uint256 releaseCount;         
  }

  mapping(address => lockInfo) internal _lockInfo;
   
  mapping(address => uint256) internal _lockupBalances;

  bool public preSaleFinished = false;

   
  uint256 public startTime;
  uint256 public endTime;

   
  uint256 public rate;

   
  uint256 public lockCycle;

   
   
  uint256 public constant DURATION = 5 * 60;   

   
  uint256 public constant CAT_FIRST = 20000 * (10 ** 18);

  enum PresaleAction {
    Ready,
    FirstPresaleActivity,
    SecondPresaleActivity,
    ThirdPresaleActivity,
    END
  }

  PresaleAction public saleAction = PresaleAction.Ready;


  address private PRESALE_ADDRESS = 0x8Aa8f4e3220838245f04fBf80A00378187dAe2bc;          
  address private FOUNDATION_ADDRESS = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;       
  address private COMMERCIAL_PLAN_ADDRESS = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;  
  address private TEAM_ADDRESS = 0x583031D1113aD414F02576BD6afaBfb302140225;             
  address private COMMUNITY_TEAM_ADDRESS = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;   

  address public wallet = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;


   
   
   

  event UnLock(address indexed beneficiary, uint256 amount);
  event SellTokens(address indexed recipient, uint256 sellTokens, uint256 rate);

   
   
   

   
  modifier beginSaleActive() {
    require(now >= startTime && now <= endTime);
    _;
  }

   
  modifier notpreSaleActive() {
    require(now <= startTime || now >= endTime);
    _;
  }


   
  function getLockBalance(address _owner) public view returns(uint256){
    return _lockupBalances[_owner];
  }

   
  function getRemainingPreSalesAmount() public view returns(uint256){
    return balances[PRESALE_ADDRESS];
  }

   
  function getLockTime(address _owner) public view returns(uint256){
     
    return _lockInfo[_owner].start.add(
        _lockInfo[_owner].releaseCount.mul(_lockInfo[_owner].duration));
  }

   
  function setSaleInfo(uint8 _round ,uint256 _startTime, uint256 _stopTime, uint256 _rate, uint256 _amount) external notpreSaleActive onlyOwner {
    require(_round == 1 || _round == 2 || _round == 3);
    require(_startTime < _stopTime);
    require(_rate != 0 && _amount >= 0);
    require(_startTime > now); 
    require(!preSaleFinished);

    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[PRESALE_ADDRESS] = balances[PRESALE_ADDRESS].add(_amount);

    startTime = _startTime;
    endTime = _stopTime;
    rate = _rate;
    _caluLocktime(_round);
  }

  function _caluLocktime(uint8 _round) internal {
    require(_round == 1 || _round == 2 || _round == 3);
    if (_round == 1 ){
      saleAction = PresaleAction.FirstPresaleActivity;
      lockCycle = 200;         
    }

    if (_round == 2){
      saleAction = PresaleAction.SecondPresaleActivity;
      lockCycle = 150;         
    }

    if (_round == 3){
      saleAction = PresaleAction.ThirdPresaleActivity;
      lockCycle = 120;         
    }
  }


   
  function closeSale() public onlyOwner notpreSaleActive {
    preSaleFinished = true;
    saleAction = PresaleAction.END;
  }


   
  function _distribute(address _to, uint256 _amount, uint256 _lockCycle, uint256 _duration) internal returns(bool)  {
     
    require(_lockInfo[_to].amount == 0 );
    require(_lockupBalances[_to] == 0);

    _lockInfo[_to].amount = _amount;
    _lockInfo[_to].releaseCount = _lockCycle;
    _lockInfo[_to].start = now;
    _lockInfo[_to].transfered = 0;
    _lockInfo[_to].duration = _duration;
    
     
    _lockupBalances[_to] = _amount;

    return true;
  }

   
  function distribute(address _to, uint256 _amount) public onlyOwner beginSaleActive {
    require(_to != 0x0);
    require(_amount != 0);
    
    _distribute(_to, _amount,lockCycle, DURATION);
    
    balances[PRESALE_ADDRESS] = balances[PRESALE_ADDRESS].sub(_amount);
    emit Transfer(PRESALE_ADDRESS, _to, _amount);
  }


   
  function _releasableAmount(address _owner, uint256 time) internal view returns (uint256){
    lockInfo storage userLockInfo = _lockInfo[_owner]; 
    if (userLockInfo.transfered == userLockInfo.amount){
      return 0;
    }

     
    uint256 amountPerRelease = userLockInfo.amount.div(userLockInfo.releaseCount);  
     
    uint256 amount = amountPerRelease.mul((time.sub(userLockInfo.start)).div(userLockInfo.duration));

    if (amount > userLockInfo.amount){
      amount = userLockInfo.amount;
    }
     
    amount = amount.sub(userLockInfo.transfered);

    return amount;
  }


   
  function relaseLock() internal returns(uint256){
    uint256 amount = _releasableAmount(msg.sender, now);
    if (amount > 0){
      _lockInfo[msg.sender].transfered = _lockInfo[msg.sender].transfered.add(amount);
      balances[msg.sender] = balances[msg.sender].add(amount);
      _lockupBalances[msg.sender] = _lockupBalances[msg.sender].sub(amount);
      emit UnLock(msg.sender, amount);
    }
    return 0;
  }


  function _initialize() internal {

    uint256 PRESALE_SUPPLY = totalSupply.mul(20).div(100);           
    uint256 FOUNDATION_SUPPLY = totalSupply.mul(30).div(100);        
    uint256 COMMUNITY_REWARDS_SUPPLY = totalSupply.mul(20).div(100); 
    uint256 COMMUNITY_TEAM_SUPPLY = totalSupply.mul(10).div(100);    
    uint256 COMMERCIAL_PLAN_SUPPLY = totalSupply * 10 / 100;         
    uint256 TEAM_SUPPLY = totalSupply.mul(10).div(100);              

    balances[msg.sender] = PRESALE_SUPPLY;
    balances[FOUNDATION_ADDRESS] = FOUNDATION_SUPPLY + COMMUNITY_REWARDS_SUPPLY;
    balances[COMMERCIAL_PLAN_ADDRESS] = COMMERCIAL_PLAN_SUPPLY;

    _distribute(COMMUNITY_TEAM_ADDRESS, COMMUNITY_TEAM_SUPPLY, 1, 365 days);
    _lockupBalances[COMMUNITY_TEAM_ADDRESS] = COMMUNITY_TEAM_SUPPLY;

    _distribute(TEAM_ADDRESS, TEAM_SUPPLY, 1, 365 days);
    _lockupBalances[TEAM_ADDRESS] = TEAM_SUPPLY;
  }



  function SEXNTestToken() public {
    totalSupply = 580000000 * (10 ** 18);  
    _initialize();
  }


   
  function () external payable beginSaleActive {
      sellTokens();
  }


   
  function sellTokens() public payable beginSaleActive {
    require(msg.value > 0);

    uint256 amount = msg.value;
    uint256 tokens = amount.mul(rate);

     
    require(tokens <= balances[PRESALE_ADDRESS]);

    if (saleAction == PresaleAction.FirstPresaleActivity){
       
      require (tokens <= CAT_FIRST);
    }

     
    _distribute(msg.sender, tokens, lockCycle, DURATION);

    
    balances[PRESALE_ADDRESS] = balances[PRESALE_ADDRESS].sub(tokens);

    emit Transfer(PRESALE_ADDRESS, msg.sender, tokens);
    emit SellTokens(msg.sender, tokens, rate);

    forwardFunds();
  }


   
   
  function forwardFunds() internal {
      wallet.transfer(msg.value);
  }


  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner].add(_lockupBalances[_owner]);
  }


  function transfer(address _to, uint256 _value) public returns (bool) {
    if (_lockupBalances[msg.sender] > 0){
      relaseLock();
    }

    return  super.transfer( _to, _value);
  }

}