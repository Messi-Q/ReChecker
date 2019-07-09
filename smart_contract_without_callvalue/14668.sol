pragma solidity ^0.4.21;

 

library InteractiveCrowdsaleLib {
  using SafeMath for uint256;
  using TokenLib for TokenLib.TokenStorage;
  using LinkedListLib for LinkedListLib.LinkedList;

   
  uint256 constant NULL = 0;
  uint256 constant HEAD = 0;
  bool constant PREV = false;
  bool constant NEXT = true;

  struct InteractiveCrowdsaleStorage {

    address owner;      

  	uint256 tokensPerEth;   
  	uint256 startTime;  
  	uint256 endTime;  
    uint256 ownerBalance;  
    uint256 startingTokenBalance;  

     
  	mapping (address => uint256) hasContributed;

     
  	mapping (address => uint256) withdrawTokensMap;

     
    mapping (address => uint256) leftoverWei;

  	InteractiveCrowdsaleToken token;  

     
    LinkedListLib.LinkedList valuationsList;

     
    TokenLib.TokenStorage tokenInfo;

    uint256 endWithdrawalTime;    

     
     
    uint256 totalValuation;

     
     
     
     
    uint256 valueCommitted;

     
     
    uint256 currentBucket;

     
     
    uint256 q;

     
    uint256 minimumRaise;

     
    uint8 percentBeingSold;

     
     
    uint256 priceBonusPercent;

     
    bool isFinalized;

     
    bool isCanceled;

     
    mapping (address => uint256) pricePurchasedAt;

     
    mapping (uint256 => uint256) valuationSums;

     
    mapping (uint256 => uint256) numBidsAtValuation;

     
    mapping (address => uint256) personalCaps;

     
    mapping (address => bool) hasManuallyWithdrawn;
  }

   
  event LogTokensWithdrawn(address indexed _bidder, uint256 Amount);

   
  event LogWeiWithdrawn(address indexed _bidder, uint256 Amount);

   
  event LogOwnerEthWithdrawn(address indexed owner, uint256 amount, string Msg);

   
  event LogBidAccepted(address indexed bidder, uint256 amount, uint256 personalValuation);

   
  event LogBidWithdrawn(address indexed bidder, uint256 amount, uint256 personalValuation);

   
  event LogBidRemoved(address indexed bidder, uint256 personalValuation);

   
  event LogErrorMsg(uint256 amount, string Msg);

   
  event LogTokenPriceChange(uint256 amount, string Msg);

   
   
  event BucketAndValuationAndCommitted(uint256 bucket, uint256 valuation, uint256 committed);

  modifier saleEndedNotFinal(InteractiveCrowdsaleStorage storage self) {
    require(now > self.endTime && (!self.isFinalized));
    _;
  }

   
   
   
   
   
   
   
   
   
   
   
   
   
  function init(InteractiveCrowdsaleStorage storage self,
                address _owner,
                uint256 _priceBonusPercent,
                uint256 _minimumRaise,
                uint256 _tokensPerEth,
                uint256 _startTime,
                uint256 _endWithdrawalTime,
                uint256 _endTime,
                uint8 _percentBeingSold,
                string _tokenName,
                string _tokenSymbol,
                uint8 _tokenDecimals) internal
  {
     
     
     
    require(self.owner == 0);
    require(_owner > 0);
    require(_endWithdrawalTime < _endTime);
    require(_endWithdrawalTime > _startTime);
    require(_minimumRaise > 0);
    require(_percentBeingSold > 0);
    require(_percentBeingSold <= 100);
    require(_priceBonusPercent > 0);

     
    self.owner = _owner;
    self.priceBonusPercent = _priceBonusPercent;
    self.minimumRaise = _minimumRaise;
    self.tokensPerEth = _tokensPerEth;
    self.startTime = _startTime;
    self.endWithdrawalTime = _endWithdrawalTime;
    self.endTime = _endTime;
    self.percentBeingSold = _percentBeingSold;
    self.tokenInfo.name = _tokenName;
    self.tokenInfo.symbol = _tokenSymbol;
    self.tokenInfo.decimals = _tokenDecimals;
  }

   
   
   
   
  function numDigits(uint256 _number) private pure returns (uint256) {
    uint256 _digits = 0;
    while (_number != 0) {
      _number /= 10;
      _digits++;
    }
    return _digits;
  }

   
   
   
   
   
   
  function calculateTokenPurchase(uint256 _amount,
                                  uint256 _price)
                                  private
                                  pure
                                  returns (uint256,uint256)
  {
    uint256 remainder = 0;  

    uint256 numTokens;
    uint256 weiTokens;  

     
    weiTokens = _amount.mul(_price);

    numTokens = weiTokens / 1000000000000000000;
    remainder = weiTokens % 1000000000000000000;
    remainder = remainder / _price;

    return (numTokens,remainder);
  }

   
   
   
  function getCurrentBonus(InteractiveCrowdsaleStorage storage self) private view returns (uint256){

    uint256 bonusTime;
    uint256 elapsed;
    uint256 currentBonus;

    bonusTime = self.endWithdrawalTime.sub(self.startTime);
    elapsed = now.sub(self.startTime);

    uint256 percentElapsed = (elapsed.mul(100))/bonusTime;

    currentBonus = self.priceBonusPercent.sub(((percentElapsed.mul(self.priceBonusPercent))/100));

    return currentBonus;
  }

  function isAValidPurchase(InteractiveCrowdsaleStorage storage self) private view returns (bool){
    require(msg.sender != self.owner);

    bool nonZeroPurchase = msg.value != 0;
    require(nonZeroPurchase);
     
    require((self.personalCaps[msg.sender] == 0) && (self.hasContributed[msg.sender] == 0));
    return true;
  }

   
   
   
   
   
   
  function submitBid(InteractiveCrowdsaleStorage storage self,
                      uint256 _amount,
                      uint256 _personalCap,
                      uint256 _valuePredict)
                      public
                      returns (bool)
  {
    require(crowdsaleIsActive(self));
    require(isAValidPurchase(self));
    uint256 _bonusPercent;
    uint256 placeholder;
     
    if (isBeforeWithdrawalLock(self)) {  
      require(_personalCap > _amount);  
      _bonusPercent = getCurrentBonus(self);
    } else {  
       
       
      require(_personalCap >= self.totalValuation.add(_amount));  
    }

     
     
     
    placeholder = numDigits(_personalCap);
    if(placeholder > 3) {
       
      require((_personalCap % (10**(placeholder - 3))) == 0);
    }

     
     
    if(!self.valuationsList.nodeExists(_personalCap)){
        placeholder = self.valuationsList.getSortedSpot(_valuePredict,_personalCap,NEXT);
        self.valuationsList.insert(placeholder,_personalCap,PREV);
    }

     
    self.personalCaps[msg.sender] = _personalCap;

     
    self.valuationSums[_personalCap] = self.valuationSums[_personalCap].add(_amount);

    self.numBidsAtValuation[_personalCap] = self.numBidsAtValuation[_personalCap].add(1);

     
    self.hasContributed[msg.sender] = self.hasContributed[msg.sender].add(_amount);

     
    uint256 _proposedCommit;
    uint256 _currentBucket;
    bool loop;
    bool exists;

     
    if(_personalCap > self.currentBucket){

       
       
      if (self.totalValuation == self.currentBucket) {
         
         
        _proposedCommit = (self.valueCommitted.sub(self.valuationSums[self.currentBucket])).add(_amount);

        if(_proposedCommit > self.currentBucket){ loop = true; }
      } else {
         
         
        _proposedCommit = self.totalValuation.add(_amount);
        loop = true;
      }

      if(loop){
         
        (exists,_currentBucket) = self.valuationsList.getAdjacent(self.currentBucket, NEXT);

        while(_proposedCommit >= _currentBucket){
           
           
          _proposedCommit = _proposedCommit.sub(self.valuationSums[_currentBucket]);

           
          (exists,_currentBucket) = self.valuationsList.getAdjacent(_currentBucket, NEXT);
        }
         
        (exists, _currentBucket) = self.valuationsList.getAdjacent(_currentBucket, PREV);
        self.currentBucket = _currentBucket;
      } else {
         
        _currentBucket = self.currentBucket;
      }
       
      if(_proposedCommit <= _currentBucket){
         
        _proposedCommit = self.valuationSums[_currentBucket].add(_proposedCommit);
         
        self.totalValuation = _currentBucket;
      } else {
         
        self.totalValuation = _proposedCommit;
      }

      self.valueCommitted = _proposedCommit;
    } else if(_personalCap == self.totalValuation){
      self.valueCommitted = self.valueCommitted.add(_amount);
    }

    self.pricePurchasedAt[msg.sender] = (self.tokensPerEth.mul(_bonusPercent.add(100)))/100;
    LogBidAccepted(msg.sender, _amount, _personalCap);
    BucketAndValuationAndCommitted(self.currentBucket, self.totalValuation, self.valueCommitted);
    return true;
  }


   
   
   
   
  function withdrawBid(InteractiveCrowdsaleStorage storage self) public returns (bool) {
     
    require(self.personalCaps[msg.sender] > 0);
    require(crowdsaleIsActive(self));
    uint256 refundWei;
     
     
    if (isAfterWithdrawalLock(self)) {
      require(self.personalCaps[msg.sender] < self.totalValuation);

       
      refundWei = self.hasContributed[msg.sender];
    } else {
      require(!self.hasManuallyWithdrawn[msg.sender]);   
       
       
       
       
       
       
       
      uint256 timeLeft;

      timeLeft = self.endWithdrawalTime.sub(now);
      uint256 multiplierPercent = (timeLeft.mul(100)) / (self.endWithdrawalTime.sub(self.startTime));

      refundWei = (multiplierPercent.mul(self.hasContributed[msg.sender])) / 100;
      self.valuationSums[self.personalCaps[msg.sender]] = self.valuationSums[self.personalCaps[msg.sender]].sub(refundWei);

      self.numBidsAtValuation[self.personalCaps[msg.sender]] = self.numBidsAtValuation[self.personalCaps[msg.sender]].sub(1);

      uint256 bonusAmount;
      bonusAmount = self.pricePurchasedAt[msg.sender].sub(self.tokensPerEth);
      self.pricePurchasedAt[msg.sender] = self.pricePurchasedAt[msg.sender].sub(bonusAmount / 3);

      self.hasManuallyWithdrawn[msg.sender] = true;

    }

     
    self.leftoverWei[msg.sender] = self.leftoverWei[msg.sender].add(refundWei);

     
    self.hasContributed[msg.sender] = self.hasContributed[msg.sender].sub(refundWei);

    uint256 _proposedCommit;
    uint256 _proposedValue;
    uint256 _currentBucket;
    bool loop;
    bool exists;

     
     
    if(self.personalCaps[msg.sender] >= self.totalValuation){

       
      _proposedCommit = self.valueCommitted.sub(refundWei);

       
      if(_proposedCommit <= self.currentBucket){
         
        if(self.totalValuation > self.currentBucket){
          _proposedCommit = self.valuationSums[self.currentBucket].add(_proposedCommit);
        }

        if(_proposedCommit >= self.currentBucket){
          _proposedValue = self.currentBucket;
        } else {
           
          loop = true;
        }
      } else {
        if(self.totalValuation == self.currentBucket){
          _proposedValue = self.totalValuation;
        } else {
          _proposedValue = _proposedCommit;
        }
      }

      if(loop){
         
        (exists,_currentBucket) = self.valuationsList.getAdjacent(self.currentBucket, PREV);
        while(_proposedCommit <= _currentBucket){
           
          _proposedCommit = self.valuationSums[_currentBucket].add(_proposedCommit);
           
          if(_proposedCommit >= _currentBucket){
            _proposedValue = _currentBucket;
          } else {
            (exists,_currentBucket) = self.valuationsList.getAdjacent(_currentBucket, PREV);
          }
        }

        if(_proposedValue == 0) { _proposedValue = _proposedCommit; }

        self.currentBucket = _currentBucket;
      }

      self.totalValuation = _proposedValue;
      self.valueCommitted = _proposedCommit;
    }

    LogBidWithdrawn(msg.sender, refundWei, self.personalCaps[msg.sender]);
    BucketAndValuationAndCommitted(self.currentBucket, self.totalValuation, self.valueCommitted);
    return true;
  }

   
   
   

   
  function finalizeSale(InteractiveCrowdsaleStorage storage self) public
           saleEndedNotFinal(self)
           returns (bool)
  {
    setCanceled(self);

    self.isFinalized = true;
    require(launchToken(self));
     
    uint256 computedValue;

     
    if(!self.isCanceled){
      if(self.totalValuation == self.currentBucket){
         
        self.q = ((((self.valueCommitted.sub(self.totalValuation)).mul(100)))/self.valuationSums[self.totalValuation]).add(uint256(1));
        computedValue = self.valueCommitted.sub(self.valuationSums[self.totalValuation]);
        computedValue = computedValue.add(((uint256(100).sub(self.q)).mul(self.valuationSums[self.totalValuation]))/100);
      } else {
         
        computedValue = self.totalValuation;
      }
      self.ownerBalance = computedValue;   
    }
  }

   
   
   
   
  function launchToken(InteractiveCrowdsaleStorage storage self) private returns (bool) {
     
    uint256 _fullValue = (self.totalValuation.mul(100))/uint256(self.percentBeingSold);
     
    uint256 _bonusValue = ((self.totalValuation.mul(self.priceBonusPercent.add(100)))/100).sub(self.totalValuation);
     
    uint256 _supply = (_fullValue.mul(self.tokensPerEth))/1000000000000000000;
     
    uint256 _bonusTokens = (_bonusValue.mul(self.tokensPerEth))/1000000000000000000;
     
    uint256 _ownerTokens = _supply.sub((_supply.mul(uint256(self.percentBeingSold)))/100);
     
    uint256 _totalSupply = _supply.add(_bonusTokens);

     
    self.token = new InteractiveCrowdsaleToken(address(this),
                                               self.tokenInfo.name,
                                               self.tokenInfo.symbol,
                                               self.tokenInfo.decimals,
                                               _totalSupply);


    if(!self.isCanceled){
       
      self.token.transfer(self.owner, _ownerTokens);
    } else {
       
      self.token.transfer(self.owner, _supply);
      self.token.burnToken(_bonusTokens);
    }
     
    self.token.changeOwner(self.owner);
    self.startingTokenBalance = _supply.sub(_ownerTokens);

    return true;
  }

   
   
   
   
   
  function setCanceled(InteractiveCrowdsaleStorage storage self) private returns(bool){
    bool canceled = (self.totalValuation < self.minimumRaise) ||
                    ((now > (self.endTime + 30 days)) && !self.isFinalized);

    if(canceled) {self.isCanceled = true;}

    return self.isCanceled;
  }

   
   
   
   
   
  function retrieveFinalResult(InteractiveCrowdsaleStorage storage self) public returns (bool) {
    require(now > self.endTime);  
    require(self.personalCaps[msg.sender] > 0);  

    uint256 numTokens;  
    uint256 remainder;

    if(!self.isFinalized){
      require(setCanceled(self));
    }

    if (self.isCanceled) {
       
      self.leftoverWei[msg.sender] = self.leftoverWei[msg.sender].add(self.hasContributed[msg.sender]);
      self.hasContributed[msg.sender] = 0;
      LogErrorMsg(self.totalValuation, "Sale is canceled, all bids have been refunded!");
      return true;
    }

    if (self.personalCaps[msg.sender] < self.totalValuation) {

       
      self.leftoverWei[msg.sender] += self.hasContributed[msg.sender];

       
      self.hasContributed[msg.sender] = 0;

      return withdrawLeftoverWei(self);

    } else if (self.personalCaps[msg.sender] == self.totalValuation) {

       
      uint256 refundAmount = (self.q.mul(self.hasContributed[msg.sender]))/100;
      uint256 dust = (self.q.mul(self.hasContributed[msg.sender]))%100;

       
      self.leftoverWei[msg.sender] = self.leftoverWei[msg.sender].add(refundAmount);

       
      self.hasContributed[msg.sender] = self.hasContributed[msg.sender].sub(refundAmount);
      if(dust > 0) {
        self.leftoverWei[msg.sender] = self.leftoverWei[msg.sender].add(dust);
        self.hasContributed[msg.sender] = self.hasContributed[msg.sender].sub(dust);
      }
    }

     
    (numTokens, remainder) = calculateTokenPurchase(self.hasContributed[msg.sender],
                                                    self.pricePurchasedAt[msg.sender]);

    self.withdrawTokensMap[msg.sender] = self.withdrawTokensMap[msg.sender].add(numTokens);
    self.valueCommitted = self.valueCommitted.sub(remainder);
    self.hasContributed[msg.sender] = self.hasContributed[msg.sender].sub(remainder);
    self.leftoverWei[msg.sender] = self.leftoverWei[msg.sender].add(remainder);

     
    uint256 _fullBonus;
    uint256 _fullBonusPrice = (self.tokensPerEth.mul(self.priceBonusPercent.add(100)))/100;
    (_fullBonus, remainder) = calculateTokenPurchase(self.hasContributed[msg.sender], _fullBonusPrice);
    uint256 _leftoverBonus = _fullBonus.sub(numTokens);

    self.token.burnToken(_leftoverBonus);

    self.hasContributed[msg.sender] = 0;

     
    withdrawTokens(self);

    withdrawLeftoverWei(self);

  }

   
   
   
  function withdrawTokens(InteractiveCrowdsaleStorage storage self) public returns (bool) {
    bool ok;

    if (self.withdrawTokensMap[msg.sender] == 0) {
      LogErrorMsg(0, "Sender has no tokens to withdraw!");
      return false;
    }

    if (msg.sender == self.owner) {
      if(!self.isFinalized){
        LogErrorMsg(0, "Owner cannot withdraw extra tokens until after the sale!");
        return false;
      }
    }

    uint256 total = self.withdrawTokensMap[msg.sender];
    self.withdrawTokensMap[msg.sender] = 0;
    ok = self.token.transfer(msg.sender, total);
    require(ok);
    LogTokensWithdrawn(msg.sender, total);
    return true;
  }

   
   
   
  function withdrawLeftoverWei(InteractiveCrowdsaleStorage storage self) public returns (bool) {
    if (self.leftoverWei[msg.sender] == 0) {
      LogErrorMsg(0, "Sender has no extra wei to withdraw!");
      return false;
    }

    uint256 total = self.leftoverWei[msg.sender];
    self.leftoverWei[msg.sender] = 0;
    msg.sender.transfer(total);
    LogWeiWithdrawn(msg.sender, total);
    return true;
  }

   
   
   
  function withdrawOwnerEth(InteractiveCrowdsaleStorage storage self) public returns (bool) {
    require(msg.sender == self.owner);
    require(self.ownerBalance > 0);
    require(self.isFinalized);

    uint256 amount = self.ownerBalance;
    self.ownerBalance = 0;
    self.owner.transfer(amount);
    LogOwnerEthWithdrawn(msg.sender,amount,"Crowdsale owner has withdrawn all funds!");

    return true;
  }

  function crowdsaleIsActive(InteractiveCrowdsaleStorage storage self) public view returns (bool) {
    return (now >= self.startTime && now <= self.endTime);
  }

  function isBeforeWithdrawalLock(InteractiveCrowdsaleStorage storage self) public view returns (bool) {
    return now < self.endWithdrawalTime;
  }

  function isAfterWithdrawalLock(InteractiveCrowdsaleStorage storage self) public view returns (bool) {
    return now >= self.endWithdrawalTime;
  }

  function getPersonalCap(InteractiveCrowdsaleStorage storage self, address _bidder) public view returns (uint256) {
    return self.personalCaps[_bidder];
  }

}

pragma solidity 0.4.21;

 


library LinkedListLib {

    uint256 constant NULL = 0;
    uint256 constant HEAD = 0;
    bool constant PREV = false;
    bool constant NEXT = true;

    struct LinkedList{
        mapping (uint256 => mapping (bool => uint256)) list;
    }

     
     
    function listExists(LinkedList storage self)
        public
        view returns (bool)
    {
         
        if (self.list[HEAD][PREV] != HEAD || self.list[HEAD][NEXT] != HEAD) {
            return true;
        } else {
            return false;
        }
    }

     
     
     
    function nodeExists(LinkedList storage self, uint256 _node)
        public
        view returns (bool)
    {
        if (self.list[_node][PREV] == HEAD && self.list[_node][NEXT] == HEAD) {
            if (self.list[HEAD][NEXT] == _node) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

     
     
    function sizeOf(LinkedList storage self) public view returns (uint256 numElements) {
        bool exists;
        uint256 i;
        (exists,i) = getAdjacent(self, HEAD, NEXT);
        while (i != HEAD) {
            (exists,i) = getAdjacent(self, i, NEXT);
            numElements++;
        }
        return;
    }

     
     
     
    function getNode(LinkedList storage self, uint256 _node)
        public view returns (bool,uint256,uint256)
    {
        if (!nodeExists(self,_node)) {
            return (false,0,0);
        } else {
            return (true,self.list[_node][PREV], self.list[_node][NEXT]);
        }
    }

     
     
     
     
    function getAdjacent(LinkedList storage self, uint256 _node, bool _direction)
        public view returns (bool,uint256)
    {
        if (!nodeExists(self,_node)) {
            return (false,0);
        } else {
            return (true,self.list[_node][_direction]);
        }
    }

     
     
     
     
     
     
    function getSortedSpot(LinkedList storage self, uint256 _node, uint256 _value, bool _direction)
        public view returns (uint256)
    {
        if (sizeOf(self) == 0) { return 0; }
        require((_node == 0) || nodeExists(self,_node));
        bool exists;
        uint256 next;
        (exists,next) = getAdjacent(self, _node, _direction);
        while  ((next != 0) && (_value != next) && ((_value < next) != _direction)) next = self.list[next][_direction];
        return next;
    }

     
     
     
     
    function createLink(LinkedList storage self, uint256 _node, uint256 _link, bool _direction) private  {
        self.list[_link][!_direction] = _node;
        self.list[_node][_direction] = _link;
    }

     
     
     
     
     
    function insert(LinkedList storage self, uint256 _node, uint256 _new, bool _direction) internal returns (bool) {
        if(!nodeExists(self,_new) && nodeExists(self,_node)) {
            uint256 c = self.list[_node][_direction];
            createLink(self, _node, _new, _direction);
            createLink(self, _new, c, _direction);
            return true;
        } else {
            return false;
        }
    }

     
     
     
    function remove(LinkedList storage self, uint256 _node) internal returns (uint256) {
        if ((_node == NULL) || (!nodeExists(self,_node))) { return 0; }
        createLink(self, self.list[_node][PREV], self.list[_node][NEXT], NEXT);
        delete self.list[_node][PREV];
        delete self.list[_node][NEXT];
        return _node;
    }

     
     
     
     
    function push(LinkedList storage self, uint256 _node, bool _direction) internal  {
        insert(self, HEAD, _node, _direction);
    }

     
     
     
    function pop(LinkedList storage self, bool _direction) internal returns (uint256) {
        bool exists;
        uint256 adj;

        (exists,adj) = getAdjacent(self, HEAD, _direction);

        return remove(self, adj);
    }
}

library BasicMathLib {
   
   
   
   
   
   
  function times(uint256 a, uint256 b) public pure returns (bool err,uint256 res) {
    assembly{
      res := mul(a,b)
      switch or(iszero(b), eq(div(res,b), a))
      case 0 {
        err := 1
        res := 0
      }
    }
  }

   
   
   
   
   
   
  function dividedBy(uint256 a, uint256 b) public pure returns (bool err,uint256 i) {
    uint256 res;
    assembly{
      switch iszero(b)
      case 0 {
        res := div(a,b)
        let loc := mload(0x40)
        mstore(add(loc,0x20),res)
        i := mload(add(loc,0x20))
      }
      default {
        err := 1
        i := 0
      }
    }
  }

   
   
   
   
   
   
  function plus(uint256 a, uint256 b) public pure returns (bool err, uint256 res) {
    assembly{
      res := add(a,b)
      switch and(eq(sub(res,b), a), or(gt(res,b),eq(res,b)))
      case 0 {
        err := 1
        res := 0
      }
    }
  }

   
   
   
   
   
   
  function minus(uint256 a, uint256 b) public pure returns (bool err,uint256 res) {
    assembly{
      res := sub(a,b)
      switch eq(and(eq(add(res,b), a), or(lt(res,a), eq(res,a))), 1)
      case 0 {
        err := 1
        res := 0
      }
    }
  }
}

library TokenLib {
  using BasicMathLib for uint256;

  struct TokenStorage {
    bool initialized;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    string name;
    string symbol;
    uint256 totalSupply;
    uint256 initialSupply;
    address owner;
    uint8 decimals;
    bool stillMinting;
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event OwnerChange(address from, address to);
  event Burn(address indexed burner, uint256 value);
  event MintingClosed(bool mintingClosed);

   
   
   
   
   
   
   
  function init(TokenStorage storage self,
                address _owner,
                string _name,
                string _symbol,
                uint8 _decimals,
                uint256 _initial_supply,
                bool _allowMinting)
                public
  {
    require(!self.initialized);
    self.initialized = true;
    self.name = _name;
    self.symbol = _symbol;
    self.totalSupply = _initial_supply;
    self.initialSupply = _initial_supply;
    self.decimals = _decimals;
    self.owner = _owner;
    self.stillMinting = _allowMinting;
    self.balances[_owner] = _initial_supply;
  }

   
   
   
   
   
  function transfer(TokenStorage storage self, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    bool err;
    uint256 balance;

    (err,balance) = self.balances[msg.sender].minus(_value);
    require(!err);
    self.balances[msg.sender] = balance;
     
    self.balances[_to] = self.balances[_to] + _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
   
   
   
   
   
  function transferFrom(TokenStorage storage self,
                        address _from,
                        address _to,
                        uint256 _value)
                        public
                        returns (bool)
  {
    uint256 _allowance = self.allowed[_from][msg.sender];
    bool err;
    uint256 balanceOwner;
    uint256 balanceSpender;

    (err,balanceOwner) = self.balances[_from].minus(_value);
    require(!err);

    (err,balanceSpender) = _allowance.minus(_value);
    require(!err);

    self.balances[_from] = balanceOwner;
    self.allowed[_from][msg.sender] = balanceSpender;
    self.balances[_to] = self.balances[_to] + _value;

    emit Transfer(_from, _to, _value);
    return true;
  }

   
   
   
   
  function balanceOf(TokenStorage storage self, address _owner) public view returns (uint256 balance) {
    return self.balances[_owner];
  }

   
   
   
   
   
  function approve(TokenStorage storage self, address _spender, uint256 _value) public returns (bool) {
     
    require((_value == 0) || (self.allowed[msg.sender][_spender] == 0));

    self.allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
   
   
   
   
  function allowance(TokenStorage storage self, address _owner, address _spender)
                     public
                     view
                     returns (uint256 remaining) {
    return self.allowed[_owner][_spender];
  }

   
   
   
   
   
   
  function approveChange (TokenStorage storage self, address _spender, uint256 _valueChange, bool _increase)
                          public returns (bool)
  {
    uint256 _newAllowed;
    bool err;

    if(_increase) {
      (err, _newAllowed) = self.allowed[msg.sender][_spender].plus(_valueChange);
      require(!err);

      self.allowed[msg.sender][_spender] = _newAllowed;
    } else {
      if (_valueChange > self.allowed[msg.sender][_spender]) {
        self.allowed[msg.sender][_spender] = 0;
      } else {
        _newAllowed = self.allowed[msg.sender][_spender] - _valueChange;
        self.allowed[msg.sender][_spender] = _newAllowed;
      }
    }

    emit Approval(msg.sender, _spender, _newAllowed);
    return true;
  }

   
   
   
   
  function changeOwner(TokenStorage storage self, address _newOwner) public returns (bool) {
    require((self.owner == msg.sender) && (_newOwner > 0));

    self.owner = _newOwner;
    emit OwnerChange(msg.sender, _newOwner);
    return true;
  }

   
   
   
   
  function mintToken(TokenStorage storage self, uint256 _amount) public returns (bool) {
    require((self.owner == msg.sender) && self.stillMinting);
    uint256 _newAmount;
    bool err;

    (err, _newAmount) = self.totalSupply.plus(_amount);
    require(!err);

    self.totalSupply =  _newAmount;
    self.balances[self.owner] = self.balances[self.owner] + _amount;
    emit Transfer(0x0, self.owner, _amount);
    return true;
  }

   
   
   
  function closeMint(TokenStorage storage self) public returns (bool) {
    require(self.owner == msg.sender);

    self.stillMinting = false;
    emit MintingClosed(true);
    return true;
  }

   
   
   
   
  function burnToken(TokenStorage storage self, uint256 _amount) public returns (bool) {
      uint256 _newBalance;
      bool err;

      (err, _newBalance) = self.balances[msg.sender].minus(_amount);
      require(!err);

      self.balances[msg.sender] = _newBalance;
      self.totalSupply = self.totalSupply - _amount;
      emit Burn(msg.sender, _amount);
      emit Transfer(msg.sender, 0x0, _amount);
      return true;
  }
}

contract InteractiveCrowdsaleToken {
  using TokenLib for TokenLib.TokenStorage;

  TokenLib.TokenStorage public token;

   
  function InteractiveCrowdsaleToken(address owner,
                                     string name,
                                     string symbol,
                                     uint8 decimals,
                                     uint256 initialSupply) public
  {
    token.init(owner, name, symbol, decimals, initialSupply, false);
  }

  function name() public view returns (string) {
    return token.name;
  }

  function symbol() public view returns (string) {
    return token.symbol;
  }

  function decimals() public view returns (uint8) {
    return token.decimals;
  }

  function totalSupply() public view returns (uint256) {
    return token.totalSupply;
  }

  function initialSupply() public view returns (uint256) {
    return token.initialSupply;
  }

  function balanceOf(address who) public view returns (uint256) {
    return token.balanceOf(who);
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return token.allowance(owner, spender);
  }

  function transfer(address to, uint value) public returns (bool ok) {
    return token.transfer(to, value);
  }

  function transferFrom(address from, address to, uint value) public returns (bool ok) {
    return token.transferFrom(from, to, value);
  }

  function approve(address spender, uint value) public returns (bool ok) {
    return token.approve(spender, value);
  }

  function approveChange(address spender, uint256 valueChange, bool increase)
                         public returns (bool ok)
  {
    return token.approveChange(spender, valueChange, increase);
  }

  function changeOwner(address newOwner) public returns (bool ok) {
    return token.changeOwner(newOwner);
  }

  function mintToken(uint256 amount) public returns (bool ok) {
    return token.mintToken(amount);
  }

  function closeMint() public returns (bool ok) {
    return token.closeMint();
  }

  function burnToken(uint256 amount) public returns (bool ok) {
    return token.burnToken(amount);
  }
}

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