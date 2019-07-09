pragma solidity ^0.4.15;


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

 
 
contract DNNToken is StandardToken {

    using SafeMath for uint256;

     
     
     
    enum DNNSupplyAllocations {
        EarlyBackerSupplyAllocation,
        PRETDESupplyAllocation,
        TDESupplyAllocation,
        BountySupplyAllocation,
        WriterAccountSupplyAllocation,
        AdvisorySupplyAllocation,
        PlatformSupplyAllocation
    }

     
     
     
    address public allocatorAddress;
    address public crowdfundContract;

     
     
     
    string constant public name = "DNN";
    string constant public symbol = "DNN";
    uint8 constant public decimals = 18;  

     
     
     
    address public cofounderA;
    address public cofounderB;

     
     
     
    address public platform;

     
     
     
    uint256 public earlyBackerSupply;  
    uint256 public PRETDESupply;  
    uint256 public TDESupply;  
    uint256 public bountySupply;  
    uint256 public writerAccountSupply;  
    uint256 public advisorySupply;  
    uint256 public cofoundersSupply;  
    uint256 public platformSupply;  

    uint256 public earlyBackerSupplyRemaining;  
    uint256 public PRETDESupplyRemaining;  
    uint256 public TDESupplyRemaining;  
    uint256 public bountySupplyRemaining;  
    uint256 public writerAccountSupplyRemaining;  
    uint256 public advisorySupplyRemaining;  
    uint256 public cofoundersSupplyRemaining;  
    uint256 public platformSupplyRemaining;  

     
     
     
    uint256 public cofoundersSupplyVestingTranches = 10;
    uint256 public cofoundersSupplyVestingTranchesIssued = 0;
    uint256 public cofoundersSupplyVestingStartDate;  
    uint256 public cofoundersSupplyDistributed = 0;   

     
     
     
    bool public tokensLocked = true;

     
     
     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
     
     
    modifier CofoundersTokensVested()
    {
         
        require (cofoundersSupplyVestingStartDate != 0 && (now-cofoundersSupplyVestingStartDate) >= 4 weeks);

         
        uint256 currentTranche = now.sub(cofoundersSupplyVestingStartDate) / 4 weeks;

         
        uint256 issuedTranches = cofoundersSupplyVestingTranchesIssued;

         
        uint256 maxTranches = cofoundersSupplyVestingTranches;

         
         
        require (issuedTranches != maxTranches && currentTranche > issuedTranches);

        _;
    }

     
     
     
    modifier TokensUnlocked()
    {
        require (tokensLocked == false);
        _;
    }

     
     
     
    modifier TokensLocked()
    {
       require (tokensLocked == true);
       _;
    }

     
     
     
    modifier onlyCofounders()
    {
        require (msg.sender == cofounderA || msg.sender == cofounderB);
        _;
    }

     
     
     
    modifier onlyCofounderA()
    {
        require (msg.sender == cofounderA);
        _;
    }

     
     
     
    modifier onlyCofounderB()
    {
        require (msg.sender == cofounderB);
        _;
    }

     
     
     
    modifier onlyAllocator()
    {
        require (msg.sender == allocatorAddress);
        _;
    }

     
     
     
    modifier onlyCrowdfundContract()
    {
        require (msg.sender == crowdfundContract);
        _;
    }

     
     
     
    modifier onlyAllocatorOrCrowdfundContractOrPlatform()
    {
        require (msg.sender == allocatorAddress || msg.sender == crowdfundContract || msg.sender == platform);
        _;
    }

     
     
     
     
    function changePlatform(address newAddress)
        onlyCofounders
    {
        platform = newAddress;
    }

     
     
     
     
    function changeCrowdfundContract(address newAddress)
        onlyCofounders
    {
        crowdfundContract = newAddress;
    }

     
     
     
     
    function changeAllocator(address newAddress)
        onlyCofounders
    {
        allocatorAddress = newAddress;
    }

     
     
     
     
    function changeCofounderA(address newAddress)
        onlyCofounderA
    {
        cofounderA = newAddress;
    }

     
     
     
     
    function changeCofounderB(address newAddress)
        onlyCofounderB
    {
        cofounderB = newAddress;
    }


     
     
     
    function transfer(address _to, uint256 _value)
      TokensUnlocked
      returns (bool)
    {
          Transfer(msg.sender, _to, _value);
          return BasicToken.transfer(_to, _value);
    }

     
     
     
    function transferFrom(address _from, address _to, uint256 _value)
      TokensUnlocked
      returns (bool)
    {
          Transfer(_from, _to, _value);
          return StandardToken.transferFrom(_from, _to, _value);
    }


     
     
     
     
     
    function issueCofoundersTokensIfPossible()
        onlyCofounders
        CofoundersTokensVested
        returns (bool)
    {
         
        uint256 tokenCount = cofoundersSupply.div(cofoundersSupplyVestingTranches);

         
        if (tokenCount > cofoundersSupplyRemaining) {
           return false;
        }

         
        cofoundersSupplyRemaining = cofoundersSupplyRemaining.sub(tokenCount);

         
        cofoundersSupplyDistributed = cofoundersSupplyDistributed.add(tokenCount);

         
        balances[cofounderA] = balances[cofounderA].add(tokenCount.div(2));
        balances[cofounderB] = balances[cofounderB].add(tokenCount.div(2));

         
        cofoundersSupplyVestingTranchesIssued += 1;

        return true;
    }


     
     
     
    function issueTokens(address beneficiary, uint256 tokenCount, DNNSupplyAllocations allocationType)
      onlyAllocatorOrCrowdfundContractOrPlatform
      returns (bool)
    {
         
         
        bool canAllocatorPerform = msg.sender == allocatorAddress;
        bool canCrowdfundContractPerform = msg.sender == crowdfundContract;
        bool canPlatformPerform = msg.sender == platform;

         
        if (canAllocatorPerform && allocationType == DNNSupplyAllocations.EarlyBackerSupplyAllocation && tokenCount <= earlyBackerSupplyRemaining) {
            earlyBackerSupplyRemaining = earlyBackerSupplyRemaining.sub(tokenCount);
        }

         
        else if (canCrowdfundContractPerform && msg.sender == crowdfundContract && allocationType == DNNSupplyAllocations.PRETDESupplyAllocation) {

               
               
              if (PRETDESupplyRemaining >= tokenCount) {

                     
                    PRETDESupplyRemaining = PRETDESupplyRemaining.sub(tokenCount);
              }

               
              else if (PRETDESupplyRemaining+TDESupplyRemaining >= tokenCount) {

                     
                    TDESupplyRemaining = TDESupplyRemaining.sub(tokenCount-PRETDESupplyRemaining);

                     
                    PRETDESupplyRemaining = 0;
              }

               
              else {
                  return false;
              }
        }

         
        else if (canCrowdfundContractPerform && allocationType == DNNSupplyAllocations.TDESupplyAllocation && tokenCount <= TDESupplyRemaining) {
            TDESupplyRemaining = TDESupplyRemaining.sub(tokenCount);
        }

         
        else if (canAllocatorPerform && allocationType == DNNSupplyAllocations.BountySupplyAllocation && tokenCount <= bountySupplyRemaining) {
            bountySupplyRemaining = bountySupplyRemaining.sub(tokenCount);
        }

         
        else if (canAllocatorPerform && allocationType == DNNSupplyAllocations.WriterAccountSupplyAllocation && tokenCount <= writerAccountSupplyRemaining) {
            writerAccountSupplyRemaining = writerAccountSupplyRemaining.sub(tokenCount);
        }

         
        else if (canAllocatorPerform && allocationType == DNNSupplyAllocations.AdvisorySupplyAllocation && tokenCount <= advisorySupplyRemaining) {
            advisorySupplyRemaining = advisorySupplyRemaining.sub(tokenCount);
        }

         
        else if (canPlatformPerform && allocationType == DNNSupplyAllocations.PlatformSupplyAllocation && tokenCount <= platformSupplyRemaining) {
            platformSupplyRemaining = platformSupplyRemaining.sub(tokenCount);
        }

        else {
            return false;
        }

         
        Transfer(address(this), beneficiary, tokenCount);

         
        balances[beneficiary] = balances[beneficiary].add(tokenCount);

        return true;
    }

     
     
     
    function sendUnsoldTDETokensToPlatform()
      external
      onlyCrowdfundContract
    {
         
        if (TDESupplyRemaining > 0) {

             
            platformSupplyRemaining = platformSupplyRemaining.add(TDESupplyRemaining);

             
            TDESupplyRemaining = 0;
        }
    }

     
     
     
    function sendUnsoldPRETDETokensToTDE()
      external
      onlyCrowdfundContract
    {
           
          if (PRETDESupplyRemaining > 0) {

               
              TDESupplyRemaining = TDESupplyRemaining.add(PRETDESupplyRemaining);

               
              PRETDESupplyRemaining = 0;
        }
    }

     
     
     
    function unlockTokens()
        external
        onlyCrowdfundContract
    {
         
        require(tokensLocked == true);

        tokensLocked = false;
    }

     
     
     
    function DNNToken()
    {
           
          uint256 vestingStartDate = 1526072145;

           
          cofounderA = 0x3Cf26a9FE33C219dB87c2e50572e50803eFb2981;
          cofounderB = 0x9FFE2aD5D76954C7C25be0cEE30795279c4Cab9f;

           
          platform = address(this);

           
           
          totalSupply = uint256(1000000000).mul(uint256(10)**decimals);

           
          earlyBackerSupply = totalSupply.mul(10).div(100);  
          PRETDESupply = totalSupply.mul(10).div(100);  
          TDESupply = totalSupply.mul(40).div(100);  
          bountySupply = totalSupply.mul(1).div(100);  
          writerAccountSupply = totalSupply.mul(4).div(100);  
          advisorySupply = totalSupply.mul(14).div(100);  
          cofoundersSupply = totalSupply.mul(10).div(100);  
          platformSupply = totalSupply.mul(11).div(100);  

           
          earlyBackerSupplyRemaining = earlyBackerSupply;
          PRETDESupplyRemaining = PRETDESupply;
          TDESupplyRemaining = TDESupply;
          bountySupplyRemaining = bountySupply;
          writerAccountSupplyRemaining = writerAccountSupply;
          advisorySupplyRemaining = advisorySupply;
          cofoundersSupplyRemaining = cofoundersSupply;
          platformSupplyRemaining = platformSupply;

           
          cofoundersSupplyVestingStartDate = vestingStartDate >= now ? vestingStartDate : now;
    }
}

 
 
contract DNNTDE {

    using SafeMath for uint256;

     
     
     
    DNNToken public dnnToken;

     
     
     
    address public cofounderA;
    address public cofounderB;

     
     
     
    address public dnnHoldingMultisig;

     
     
     
    uint256 public TDEStartDate;   

     
     
     
    uint256 public TDEEndDate;   

     
     
     
    uint256 public tokenExchangeRateBase = 3000;  

     
     
     
    uint256 public tokensDistributed = 0;

     
     
     
    uint256 public minimumTDEContributionInWei = 0.001 ether;
    uint256 public minimumPRETDEContributionInWei = 5 ether;

     
     
     
    uint256 public maximumFundingGoalInETH;

     
     
     
    uint256 public fundsRaisedInWei = 0;
    uint256 public presaleFundsRaisedInWei = 0;
    uint256 public tdeFundsRaisedInWei = 0;

     
     
     
    mapping(address => uint256) ETHContributions;

     
     
     
    mapping(address => uint256) ETHContributorTokens;


     
     
     
    mapping(address => uint256) PRETDEContributorTokensPendingRelease;
    uint256 PRETDEContributorsTokensPendingCount = 0;  
    uint256 TokensPurchasedDuringPRETDE = 0;  


     
     
     
    bool public trickleDownBonusesReleased = false;
    uint256 public rangeETHAmount = 0;
    uint256 public bonusRangeCount = 4;

    uint256 public TDEContributorCount = 0;
    mapping(uint256 => address) public TDEContributorAddresses;
    mapping(address => uint256) public TDEContributorInitialBonusByAddress;

    uint256 public tokensIssuedForBonusRangeOne    = 0;
    uint256 public tokensIssuedForBonusRangeTwo    = 0;
    uint256 public tokensIssuedForBonusRangeThree  = 0;
    uint256 public tokensIssuedForBonusRangeFour   = 0;

     
     
     
    modifier HasTrickleDownBonusesNotBeenReleased() {
        require (trickleDownBonusesReleased == false);
        _;
    }

     
     
     
    modifier NoPRETDEContributorsAwaitingTokens() {
         
        require(PRETDEContributorsTokensPendingCount == 0);
        _;
    }

     
     
     
    modifier PRETDEContributorsAwaitingTokens() {

         
        require(PRETDEContributorsTokensPendingCount > 0);

        _;
    }

     
     
     
    modifier onlyCofounders() {
        require (msg.sender == cofounderA || msg.sender == cofounderB);
        _;
    }

     
     
     
    modifier onlyCofounderA() {
        require (msg.sender == cofounderA);
        _;
    }

     
     
     
    modifier onlyCofounderB() {
        require (msg.sender == cofounderB);
        _;
    }

     
     
     
    modifier TDEHasEnded() {
       require (now >= TDEEndDate || fundsRaisedInWei >= maximumFundingGoalInETH);
       _;
    }

     
     
     
    modifier ContributionIsAtLeastMinimum() {
        require (msg.value >= minimumTDEContributionInWei);
        _;
    }

     
     
     
    modifier ContributionDoesNotCauseGoalExceedance() {
       uint256 newFundsRaised = msg.value+fundsRaisedInWei;
       require (newFundsRaised <= maximumFundingGoalInETH);
       _;
    }

     
     
     
    modifier TDEBonusesDoesNotCauseTokenExceedance() {
       uint256 tokensDistributedPlusBonuses = getTokensDistributedPlusTrickleDownBonuses();
       require (tokensDistributedPlusBonuses < dnnToken.TDESupplyRemaining());
       _;
    }

     
     
     
    modifier HasPendingPRETDETokens(address _contributor) {
        require (PRETDEContributorTokensPendingRelease[_contributor] !=  0);
        _;
    }

     
     
     
    modifier IsNotAwaitingPRETDETokens(address _contributor) {
        require (PRETDEContributorTokensPendingRelease[_contributor] ==  0);
        _;
    }

     
     
     
     
    function changeCofounderA(address newAddress)
        onlyCofounderA
    {
        cofounderA = newAddress;
    }

     
     
     
     
    function changeCofounderB(address newAddress)
        onlyCofounderB
    {
        cofounderB = newAddress;
    }

     
     
     
    function getTokensDistributedPlusTrickleDownBonuses()
        constant
        returns (uint256)
    {
        return tokensIssuedForBonusRangeOne.mul(220).div(100) + tokensIssuedForBonusRangeTwo.mul(190).div(100) + tokensIssuedForBonusRangeThree.mul(150).div(100) + tokensIssuedForBonusRangeFour.mul(100).div(100);
    }

     
     
     
     
    function extendTDE(uint256 endDate)
        onlyCofounders
        returns (bool)
    {
         
         
        if (endDate > now && endDate > TDEEndDate) {
            TDEEndDate = endDate;
            return true;
        }

        return false;
    }

     
     
     
     
    function extendPRETDE(uint256 startDate)
        onlyCofounders
        returns (bool)
    {
         
         
        if (startDate > now && startDate > TDEStartDate) {
            TDEEndDate = TDEEndDate + (startDate-TDEStartDate);  
            TDEStartDate = startDate;  
            return true;
        }

        return false;
    }

     
     
     
     
    function changeDNNHoldingMultisig(address newAddress)
        onlyCofounders
    {
        dnnHoldingMultisig = newAddress;
    }

     
     
     
    function contributorETHBalance(address _owner)
      constant
      returns (uint256 balance)
    {
        return ETHContributions[_owner];
    }

     
     
     
    function isAwaitingPRETDETokens(address _contributorAddress)
       internal
       returns (bool)
    {
        return PRETDEContributorTokensPendingRelease[_contributorAddress] > 0;
    }

     
     
     
    function getPendingPresaleTokens(address _contributor)
        constant
        returns (uint256)
    {
        return PRETDEContributorTokensPendingRelease[_contributor];
    }

     
     
     
    function getCurrentTDEBonus()
        constant
        returns (uint256)
    {
        return getTDETokenExchangeRate(now);
    }


     
     
     
    function getCurrentPRETDEBonus()
        constant
        returns (uint256)
    {
        return getPRETDETokenExchangeRate(now);
    }

     
     
     
     
    function getTDETokenExchangeRate(uint256 timestamp)
        constant
        returns (uint256)
    {
         
        if (timestamp > TDEEndDate) {
            return uint256(0);
        }

         
        if (TDEStartDate > timestamp) {
            return uint256(0);
        }

         
        if (tdeFundsRaisedInWei <= rangeETHAmount) {
            return tokenExchangeRateBase.mul(120).div(100);
        }
         
        else if (tdeFundsRaisedInWei > rangeETHAmount && tdeFundsRaisedInWei <= rangeETHAmount.mul(2)) {
            return tokenExchangeRateBase.mul(130).div(100);
        }
         
        else if (tdeFundsRaisedInWei > rangeETHAmount.mul(2) && tdeFundsRaisedInWei <= rangeETHAmount.mul(3)) {
            return tokenExchangeRateBase.mul(140).div(100);
        }
         
        else if (tdeFundsRaisedInWei > rangeETHAmount.mul(3) && tdeFundsRaisedInWei <= maximumFundingGoalInETH) {
            return tokenExchangeRateBase.mul(150).div(100);
        }
        else {
            return tokenExchangeRateBase;
        }
    }

     
     
     
     
    function getPRETDETokenExchangeRate(uint256 weiamount)
        constant
        returns (uint256)
    {
         
        if (weiamount < minimumPRETDEContributionInWei) {
            return uint256(0);
        }

         
        if (weiamount >= minimumPRETDEContributionInWei && weiamount <= 199 ether) {
            return tokenExchangeRateBase + tokenExchangeRateBase.mul(25).div(100);

         
        } else if (weiamount >= 200 ether && weiamount <= 300 ether) {
            return tokenExchangeRateBase + tokenExchangeRateBase.mul(30).div(100);

         
        } else if (weiamount >= 301 ether && weiamount <= 2665 ether) {
            return tokenExchangeRateBase + tokenExchangeRateBase.mul(35).div(100);

         
        } else {
            return tokenExchangeRateBase + tokenExchangeRateBase.mul(50).div(100);
        }
    }

     
     
     
    function calculateTokens(uint256 weiamount, uint256 timestamp)
        constant
        returns (uint256)
    {
         
        uint256 computedTokensForPurchase = weiamount.mul(timestamp >= TDEStartDate ? getTDETokenExchangeRate(timestamp) : getPRETDETokenExchangeRate(weiamount));

         
        return computedTokensForPurchase;
     }


     
     
     
     
     
     
    function buyTokens()
        internal
        ContributionIsAtLeastMinimum
        ContributionDoesNotCauseGoalExceedance
        TDEBonusesDoesNotCauseTokenExceedance
        returns (bool)
    {
         
        uint256 tokenCount = calculateTokens(msg.value, now);

          
        if (tdeFundsRaisedInWei > rangeETHAmount.mul(3) && tdeFundsRaisedInWei <= maximumFundingGoalInETH) {
            if (TDEContributorInitialBonusByAddress[msg.sender] == 0) {
                TDEContributorInitialBonusByAddress[msg.sender] = tdeFundsRaisedInWei;
                TDEContributorAddresses[TDEContributorCount] = msg.sender;
                TDEContributorCount++;
            }
        }
         
        else if (tdeFundsRaisedInWei > rangeETHAmount.mul(2) && tdeFundsRaisedInWei <= rangeETHAmount.mul(3)) {
            if (TDEContributorInitialBonusByAddress[msg.sender] == 0) {
                TDEContributorInitialBonusByAddress[msg.sender] = rangeETHAmount.mul(3);
                TDEContributorAddresses[TDEContributorCount] = msg.sender;
                TDEContributorCount++;
            }
        }
         
        else if (tdeFundsRaisedInWei > rangeETHAmount && tdeFundsRaisedInWei <= rangeETHAmount.mul(2)) {
            if (TDEContributorInitialBonusByAddress[msg.sender] == 0) {
                TDEContributorInitialBonusByAddress[msg.sender] = rangeETHAmount.mul(2);
                TDEContributorAddresses[TDEContributorCount] = msg.sender;
                TDEContributorCount++;
            }
        }
         
        else if (tdeFundsRaisedInWei <= rangeETHAmount) {
            if (TDEContributorInitialBonusByAddress[msg.sender] == 0) {
                TDEContributorInitialBonusByAddress[msg.sender] = rangeETHAmount;
                TDEContributorAddresses[TDEContributorCount] = msg.sender;
                TDEContributorCount++;
            }
        }

         
         
        if (TDEContributorInitialBonusByAddress[msg.sender] == tdeFundsRaisedInWei) {
            tokensIssuedForBonusRangeFour = tokensIssuedForBonusRangeFour.add(tokenCount);
        }
         
        else if (TDEContributorInitialBonusByAddress[msg.sender] == rangeETHAmount.mul(3)) {
            tokensIssuedForBonusRangeThree = tokensIssuedForBonusRangeThree.add(tokenCount);
        }
         
        else if (TDEContributorInitialBonusByAddress[msg.sender] == rangeETHAmount.mul(2)) {
            tokensIssuedForBonusRangeTwo = tokensIssuedForBonusRangeTwo.add(tokenCount);
        }
         
        else if (TDEContributorInitialBonusByAddress[msg.sender] == rangeETHAmount) {
            tokensIssuedForBonusRangeOne = tokensIssuedForBonusRangeOne.add(tokenCount);
        }

         
        uint256 tokensDistributedPlusBonuses = getTokensDistributedPlusTrickleDownBonuses();

         
        if (tokensDistributedPlusBonuses > dnnToken.TDESupplyRemaining()) {
            revert();
        }

         
        tokensDistributed = tokensDistributed.add(tokenCount);

         
        ETHContributions[msg.sender] = ETHContributions[msg.sender].add(msg.value);

         
        ETHContributorTokens[msg.sender] = ETHContributorTokens[msg.sender].add(tokenCount);

         
        fundsRaisedInWei = fundsRaisedInWei.add(msg.value);

         
        tdeFundsRaisedInWei = tdeFundsRaisedInWei.add(msg.value);

         
        DNNToken.DNNSupplyAllocations allocationType = DNNToken.DNNSupplyAllocations.TDESupplyAllocation;

         
        if (!dnnToken.issueTokens(msg.sender, tokenCount, allocationType)) {
            revert();
        }

         
        dnnHoldingMultisig.transfer(msg.value);

        return true;
    }

     
     
     
     
     
    function buyPRETDETokensWithoutETH(address beneficiary, uint256 weiamount, uint256 tokenCount)
        onlyCofounders
        IsNotAwaitingPRETDETokens(beneficiary)
        returns (bool)
    {

           
          ETHContributorTokens[beneficiary] = ETHContributorTokens[beneficiary].add(tokenCount);

           
          ETHContributions[beneficiary] = ETHContributions[beneficiary].add(weiamount);

           
          fundsRaisedInWei = fundsRaisedInWei.add(weiamount);

           
          presaleFundsRaisedInWei = presaleFundsRaisedInWei.add(weiamount);

           
          PRETDEContributorTokensPendingRelease[beneficiary] = PRETDEContributorTokensPendingRelease[beneficiary].add(tokenCount);

           
          PRETDEContributorsTokensPendingCount += 1;

           
          return issuePRETDETokens(beneficiary);
      }

       
       
       
       
       
      function buyTDETokensWithoutETH(address beneficiary, uint256 weiamount, uint256 tokenCount)
          onlyCofounders
          returns (bool)
      {
             
            uint256 tokensDistributedPlusBonuses = tokenCount.add(getTokensDistributedPlusTrickleDownBonuses());

             
            if (tokensDistributedPlusBonuses > dnnToken.TDESupplyRemaining()) {
                revert();
            }

             
            ETHContributorTokens[beneficiary] = ETHContributorTokens[beneficiary].add(tokenCount);

             
            ETHContributions[beneficiary] = ETHContributions[beneficiary].add(weiamount);

             
            fundsRaisedInWei = fundsRaisedInWei.add(weiamount);

             
            tdeFundsRaisedInWei = tdeFundsRaisedInWei.add(weiamount);

             
            return issueTDETokens(beneficiary, tokenCount);
        }

       
       
       
       
      function issueTDETokens(address beneficiary, uint256 tokenCount)
          internal
          returns (bool)
      {

           
          tokensDistributed = tokensDistributed.add(tokenCount);

           
          DNNToken.DNNSupplyAllocations allocationType = DNNToken.DNNSupplyAllocations.TDESupplyAllocation;

           
          if (!dnnToken.issueTokens(beneficiary, tokenCount, allocationType)) {
              revert();
          }

          return true;
      }

     
     
     
     
    function issuePRETDETokens(address beneficiary)
        onlyCofounders
        PRETDEContributorsAwaitingTokens
        HasPendingPRETDETokens(beneficiary)
        returns (bool)
    {
         
        uint256 tokenCount = PRETDEContributorTokensPendingRelease[beneficiary];

         
        tokensDistributed = tokensDistributed.add(tokenCount);

         
        DNNToken.DNNSupplyAllocations allocationType = DNNToken.DNNSupplyAllocations.PRETDESupplyAllocation;

         
        if (!dnnToken.issueTokens(beneficiary, tokenCount, allocationType)) {
            revert();
        }

         
        PRETDEContributorsTokensPendingCount -= 1;

         
        PRETDEContributorTokensPendingRelease[beneficiary] = 0;

        return true;
    }

     
     
     
    function releaseTrickleDownBonuses()
      onlyCofounders
    {
         
        if (trickleDownBonusesReleased == false) {

             
            DNNToken.DNNSupplyAllocations allocationType = DNNToken.DNNSupplyAllocations.TDESupplyAllocation;

             
            address contributorAddress;

             
            uint256 bonusTokens;

             
            for (uint256 iteration=0; iteration < TDEContributorCount; iteration++) {

                 
                 
                bonusTokens = 0;

                 
                if (tdeFundsRaisedInWei > rangeETHAmount && tdeFundsRaisedInWei <= rangeETHAmount.mul(2)) {

                     
                    contributorAddress = TDEContributorAddresses[iteration];

                     
                    if (TDEContributorInitialBonusByAddress[contributorAddress] == rangeETHAmount) {
                        bonusTokens = ETHContributorTokens[contributorAddress].mul(130).div(100).sub(ETHContributorTokens[contributorAddress]);
                    }

                     
                    if (bonusTokens > 0 && !dnnToken.issueTokens(contributorAddress, bonusTokens, allocationType)) {
                        revert();
                    }
                }

                 
                else if (tdeFundsRaisedInWei > rangeETHAmount.mul(2) && tdeFundsRaisedInWei <= rangeETHAmount.mul(3)) {

                     
                    contributorAddress = TDEContributorAddresses[iteration];

                     
                    if (TDEContributorInitialBonusByAddress[contributorAddress] == rangeETHAmount) {
                        bonusTokens = ETHContributorTokens[contributorAddress].mul(170).div(100).sub(ETHContributorTokens[contributorAddress]);
                    }
                     
                    else if (TDEContributorInitialBonusByAddress[contributorAddress] == rangeETHAmount.mul(2)) {
                        bonusTokens = ETHContributorTokens[contributorAddress].mul(140).div(100).sub(ETHContributorTokens[contributorAddress]);
                    }

                     
                    if (bonusTokens > 0 && !dnnToken.issueTokens(contributorAddress, bonusTokens, allocationType)) {
                        revert();
                    }
                }

                 
                else if (tdeFundsRaisedInWei > rangeETHAmount.mul(3)) {

                     
                    contributorAddress = TDEContributorAddresses[iteration];

                     
                    if (TDEContributorInitialBonusByAddress[contributorAddress] == rangeETHAmount) {
                        bonusTokens = ETHContributorTokens[contributorAddress].mul(220).div(100).sub(ETHContributorTokens[contributorAddress]);
                    }
                     
                    else if (TDEContributorInitialBonusByAddress[contributorAddress] == rangeETHAmount.mul(2)) {
                        bonusTokens = ETHContributorTokens[contributorAddress].mul(190).div(100).sub(ETHContributorTokens[contributorAddress]);
                    }
                     
                    else if (TDEContributorInitialBonusByAddress[contributorAddress] == rangeETHAmount.mul(3)) {
                        bonusTokens = ETHContributorTokens[contributorAddress].mul(150).div(100).sub(ETHContributorTokens[contributorAddress]);
                    }

                     
                    if (bonusTokens > 0 && !dnnToken.issueTokens(contributorAddress, bonusTokens, allocationType)) {
                        revert();
                    }
                }
            }

             
            trickleDownBonusesReleased = true;
        }
    }

     
     
     
    function finalizeTDE()
       onlyCofounders
       TDEHasEnded
    {
         
         
        require(dnnToken.tokensLocked() == true && dnnToken.PRETDESupplyRemaining() == 0);

         
        releaseTrickleDownBonuses();

         
        dnnToken.unlockTokens();

         
        tokensDistributed += dnnToken.TDESupplyRemaining();

         
        dnnToken.sendUnsoldTDETokensToPlatform();
    }


     
     
     
    function finalizePRETDE()
       onlyCofounders
       NoPRETDEContributorsAwaitingTokens
    {
         
        require(dnnToken.PRETDESupplyRemaining() > 0);

         
        dnnToken.sendUnsoldPRETDETokensToTDE();
    }


     
     
     
    function DNNTDE()
    {
         
        uint256 hardCap = 35000;

         
        dnnToken = DNNToken(0x9D9832d1beb29CC949d75D61415FD00279f84Dc2);

         
        cofounderA = 0x3Cf26a9FE33C219dB87c2e50572e50803eFb2981;
        cofounderB = 0x9FFE2aD5D76954C7C25be0cEE30795279c4Cab9f;

         
        dnnHoldingMultisig = 0x5980a47514a0Af79a8d2F6276f8673a006ec9929;

         
        maximumFundingGoalInETH = hardCap * 1 ether;

         
        rangeETHAmount = hardCap.div(bonusRangeCount) * 1 ether;

         
        TDEStartDate = 1529020801;

         
         
        TDEEndDate = (TDEStartDate + 35 days);
    }

     
     
     
    function () payable {

         
         
         
        if (now < TDEStartDate && msg.value >= minimumPRETDEContributionInWei && PRETDEContributorTokensPendingRelease[msg.sender] == 0) {

             
            ETHContributions[msg.sender] = ETHContributions[msg.sender].add(msg.value);

             
            fundsRaisedInWei = fundsRaisedInWei.add(msg.value);

             
            presaleFundsRaisedInWei = presaleFundsRaisedInWei.add(msg.value);

             
            PRETDEContributorTokensPendingRelease[msg.sender] = PRETDEContributorTokensPendingRelease[msg.sender].add(calculateTokens(msg.value, now));

             
            TokensPurchasedDuringPRETDE += calculateTokens(msg.value, now);

             
            PRETDEContributorsTokensPendingCount += 1;

             
            if (TokensPurchasedDuringPRETDE > dnnToken.TDESupplyRemaining()+dnnToken.PRETDESupplyRemaining()) {
                revert();
            }

             
            dnnHoldingMultisig.transfer(msg.value);
        }

         
        else if (now >= TDEStartDate && now < TDEEndDate) buyTokens();

         
        else revert();
    }
}