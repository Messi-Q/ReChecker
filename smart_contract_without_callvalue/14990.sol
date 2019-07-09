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