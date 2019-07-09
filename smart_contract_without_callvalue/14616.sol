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

 
contract ERC20 {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
}

 
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
  constructor() public {
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

contract KYCCrowdsale is Ownable{

    bool public isKYCRequired = false;

    mapping (bytes32 => address) public whiteListed;

    function enableKYC() external onlyOwner {
        require(!isKYCRequired);  
        isKYCRequired = true;
    }

    function disableKYC() external onlyOwner {
        require(isKYCRequired);  
        isKYCRequired = false; 
    }

     
    function isWhitelistedAddress(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public returns (bool){
        assert( whiteListed[hash] == address(0x0));  
        require(owner == ecrecover(hash, v, r, s));
        whiteListed[hash] = msg.sender;
        return true;
    }
}

 
contract Crowdsale is Pausable, KYCCrowdsale{
  using SafeMath for uint256;
    
   
  ERC20 public token;

   
  address public tokenWallet;

   
  uint256 public startTime;
  uint256 public endTime;

   
  address public wallet;

   
  uint256 public rate;
  
  uint256 public roundOneRate;
  uint256 public roundTwoRate;
  uint256 public defaultBonussRate;

   
  uint256 public weiRaised;

  uint256 public tokensSold;

  uint256 public constant forSale = 16250000;

   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount, uint256 releaseTime);

   
  event EndTimeUpdated();

   
  event EQUIPriceUpdated(uint256 oldPrice, uint256 newPrice);

   
  event TokenReleased(address indexed holder, uint256 amount);

  constructor() public
   {
    owner = 0xe46d0049D4a4642bC875164bd9293a05dBa523f1;
    startTime = now;
    endTime = 1527811199;  
    rate = 500000000000000;                      
    roundOneRate = (rate.mul(6)).div(10);        
    roundTwoRate = (rate.mul(65)).div(100);      
    defaultBonussRate = (rate.mul(8)).div(10);   
    
    wallet =  0xccB84A750f386bf5A4FC8C29611ad59057968605;
    token = ERC20(0xE6FF2834b6Cf56DC23282A5444B297fAcCcA1b28);
    tokenWallet =  0x4AA48F9cF25eB7d2c425780653c321cfaC458FA4;
  }

   
  function () external payable {
    buyTokens(msg.sender);
  }

   
  function buyTokens(address beneficiary) public payable whenNotPaused {
    require(beneficiary != address(0));

    validPurchase();

    uint256 weiAmount = msg.value;

     
    uint256 tokens = getTokenAmount(weiAmount);

     
    weiRaised = weiRaised.add(weiAmount);
    tokensSold = tokensSold.add(tokens);
    deposited[msg.sender] = deposited[msg.sender].add(weiAmount);
    updateRoundLimits(tokens);
   
    uint256 lockedFor = assignTokens(beneficiary, tokens);
    emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens, lockedFor);

    forwardFunds();
  }

   
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }
  
   uint256 public roundOneLimit = 9500000 ether;
   uint256 public roundTwoLimit = 6750000 ether;
   
  function updateRoundLimits(uint256 _amount) private {
      if (roundOneLimit > 0){
          if(roundOneLimit > _amount){
                roundOneLimit = roundOneLimit.sub(_amount);
                return;
          } else {
              _amount = _amount.sub(roundOneLimit);
              roundOneLimit = 0;
          }
      }
      roundTwoLimit = roundTwoLimit.sub(_amount);
  }

  function getTokenAmount(uint256 weiAmount) public view returns(uint256) {
  
      uint256 buffer = 0;
      uint256 tokens = 0;
      if(weiAmount < 1 ether)
      
         
         
        return (weiAmount.div(defaultBonussRate)).mul(1 ether);

      else if(weiAmount >= 1 ether) {
          
          
          if(roundOneLimit > 0){
              
              uint256 amount = roundOneRate * roundOneLimit;
              
              if (weiAmount > amount){
                  buffer = weiAmount - amount;
                  tokens =  (amount.div(roundOneRate)).mul(1 ether);
              }else{
                   
                   
                  return (weiAmount.div(roundOneRate)).mul(1 ether);
              }
        
          }
          
          if(buffer > 0){
              uint256 roundTwo = (buffer.div(roundTwoRate)).mul(1 ether);
              return tokens + roundTwo;
          }
          
          return (weiAmount.div(roundTwoRate)).mul(1 ether);
      }
  }

   
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

   
  function validPurchase() internal view {
    require(msg.value != 0);
    require(remainingTokens() > 0,"contract doesn't have tokens");
    require(now >= startTime && now <= endTime);
  }

  function updateEndTime(uint256 newTime) onlyOwner external {
    require(newTime > startTime);
    endTime = newTime;
    emit EndTimeUpdated();
  }

  function updateEQUIPrice(uint256 weiAmount) onlyOwner external {
    require(weiAmount > 0);
    assert((1 ether) % weiAmount == 0);
    emit EQUIPriceUpdated(rate, weiAmount);
    rate = weiAmount;
    roundOneRate = (rate.mul(6)).div(10);        
    roundTwoRate = (rate.mul(65)).div(100);      
    defaultBonussRate = (rate.mul(8)).div(10);     
  }

  mapping(address => uint256) balances;
  mapping(address => uint256) internal deposited;

  struct account{
      uint256[] releaseTime;
      mapping(uint256 => uint256) balance;
  }
  mapping(address => account) ledger;


  function assignTokens(address beneficiary, uint256 amount) private returns(uint256 lockedFor){
      lockedFor = 1526278800;  

      balances[beneficiary] = balances[beneficiary].add(amount);

      ledger[beneficiary].releaseTime.push(lockedFor);
      ledger[beneficiary].balance[lockedFor] = amount;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  function unlockedBalance(address _owner) public view returns (uint256 amount) {
    for(uint256 i = 0 ; i < ledger[_owner].releaseTime.length; i++){
        uint256 time = ledger[_owner].releaseTime[i];
        if(now >= time) amount +=  ledger[_owner].balance[time];
    }
  }

   
  function releaseEQUITokens(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public whenNotPaused {
    require(balances[msg.sender] > 0);

    uint256 amount = 0;
    for(uint8 i = 0 ; i < ledger[msg.sender].releaseTime.length; i++){
        uint256 time = ledger[msg.sender].releaseTime[i];
        if(now >= time && ledger[msg.sender].balance[time] > 0){
            amount = ledger[msg.sender].balance[time];
            ledger[msg.sender].balance[time] = 0;
            continue;
        }
    }

    if(amount <= 0 || balances[msg.sender] < amount){
        revert();
    }

    if(isKYCRequired){
        require(isWhitelistedAddress(hash, v, r, s));
        balances[msg.sender] = balances[msg.sender].sub(amount);
        if(!token.transferFrom(tokenWallet,msg.sender,amount)){
            revert();
        }
        emit TokenReleased(msg.sender,amount);
    } else {

        balances[msg.sender] = balances[msg.sender].sub(amount);
        if(!token.transferFrom(tokenWallet,msg.sender,amount)){
            revert();
        }
        emit TokenReleased(msg.sender,amount);
    }
  }

    
  function remainingTokens() public view returns (uint256) {
    return token.allowance(tokenWallet, this);
  }
}

 
contract Refundable is Crowdsale {

  uint256 public available; 
  bool public refunding = false;

  event RefundStatusUpdated();
  event Deposited();
  event Withdraw(uint256 _amount);
  event Refunded(address indexed beneficiary, uint256 weiAmount);
  
  function deposit() onlyOwner public payable {
    available = available.add(msg.value);
    emit Deposited();
  }

  function tweakRefundStatus() onlyOwner public {
    refunding = !refunding;
    emit RefundStatusUpdated();
  }

  
  function refund() public {
    require(refunding);
    uint256 depositedValue = deposited[msg.sender];
    deposited[msg.sender] = 0;
    msg.sender.transfer(depositedValue);
    emit Refunded(msg.sender, depositedValue);
  }
  
  function withDrawBack() onlyOwner public{
      owner.transfer(this.balance);
  }
  
  function Contractbalance() view external returns( uint256){
      return this.balance;
  }
}