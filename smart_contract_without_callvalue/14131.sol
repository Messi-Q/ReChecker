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

contract SoccerGamblingV_QIU is Ownable {

    using SafeMath for uint;

    struct BettingInfo {
        uint id;
        address bettingOwner;
        bool buyHome;
        bool buyAway;
        bool buyDraw;
        uint bettingAmount;
    }
    
    struct GamblingPartyInfo {
        uint id;
        address dealerAddress;  
        uint homePayRate;
        uint awayPayRate;
        uint drawPayRate;
        uint payRateScale;
        uint bonusPool;  
        uint baseBonusPool;
        int finalScoreHome;
        int finalScoreAway;
        bool isEnded;
        bool isLockedForBet;
        BettingInfo[] bettingsInfo;
    }

    mapping (uint => GamblingPartyInfo) public gamblingPartiesInfo;
    mapping (uint => uint[]) public matchId2PartyId;
    uint private _nextGamblingPartyId;
    uint private _nextBettingInfoId;
    QIUToken public _internalToken;

    uint private _commissionNumber;
    uint private _commissionScale;
    

    function SoccerGamblingV_QIU(QIUToken _tokenAddress) public {
        _nextGamblingPartyId = 0;
        _nextBettingInfoId = 0;
        _internalToken = _tokenAddress;
        _commissionNumber = 2;
        _commissionScale = 100;
    }

    function modifyCommission(uint number,uint scale) public onlyOwner returns(bool){
        _commissionNumber = number;
        _commissionScale = scale;
        return true;
    }

    function _availableBetting(uint gamblingPartyId,uint8 buySide,uint bettingAmount) private view returns(bool) {
        GamblingPartyInfo storage gpInfo = gamblingPartiesInfo[gamblingPartyId];
        uint losePay = 0;
        if (buySide==0)
            losePay = losePay.add((gpInfo.homePayRate.mul(bettingAmount)).div(gpInfo.payRateScale));
        else if (buySide==1)
            losePay = losePay.add((gpInfo.awayPayRate.mul(bettingAmount)).div(gpInfo.payRateScale));
        else if (buySide==2)
            losePay = losePay.add((gpInfo.drawPayRate.mul(bettingAmount)).div(gpInfo.payRateScale));
        uint mostPay = 0;
        for (uint idx = 0; idx<gpInfo.bettingsInfo.length; idx++) {
            BettingInfo storage bInfo = gpInfo.bettingsInfo[idx];
            if (bInfo.buyHome && (buySide==0))
                mostPay = mostPay.add((gpInfo.homePayRate.mul(bInfo.bettingAmount)).div(gpInfo.payRateScale));
            else if (bInfo.buyAway && (buySide==1))
                mostPay = mostPay.add((gpInfo.awayPayRate.mul(bInfo.bettingAmount)).div(gpInfo.payRateScale));
            else if (bInfo.buyDraw && (buySide==2))
                mostPay = mostPay.add((gpInfo.drawPayRate.mul(bInfo.bettingAmount)).div(gpInfo.payRateScale));
        }
        if (mostPay + losePay > gpInfo.bonusPool)
            return false;
        else 
            return true;
    }

    event NewBettingSucceed(address fromAddr,uint newBettingInfoId);
    function betting(uint gamblingPartyId,uint8 buySide,uint bettingAmount) public {
        require(bettingAmount > 0);
        require(_internalToken.balanceOf(msg.sender) >= bettingAmount);
        GamblingPartyInfo storage gpInfo = gamblingPartiesInfo[gamblingPartyId];
        require(gpInfo.isEnded == false);
        require(gpInfo.isLockedForBet == false);
        require(_availableBetting(gamblingPartyId, buySide, bettingAmount));
        BettingInfo memory bInfo;
        bInfo.id = _nextBettingInfoId;
        bInfo.bettingOwner = msg.sender;
        bInfo.buyHome = false;
        bInfo.buyAway = false;
        bInfo.buyDraw = false;
        bInfo.bettingAmount = bettingAmount;
        if (buySide == 0)
            bInfo.buyHome = true;
        if (buySide == 1)
            bInfo.buyAway = true;
        if (buySide == 2)
            bInfo.buyDraw = true;
        _internalToken.originTransfer(this,bettingAmount);
        gpInfo.bettingsInfo.push(bInfo);
        _nextBettingInfoId++;
        gpInfo.bonusPool = gpInfo.bonusPool.add(bettingAmount);
        NewBettingSucceed(msg.sender,bInfo.id);
    }

    function remainingBettingFor(uint gamblingPartyId) public view returns
        (uint remainingAmountHome,
         uint remainingAmountAway,
         uint remainingAmountDraw
        ) {
        for (uint8 buySide = 0;buySide<3;buySide++){
            GamblingPartyInfo storage gpInfo = gamblingPartiesInfo[gamblingPartyId];
            uint bonusPool = gpInfo.bonusPool;
            for (uint idx = 0; idx<gpInfo.bettingsInfo.length; idx++) {
                BettingInfo storage bInfo = gpInfo.bettingsInfo[idx];
                if (bInfo.buyHome && (buySide==0))
                    bonusPool = bonusPool.sub((gpInfo.homePayRate.mul(bInfo.bettingAmount)).div(gpInfo.payRateScale));
                else if (bInfo.buyAway && (buySide==1))
                    bonusPool = bonusPool.sub((gpInfo.awayPayRate.mul(bInfo.bettingAmount)).div(gpInfo.payRateScale));
                else if (bInfo.buyDraw && (buySide==2))
                    bonusPool = bonusPool.sub((gpInfo.drawPayRate.mul(bInfo.bettingAmount)).div(gpInfo.payRateScale));
            }
            if (buySide == 0)
                remainingAmountHome = (bonusPool.mul(gpInfo.payRateScale)).div(gpInfo.homePayRate);
            else if (buySide == 1)
                remainingAmountAway = (bonusPool.mul(gpInfo.payRateScale)).div(gpInfo.awayPayRate);
            else if (buySide == 2)
                remainingAmountDraw = (bonusPool.mul(gpInfo.payRateScale)).div(gpInfo.drawPayRate);
        }
    }

    event MatchAllGPsLock(address fromAddr,uint matchId,bool isLocked);
    function lockUnlockMatchGPForBetting(uint matchId,bool lock) public {
        uint[] storage gamblingPartyIds = matchId2PartyId[matchId];
        for (uint idx = 0;idx < gamblingPartyIds.length;idx++) {
            lockUnlockGamblingPartyForBetting(gamblingPartyIds[idx],lock);
        }
        MatchAllGPsLock(msg.sender,matchId,lock);        
    }

    function lockUnlockGamblingPartyForBetting(uint gamblingPartyId,bool lock) public onlyOwner {
        GamblingPartyInfo storage gpInfo = gamblingPartiesInfo[gamblingPartyId];
        gpInfo.isLockedForBet = lock;
    }

    function getGamblingPartyInfo(uint gamblingPartyId) public view returns (uint gpId,
                                                                            address dealerAddress,
                                                                            uint homePayRate,
                                                                            uint awayPayRate,
                                                                            uint drawPayRate,
                                                                            uint payRateScale,
                                                                            uint bonusPool,
                                                                            int finalScoreHome,
                                                                            int finalScoreAway,
                                                                            bool isEnded) 
    {

        GamblingPartyInfo storage gpInfo = gamblingPartiesInfo[gamblingPartyId];
        gpId = gpInfo.id;
        dealerAddress = gpInfo.dealerAddress;  
        homePayRate = gpInfo.homePayRate;
        awayPayRate = gpInfo.awayPayRate;
        drawPayRate = gpInfo.drawPayRate;
        payRateScale = gpInfo.payRateScale;
        bonusPool = gpInfo.bonusPool;  
        finalScoreHome = gpInfo.finalScoreHome;
        finalScoreAway = gpInfo.finalScoreAway;
        isEnded = gpInfo.isEnded;
    }

     
     
     
    function getGamblingPartySummarizeInfo(uint gamblingPartyId) public view returns(
        uint gpId,
         
        uint homeSalesAmount,
        int  homeSalesEarnings,
        uint awaySalesAmount,
        int  awaySalesEarnings,
        uint drawSalesAmount,
        int  drawSalesEarnings,
        int  dealerEarnings,
        uint baseBonusPool
    ){
        GamblingPartyInfo storage gpInfo = gamblingPartiesInfo[gamblingPartyId];
        gpId = gpInfo.id;
        baseBonusPool = gpInfo.baseBonusPool;
        for (uint idx = 0; idx < gpInfo.bettingsInfo.length; idx++) {
            BettingInfo storage bInfo = gpInfo.bettingsInfo[idx];
            if (bInfo.buyHome){
                homeSalesAmount += bInfo.bettingAmount;
                if (gpInfo.isEnded && (gpInfo.finalScoreHome > gpInfo.finalScoreAway)){
                    homeSalesEarnings = homeSalesEarnings - int(bInfo.bettingAmount*gpInfo.homePayRate/gpInfo.payRateScale);
                }else
                    homeSalesEarnings += int(bInfo.bettingAmount);
            } else if (bInfo.buyAway){
                awaySalesAmount += bInfo.bettingAmount;
                if (gpInfo.isEnded && (gpInfo.finalScoreHome < gpInfo.finalScoreAway)){
                    awaySalesEarnings = awaySalesEarnings - int(bInfo.bettingAmount*gpInfo.awayPayRate/gpInfo.payRateScale);
                }else
                    awaySalesEarnings += int(bInfo.bettingAmount);
            } else if (bInfo.buyDraw){
                drawSalesAmount += bInfo.bettingAmount;
                if (gpInfo.isEnded && (gpInfo.finalScoreHome == gpInfo.finalScoreAway)){
                    drawSalesEarnings = drawSalesEarnings - int(bInfo.bettingAmount*gpInfo.drawPayRate/gpInfo.payRateScale);
                }else
                    drawSalesEarnings += int(bInfo.bettingAmount);
            }
        }
        int commission;    
        if(gpInfo.isEnded){
            dealerEarnings = int(gpInfo.bonusPool);
        }else{
            dealerEarnings = int(gpInfo.bonusPool);
            return;
        }
        if (homeSalesEarnings > 0){
            commission = homeSalesEarnings * int(_commissionNumber) / int(_commissionScale);
            homeSalesEarnings -= commission;
        }
        if (awaySalesEarnings > 0){
            commission = awaySalesEarnings * int(_commissionNumber) / int(_commissionScale);
            awaySalesEarnings -= commission;
        }
        if (drawSalesEarnings > 0){
            commission = drawSalesEarnings * int(_commissionNumber) / int(_commissionScale);
            drawSalesEarnings -= commission;
        }
        if (homeSalesEarnings < 0)
            dealerEarnings = int(gpInfo.bonusPool) + homeSalesEarnings;
        if (awaySalesEarnings < 0)
            dealerEarnings = int(gpInfo.bonusPool) + awaySalesEarnings;
        if (drawSalesEarnings < 0)
            dealerEarnings = int(gpInfo.bonusPool) + drawSalesEarnings;
        commission = dealerEarnings * int(_commissionNumber) / int(_commissionScale);
        dealerEarnings -= commission;
    }

    function getMatchSummarizeInfo(uint matchId) public view returns (
                                                            uint mSalesAmount,
                                                            uint mHomeSalesAmount,
                                                            uint mAwaySalesAmount,
                                                            uint mDrawSalesAmount,
                                                            int mDealerEarnings,
                                                            uint mBaseBonusPool
                                                        )
    {
        for (uint idx = 0; idx<matchId2PartyId[matchId].length; idx++) {
            uint gamblingPartyId = matchId2PartyId[matchId][idx];
            var (,homeSalesAmount,,awaySalesAmount,,drawSalesAmount,,dealerEarnings,baseBonusPool) = getGamblingPartySummarizeInfo(gamblingPartyId);
            mHomeSalesAmount += homeSalesAmount;
            mAwaySalesAmount += awaySalesAmount;
            mDrawSalesAmount += drawSalesAmount;
            mSalesAmount += homeSalesAmount + awaySalesAmount + drawSalesAmount;
            mDealerEarnings += dealerEarnings;
            mBaseBonusPool = baseBonusPool;
        }
    }

    function getSumOfGamblingPartiesBonusPool(uint matchId) public view returns (uint) {
        uint sum = 0;
        for (uint idx = 0; idx<matchId2PartyId[matchId].length; idx++) {
            uint gamblingPartyId = matchId2PartyId[matchId][idx];
            GamblingPartyInfo storage gpInfo = gamblingPartiesInfo[gamblingPartyId];
            sum += gpInfo.bonusPool;
        }
        return sum;
    }

    function getWinLoseAmountByBettingOwnerInGamblingParty(uint gamblingPartyId,address bettingOwner) public view returns (int) {
        int winLose = 0;
        GamblingPartyInfo storage gpInfo = gamblingPartiesInfo[gamblingPartyId];
        require(gpInfo.isEnded);
        for (uint idx = 0; idx < gpInfo.bettingsInfo.length; idx++) {
            BettingInfo storage bInfo = gpInfo.bettingsInfo[idx];
            if (bInfo.bettingOwner == bettingOwner) {
                if ((gpInfo.finalScoreHome > gpInfo.finalScoreAway) && (bInfo.buyHome)) {
                    winLose += int(gpInfo.homePayRate * bInfo.bettingAmount / gpInfo.payRateScale);
                } else if ((gpInfo.finalScoreHome < gpInfo.finalScoreAway) && (bInfo.buyAway)) {
                    winLose += int(gpInfo.awayPayRate * bInfo.bettingAmount / gpInfo.payRateScale);
                } else if ((gpInfo.finalScoreHome == gpInfo.finalScoreAway) && (bInfo.buyDraw)) {
                    winLose += int(gpInfo.drawPayRate * bInfo.bettingAmount / gpInfo.payRateScale);
                } else {
                    winLose -= int(bInfo.bettingAmount);
                }
            }
        }   
        if (winLose > 0){
            int commission = winLose * int(_commissionNumber) / int(_commissionScale);
            winLose -= commission;
        }
        return winLose;
    }

    function getWinLoseAmountByBettingIdInGamblingParty(uint gamblingPartyId,uint bettingId) public view returns (int) {
        int winLose = 0;
        GamblingPartyInfo storage gpInfo = gamblingPartiesInfo[gamblingPartyId];
        require(gpInfo.isEnded);
        for (uint idx = 0; idx < gpInfo.bettingsInfo.length; idx++) {
            BettingInfo storage bInfo = gpInfo.bettingsInfo[idx];
            if (bInfo.id == bettingId) {
                if ((gpInfo.finalScoreHome > gpInfo.finalScoreAway) && (bInfo.buyHome)) {
                    winLose += int(gpInfo.homePayRate * bInfo.bettingAmount / gpInfo.payRateScale);
                } else if ((gpInfo.finalScoreHome < gpInfo.finalScoreAway) && (bInfo.buyAway)) {
                    winLose += int(gpInfo.awayPayRate * bInfo.bettingAmount / gpInfo.payRateScale);
                } else if ((gpInfo.finalScoreHome == gpInfo.finalScoreAway) && (bInfo.buyDraw)) {
                    winLose += int(gpInfo.drawPayRate * bInfo.bettingAmount / gpInfo.payRateScale);
                } else {
                    winLose -= int(bInfo.bettingAmount);
                }
                break;
            }
        }   
        if (winLose > 0){
            int commission = winLose * int(_commissionNumber) / int(_commissionScale);
            winLose -= commission;
        }
        return winLose;
    }

    event NewGamblingPartyFounded(address fromAddr,uint newGPId);
    function foundNewGamblingParty(
        uint matchId,
        uint homePayRate,
        uint awayPayRate,
        uint drawPayRate,
        uint payRateScale,
        uint basePool
        ) public
        {
        address sender = msg.sender;
        require(basePool > 0);
        require(_internalToken.balanceOf(sender) >= basePool);
        uint newId = _nextGamblingPartyId;
        gamblingPartiesInfo[newId].id = newId;
        gamblingPartiesInfo[newId].dealerAddress = sender;
        gamblingPartiesInfo[newId].homePayRate = homePayRate;
        gamblingPartiesInfo[newId].awayPayRate = awayPayRate;
        gamblingPartiesInfo[newId].drawPayRate = drawPayRate;
        gamblingPartiesInfo[newId].payRateScale = payRateScale;
        gamblingPartiesInfo[newId].bonusPool = basePool;
        gamblingPartiesInfo[newId].baseBonusPool = basePool;
        gamblingPartiesInfo[newId].finalScoreHome = -1;
        gamblingPartiesInfo[newId].finalScoreAway = -1;
        gamblingPartiesInfo[newId].isEnded = false;
        gamblingPartiesInfo[newId].isLockedForBet = false;
        _internalToken.originTransfer(this,basePool);
        matchId2PartyId[matchId].push(gamblingPartiesInfo[newId].id);
        _nextGamblingPartyId++;
        NewGamblingPartyFounded(sender,newId); 
    }

    event MatchAllGPsEnded(address fromAddr,uint matchId);
    function endMatch(uint matchId,int homeScore,int awayScore) public {
        uint[] storage gamblingPartyIds = matchId2PartyId[matchId];
        for (uint idx = 0;idx < gamblingPartyIds.length;idx++) {
            endGamblingParty(gamblingPartyIds[idx],homeScore,awayScore);
        }
        MatchAllGPsEnded(msg.sender,matchId);        
    }

    event GamblingPartyEnded(address fromAddr,uint gamblingPartyId);
    function endGamblingParty(uint gamblingPartyId,int homeScore,int awayScore) public onlyOwner {
        GamblingPartyInfo storage gpInfo = gamblingPartiesInfo[gamblingPartyId];
        require(!gpInfo.isEnded);
        gpInfo.finalScoreHome = homeScore;
        gpInfo.finalScoreAway = awayScore;
        gpInfo.isEnded = true;
        int flag = -1;
        if (homeScore > awayScore)
            flag = 0;
        else if (homeScore < awayScore)
            flag = 1;
        else
            flag = 2;
        uint commission;  
        uint bonusPool = gpInfo.bonusPool;
        for (uint idx = 0; idx < gpInfo.bettingsInfo.length; idx++) {
            BettingInfo storage bInfo = gpInfo.bettingsInfo[idx];
            uint transferAmount = 0;
            if (flag == 0 && bInfo.buyHome)
                transferAmount = (gpInfo.homePayRate.mul(bInfo.bettingAmount)).div(gpInfo.payRateScale);
            if (flag == 1 && bInfo.buyAway)
                transferAmount = (gpInfo.awayPayRate.mul(bInfo.bettingAmount)).div(gpInfo.payRateScale);
            if (flag == 2 && bInfo.buyDraw)
                transferAmount = (gpInfo.drawPayRate.mul(bInfo.bettingAmount)).div(gpInfo.payRateScale);
            if (transferAmount != 0) {
                bonusPool = bonusPool.sub(transferAmount);
                commission = (transferAmount.mul(_commissionNumber)).div(_commissionScale);
                transferAmount = transferAmount.sub(commission);
                _internalToken.ownerTransferFrom(this,bInfo.bettingOwner,transferAmount);
                _internalToken.ownerTransferFrom(this,owner,commission);
            }
        }    
        if (bonusPool > 0) {
            uint amount = bonusPool;
             
            commission = (amount.mul(_commissionNumber)).div(_commissionScale);
            amount = amount.sub(commission);
            _internalToken.ownerTransferFrom(this,gpInfo.dealerAddress,amount);
            _internalToken.ownerTransferFrom(this,owner,commission);
        }
        GamblingPartyEnded(msg.sender,gpInfo.id);
    }

    function getETHBalance() public view returns (uint) {
        return this.balance;  
    }
}