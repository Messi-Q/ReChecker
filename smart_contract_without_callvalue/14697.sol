pragma solidity 0.4.18;

 
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



 
library StateMachineLib {

    struct Stage {
         
        bytes32 nextId;

         
        mapping(bytes4 => bool) allowedFunctions;
    }

    struct State {
         
        bytes32 currentStageId;

         
        function(bytes32) internal onTransition;

         
        mapping(bytes32 => bool) validStage;

         
        mapping(bytes32 => Stage) stages;
    }

     
     
    function setInitialStage(State storage self, bytes32 stageId) internal {
        self.validStage[stageId] = true;
        self.currentStageId = stageId;
    }

     
     
     
    function createTransition(State storage self, bytes32 fromId, bytes32 toId) internal {
        require(self.validStage[fromId]);

        Stage storage from = self.stages[fromId];

         
        if (from.nextId != 0) {
            self.validStage[from.nextId] = false;
            delete self.stages[from.nextId];
        }

        from.nextId = toId;
        self.validStage[toId] = true;
    }

     
    function goToNextStage(State storage self) internal {
        Stage storage current = self.stages[self.currentStageId];

        require(self.validStage[current.nextId]);

        self.currentStageId = current.nextId;

        self.onTransition(current.nextId);
    }

     
     
     
    function checkAllowedFunction(State storage self, bytes4 selector) internal constant returns(bool) {
        return self.stages[self.currentStageId].allowedFunctions[selector];
    }

     
     
     
    function allowFunction(State storage self, bytes32 stageId, bytes4 selector) internal {
        require(self.validStage[stageId]);
        self.stages[stageId].allowedFunctions[selector] = true;
    }


}



contract StateMachine {
    using StateMachineLib for StateMachineLib.State;

    event LogTransition(bytes32 indexed stageId, uint256 blockNumber);

    StateMachineLib.State internal state;

     
    modifier checkAllowed {
        conditionalTransitions();
        require(state.checkAllowedFunction(msg.sig));
        _;
    }

    function StateMachine() public {
         
        state.onTransition = onTransition;
    }

     
     
    function getCurrentStageId() public view returns(bytes32) {
        return state.currentStageId;
    }

     
    function conditionalTransitions() public {

        bytes32 nextId = state.stages[state.currentStageId].nextId;

        while (state.validStage[nextId]) {
            StateMachineLib.Stage storage next = state.stages[nextId];
             
            if (startConditions(nextId)) {
                state.goToNextStage();
                nextId = next.nextId;
            } else {
                break;
            }
        }
    }

     
     
    function startConditions(bytes32) internal constant returns(bool) {
        return false;
    }

     
    function onTransition(bytes32 stageId) internal {
        LogTransition(stageId, block.number);
    }


}

 
contract TimedStateMachine is StateMachine {

    event LogSetStageStartTime(bytes32 indexed stageId, uint256 startTime);

     
    mapping(bytes32 => uint256) internal startTime;

     
    function startConditions(bytes32 stageId) internal constant returns(bool) {
         
        uint256 start = startTime[stageId];
         
        return start != 0 && block.timestamp > start;
    }

     
     
     
    function setStageStartTime(bytes32 stageId, uint256 timestamp) internal {
        require(state.validStage[stageId]);
        require(timestamp > block.timestamp);

        startTime[stageId] = timestamp;
        LogSetStageStartTime(stageId, timestamp);
    }

     
     
    function getStageStartTime(bytes32 stageId) public view returns(uint256) {
        return startTime[stageId];
    }
}

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

contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
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

 

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

   
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

   
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


contract ERC223Basic is ERC20Basic {

     
    function transfer(address _to, uint _value, bytes _data) public returns (bool);

     
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _value, bytes _data);
}

 
contract ERC223ReceivingContract {

     
     
     
     
    function tokenFallback(address _from, uint _value, bytes _data);

}

 
contract ERC223BasicToken is ERC223Basic, BasicToken {

     
    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
         
         
        uint codeLength;

        assembly {
             
            codeLength := extcodesize(_to)
        }

        require(super.transfer(_to, _value));

        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }

       
    function transfer(address _to, uint256 _value) public returns (bool) {
        bytes memory empty;
        require(transfer(_to, _value, empty));
        return true;
    }

}



 
contract PryzeToken is DetailedERC20, MintableToken, ERC223BasicToken {
    string constant NAME = "Pryze";
    string constant SYMBOL = "PRYZ";
    uint8 constant DECIMALS = 18;

     
    function PryzeToken()
        DetailedERC20(NAME, SYMBOL, DECIMALS)
        public
    {}
}



contract Whitelistable is Ownable {
    
    event LogUserRegistered(address indexed sender, address indexed userAddress);
    event LogUserUnregistered(address indexed sender, address indexed userAddress);
    
    mapping(address => bool) public whitelisted;

    function registerUser(address userAddress) 
        public 
        onlyOwner 
    {
        require(userAddress != 0);
        whitelisted[userAddress] = true;
        LogUserRegistered(msg.sender, userAddress);
    }

    function unregisterUser(address userAddress) 
        public 
        onlyOwner 
    {
        require(whitelisted[userAddress] == true);
        whitelisted[userAddress] = false;
        LogUserUnregistered(msg.sender, userAddress);
    }
}


contract DisbursementHandler is Ownable {

    struct Disbursement {
        uint256 timestamp;
        uint256 tokens;
    }

    event LogSetup(address indexed vestor, uint256 tokens, uint256 timestamp);
    event LogChangeTimestamp(address indexed vestor, uint256 index, uint256 timestamp);
    event LogWithdraw(address indexed to, uint256 value);

    ERC20 public token;
    mapping(address => Disbursement[]) public disbursements;
    mapping(address => uint256) public withdrawnTokens;

    function DisbursementHandler(address _token) public {
        token = ERC20(_token);
    }

     
     
     
     
    function setupDisbursement(
        address vestor,
        uint256 tokens,
        uint256 timestamp
    )
        public
        onlyOwner
    {
        require(block.timestamp < timestamp);
        disbursements[vestor].push(Disbursement(timestamp, tokens));
        LogSetup(vestor, timestamp, tokens);
    }

     
     
     
     
    function changeTimestamp(
        address vestor,
        uint256 index,
        uint256 timestamp
    )
        public
        onlyOwner
    {
        require(block.timestamp < timestamp);
        require(index < disbursements[vestor].length);
        disbursements[vestor][index].timestamp = timestamp;
        LogChangeTimestamp(vestor, index, timestamp);
    }

     
     
     
    function withdraw(address to, uint256 value)
        public
    {
        uint256 maxTokens = calcMaxWithdraw();
        uint256 withdrawAmount = value < maxTokens ? value : maxTokens;
        withdrawnTokens[msg.sender] = SafeMath.add(withdrawnTokens[msg.sender], withdrawAmount);
        token.transfer(to, withdrawAmount);
        LogWithdraw(to, value);
    }

     
     
    function calcMaxWithdraw()
        public
        constant
        returns (uint256)
    {
        uint256 maxTokens = 0;
        Disbursement[] storage temp = disbursements[msg.sender];
        for (uint256 i = 0; i < temp.length; i++) {
            if (block.timestamp > temp[i].timestamp) {
                maxTokens = SafeMath.add(maxTokens, temp[i].tokens);
            }
        }
        maxTokens = SafeMath.sub(maxTokens, withdrawnTokens[msg.sender]);
        return maxTokens;
    }
}


 
contract Sale is Ownable, TimedStateMachine {
    using SafeMath for uint256;

    event LogContribution(address indexed contributor, uint256 amountSent, uint256 excessRefunded);
    event LogTokenAllocation(address indexed contributor, uint256 contribution, uint256 tokens);
    event LogDisbursement(address indexed beneficiary, uint256 tokens);

     
    bytes32 public constant SETUP = "setup";
    bytes32 public constant SETUP_DONE = "setupDone";
    bytes32 public constant SALE_IN_PROGRESS = "saleInProgress";
    bytes32 public constant SALE_ENDED = "saleEnded";

    mapping(address => uint256) public contributions;

    uint256 public weiContributed = 0;
    uint256 public contributionCap;

     
    address public wallet;

    MintableToken public token;

    DisbursementHandler public disbursementHandler;

    function Sale(
        address _wallet, 
        uint256 _contributionCap
    ) 
        public 
    {
        require(_wallet != 0);
        require(_contributionCap != 0);

        wallet = _wallet;

        token = createTokenContract();
        disbursementHandler = new DisbursementHandler(token);

        contributionCap = _contributionCap;

        setupStages();
    }

    function() external payable {
        contribute();
    }

     
     
    function setSaleStartTime(uint256 timestamp) 
        external 
        onlyOwner 
        checkAllowed
    {
         
        setStageStartTime(SALE_IN_PROGRESS, timestamp);
    }

     
     
    function setSaleEndTime(uint256 timestamp) 
        external 
        onlyOwner 
        checkAllowed
    {
        require(getStageStartTime(SALE_IN_PROGRESS) < timestamp);
        setStageStartTime(SALE_ENDED, timestamp);
    }

     
    function setupDone() 
        public 
        onlyOwner 
        checkAllowed
    {
        uint256 _startTime = getStageStartTime(SALE_IN_PROGRESS);
        uint256 _endTime = getStageStartTime(SALE_ENDED);
        require(block.timestamp < _startTime);
        require(_startTime < _endTime);

        state.goToNextStage();
    }

     
    function contribute() 
        public 
        payable
        checkAllowed 
    {
        require(msg.value > 0);   

        uint256 contributionLimit = getContributionLimit(msg.sender);
        require(contributionLimit > 0);

         
        uint256 totalContribution = contributions[msg.sender].add(msg.value);
        uint256 excess = 0;

         
        if (weiContributed.add(msg.value) > contributionCap) {
             
            excess = weiContributed.add(msg.value).sub(contributionCap);
            totalContribution = totalContribution.sub(excess);
        }

         
        if (totalContribution > contributionLimit) {
            excess = excess.add(totalContribution).sub(contributionLimit);
            contributions[msg.sender] = contributionLimit;
        } else {
            contributions[msg.sender] = totalContribution;
        }

         
        excess = excess < msg.value ? excess : msg.value;

        weiContributed = weiContributed.add(msg.value).sub(excess);

        if (excess > 0) {
            msg.sender.transfer(excess);
        }

        wallet.transfer(this.balance);

        assert(contributions[msg.sender] <= contributionLimit);
        LogContribution(msg.sender, msg.value, excess);
    }

     
     
     
     
    function distributeTimelockedTokens(
        address beneficiary,
        uint256 tokenAmount,
        uint256 timestamp
    ) 
        external
        onlyOwner
        checkAllowed
    { 
        disbursementHandler.setupDisbursement(
            beneficiary,
            tokenAmount,
            timestamp
        );
        token.mint(disbursementHandler, tokenAmount);
        LogDisbursement(beneficiary, tokenAmount);
    }
    
    function setupStages() internal {
         
        state.setInitialStage(SETUP);
        state.createTransition(SETUP, SETUP_DONE);
        state.createTransition(SETUP_DONE, SALE_IN_PROGRESS);
        state.createTransition(SALE_IN_PROGRESS, SALE_ENDED);

         
        state.allowFunction(SETUP, this.distributeTimelockedTokens.selector);
        state.allowFunction(SETUP, this.setSaleStartTime.selector);
        state.allowFunction(SETUP, this.setSaleEndTime.selector);
        state.allowFunction(SETUP, this.setupDone.selector);
        state.allowFunction(SALE_IN_PROGRESS, this.contribute.selector);
        state.allowFunction(SALE_IN_PROGRESS, 0);  
    }

     
    function createTokenContract() internal returns (MintableToken);
    function getContributionLimit(address userAddress) internal returns (uint256);

     
    function startConditions(bytes32 stageId) internal constant returns (bool) {
         
        if (stageId == SALE_ENDED && contributionCap == weiContributed) {
            return true;
        }
        return super.startConditions(stageId);
    }

     
    function onTransition(bytes32 stageId) internal {
        if (stageId == SALE_ENDED) { 
            onSaleEnded(); 
        }
        super.onTransition(stageId);
    }

     
    function onSaleEnded() internal {}
}



contract PryzeSale is Sale, Whitelistable {

    uint256 public constant PRESALE_WEI = 10695.303 ether;  
    uint256 public constant PRESALE_WEI_WITH_BONUS = 10695.303 ether * 1.5;  

    uint256 public constant MAX_WEI = 24695.303 ether;  
    uint256 public constant WEI_CAP = 14000 ether;  
    uint256 public constant MAX_TOKENS = 400000000 * 1000000000000000000;  

    uint256 public presaleWeiContributed = 0;
    uint256 private weiAllocated = 0;

    mapping(address => uint256) public presaleContributions;

    function PryzeSale(
        address _wallet
    )
        Sale(_wallet, WEI_CAP)
        public 
    {
    }

     
     
     
    function presaleContribute(address _contributor, uint256 _amount)
        external
        onlyOwner
        checkAllowed
    {
         
        if (presaleContributions[_contributor] != 0) {
            presaleWeiContributed = presaleWeiContributed.sub(presaleContributions[_contributor]);
        } 
        presaleWeiContributed = presaleWeiContributed.add(_amount);
        require(presaleWeiContributed <= PRESALE_WEI);
        presaleContributions[_contributor] = _amount;
    }

     
     
    function allocateTokens(address contributor) 
        external 
        checkAllowed
    {
        require(presaleContributions[contributor] != 0 || contributions[contributor] != 0);
        uint256 tokensToAllocate = calculateAllocation(contributor);

         
        weiAllocated = weiAllocated.add(presaleContributions[contributor]).add(contributions[contributor]);

         
        presaleContributions[contributor] = 0;
        contributions[contributor] = 0;

         
        token.mint(contributor, tokensToAllocate);

         
        if (weiAllocated == PRESALE_WEI.add(weiContributed)) {
          token.finishMinting();
        }
    }

    function setupDone() 
        public 
        onlyOwner 
        checkAllowed
    {
        require(presaleWeiContributed == PRESALE_WEI);
        super.setupDone();
    }

     
     
     
    function calculateAllocation(address contributor) public constant returns (uint256) {
        uint256 presale = presaleContributions[contributor].mul(15).div(10);  
        uint256 totalContribution = presale.add(contributions[contributor]);
        return totalContribution.mul(MAX_TOKENS).div(PRESALE_WEI_WITH_BONUS.add(weiContributed));
    }

    function setupStages() internal {
        super.setupStages();
        state.allowFunction(SETUP, this.presaleContribute.selector);
        state.allowFunction(SALE_ENDED, this.allocateTokens.selector);
    }

    function createTokenContract() internal returns(MintableToken) {
        return new PryzeToken();
    }

    function getContributionLimit(address userAddress) internal returns (uint256) {
         
        return whitelisted[userAddress] ? 2**256 - 1 : 0;
    }

}