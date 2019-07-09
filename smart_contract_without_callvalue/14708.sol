pragma solidity ^0.4.23;

 

pragma solidity ^0.4.23;

 

pragma solidity ^0.4.23;

 

pragma solidity ^0.4.23;

 

 
contract Ownable {
  address public owner;


   
  constructor() public {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    owner = newOwner;
  }

}

 
contract Haltable is Ownable {
  bool public halted;

  event Halted(bool halted);

  modifier stopInEmergency {
    require(!halted);
    _;
  }

  modifier onlyInEmergency {
    require(halted);
    _;
  }

   
  function halt() external onlyOwner {
    halted = true;
    emit Halted(true);
  }

   
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
    emit Halted(false);
  }
}
pragma solidity ^0.4.23;

 

 
library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
     
    uint c = a / b;
     
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint a, uint b) internal pure returns (uint) {
    return a >= b ? a : b;
  }

  function min256(uint a, uint b) internal pure returns (uint) {
    return a < b ? a : b;
  }
}

pragma solidity ^0.4.23;

 

pragma solidity ^0.4.23;

 

pragma solidity ^0.4.23;

 

pragma solidity ^0.4.23;

 
contract EIP20Token {

  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool success);
  function transferFrom(address from, address to, uint256 value) public returns (bool success);
  function approve(address spender, uint256 value) public returns (bool success);
  function allowance(address owner, address spender) public view returns (uint256 remaining);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

   

}
pragma solidity ^0.4.23;

 
contract Burnable {
   
   
   
  function burnTokens(address account, uint value) internal;
  event Burned(address account, uint value);
}
pragma solidity ^0.4.23;

 


 
contract Mintable {

   
  function mintInternal(address receiver, uint amount) internal;

   
  event Minted(address receiver, uint amount);
}

 
contract StandardToken is EIP20Token, Burnable, Mintable {
  using SafeMath for uint;

  uint private total_supply;
  mapping(address => uint) private balances;
  mapping(address => mapping (address => uint)) private allowed;


  function totalSupply() public view returns (uint) {
    return total_supply;
  }

   
  function transfer(address to, uint value) public returns (bool success) {
    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

   
  function balanceOf(address account) public view returns (uint balance) {
    return balances[account];
  }

   
  function transferFrom(address from, address to, uint value) public returns (bool success) {
    uint allowance = allowed[from][msg.sender];

     
     
     

    balances[from] = balances[from].sub(value);
    balances[to] = balances[to].add(value);
    allowed[from][msg.sender] = allowance.sub(value);
    emit Transfer(from, to, value);
    return true;
  }

   
  function approve(address spender, uint value) public returns (bool success) {

     
     
     
     
    require (value == 0 || allowed[msg.sender][spender] == 0);

    allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

   
  function allowance(address account, address spender) public view returns (uint remaining) {
    return allowed[account][spender];
  }

   
  function addApproval(address spender, uint addedValue) public returns (bool success) {
      uint oldValue = allowed[msg.sender][spender];
      allowed[msg.sender][spender] = oldValue.add(addedValue);
      emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
      return true;
  }

   
  function subApproval(address spender, uint subtractedValue) public returns (bool success) {

      uint oldVal = allowed[msg.sender][spender];

      if (subtractedValue > oldVal) {
          allowed[msg.sender][spender] = 0;
      } else {
          allowed[msg.sender][spender] = oldVal.sub(subtractedValue);
      }
      emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
      return true;
  }

   
  function burnTokens(address account, uint value) internal {
    balances[account] = balances[account].sub(value);
    total_supply = total_supply.sub(value);
    emit Transfer(account, 0, value);
    emit Burned(account, value);
  }

   
  function mintInternal(address receiver, uint amount) internal {
    total_supply = total_supply.add(amount);
    balances[receiver] = balances[receiver].add(amount);
    emit Minted(receiver, amount);

     
     
     
    emit Transfer(0, receiver, amount);
  }
  
}

 
contract ReleasableToken is StandardToken, Ownable {

   
  address public releaseAgent;

   
  bool public released = false;

   
  mapping (address => bool) public transferAgents;

   
  function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {
     
    releaseAgent = addr;
  }

   
  function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
    transferAgents[addr] = state;
  }

   
  function releaseTokenTransfer() public onlyReleaseAgent {
    released = true;
  }

   
  modifier canTransfer(address sender) {
    require(released || transferAgents[sender]);
    _;
  }

   
  modifier inReleaseState(bool releaseState) {
    require(releaseState == released);
    _;
  }

   
  modifier onlyReleaseAgent() {
    require(msg.sender == releaseAgent);
    _;
  }

   
  function transfer(address to, uint value) public canTransfer(msg.sender) returns (bool success) {
     
   return super.transfer(to, value);
  }

   
  function transferFrom(address from, address to, uint value) public canTransfer(from) returns (bool success) {
     
    return super.transferFrom(from, to, value);
  }

}



pragma solidity ^0.4.23;

 

pragma solidity ^0.4.23;

 

 
contract UpgradeAgent {

   
  uint public originalSupply;

   
  function isUpgradeAgent() public pure returns (bool) {
    return true;
  }

   
  function upgradeFrom(address from, uint value) public;

}


 
contract UpgradeableToken is EIP20Token, Burnable {
  using SafeMath for uint;

   
  address public upgradeMaster;

   
  UpgradeAgent public upgradeAgent;

   
  uint public totalUpgraded = 0;

   
  enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

   
  event Upgrade(address indexed from, address to, uint value);

   
  event UpgradeAgentSet(address agent);

   
  constructor(address master) internal {
    setUpgradeMaster(master);
  }

   
  function upgrade(uint value) public {
    UpgradeState state = getUpgradeState();
     
    require(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading);

     
    require(value != 0);

     
    upgradeAgent.upgradeFrom(msg.sender, value);
    
     
    burnTokens(msg.sender, value);
    totalUpgraded = totalUpgraded.add(value);

    emit Upgrade(msg.sender, upgradeAgent, value);
  }

   
  function setUpgradeAgent(address agent) onlyMaster external {
     
    require(canUpgrade());

    require(agent != 0x0);
     
    require(getUpgradeState() != UpgradeState.Upgrading);

    upgradeAgent = UpgradeAgent(agent);

     
    require(upgradeAgent.isUpgradeAgent());
     
    require(upgradeAgent.originalSupply() == totalSupply());

    emit UpgradeAgentSet(upgradeAgent);
  }

   
  function getUpgradeState() public view returns(UpgradeState) {
    if (!canUpgrade()) return UpgradeState.NotAllowed;
    else if (address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
    else if (totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
    else return UpgradeState.Upgrading;
  }

   
  function changeUpgradeMaster(address new_master) onlyMaster public {
    setUpgradeMaster(new_master);
  }

   
  function setUpgradeMaster(address new_master) private {
    require(new_master != 0x0);
    upgradeMaster = new_master;
  }

   
  function canUpgrade() public view returns(bool) {
     return true;
  }


  modifier onlyMaster() {
    require(msg.sender == upgradeMaster);
    _;
  }
}

pragma solidity ^0.4.23;

 


 
 
 
contract LostAndFoundToken {
   
  function getLostAndFoundMaster() internal view returns (address);

   
  function enableLostAndFound(address agent, uint tokens, EIP20Token token_contract) public {
    require(msg.sender == getLostAndFoundMaster());
     
     
    token_contract.approve(agent, tokens);
  }
}
pragma solidity ^0.4.23;

 


 
contract MintableToken is Mintable, Ownable {

  using SafeMath for uint;

  bool public mintingFinished = false;

   
  mapping (address => bool) public mintAgents;

  event MintingAgentChanged(address addr, bool state);


  constructor(uint initialSupply, address multisig, bool mintable) internal {
    require(multisig != address(0));
     
    require(mintable || initialSupply != 0);
     
    if (initialSupply > 0)
      mintInternal(multisig, initialSupply);
     
    mintingFinished = !mintable;
  }

   
  function mint(address receiver, uint amount) onlyMintAgent canMint public {
    mintInternal(receiver, amount);
  }

   
  function setMintAgent(address addr, bool state) onlyOwner canMint public {
    mintAgents[addr] = state;
    emit MintingAgentChanged(addr, state);
  }

  modifier onlyMintAgent() {
     
    require(mintAgents[msg.sender]);
    _;
  }

   
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
}

 
contract CrowdsaleToken is ReleasableToken, MintableToken, UpgradeableToken, LostAndFoundToken {

  string public name = "Kryptobits";

  string public symbol = "KBE";

  uint8 public decimals;

  address public lost_and_found_master;

   
  constructor(uint initial_supply, uint8 token_decimals, address team_multisig, address token_retriever) public
  UpgradeableToken(team_multisig) MintableToken(initial_supply, team_multisig, true) {
    require(token_retriever != address(0));
    decimals = token_decimals;
    lost_and_found_master = token_retriever;
  }

   
  function releaseTokenTransfer() public onlyReleaseAgent {
    mintingFinished = true;
    super.releaseTokenTransfer();
  }

   
  function canUpgrade() public view returns(bool) {
    return released && super.canUpgrade();
  }

  function burn(uint value) public {
    burnTokens(msg.sender, value);
  }

  function getLostAndFoundMaster() internal view returns(address) {
    return lost_and_found_master;
  }
}

 
contract GenericCrowdsale is Haltable {

  using SafeMath for uint;

   
  CrowdsaleToken public token;

   
  address public multisigWallet;

   
  uint public startsAt;

   
  uint public endsAt;

   
  uint public tokensSold = 0;

   
  uint public weiRaised = 0;

   
  uint public investorCount = 0;

   
  bool public finalized = false;

   
  bool public requireCustomerId = false;

   
  bool public configured = false;

   
  bool public requiredSignedAddress = false;

   
  address public signerAddress;

   
  mapping (address => uint) public investedAmountOf;

   
  mapping (address => uint) public tokenAmountOf;

   
  mapping (address => bool) public earlyParticipantWhitelist;

   
  enum State{Unknown, PendingConfiguration, PreFunding, Funding, Success, Finalized}


   
  event Invested(address investor, uint weiAmount, uint tokenAmount, uint128 customerId);

   
  event InvestmentPolicyChanged(bool requireCId, bool requireSignedAddress, address signer);

   
  event Whitelisted(address addr, bool status);

   
  event Finalized();

   
  function configurationGenericCrowdsale(address team_multisig, uint start, uint end) internal inState(State.PendingConfiguration) {
    setMultisig(team_multisig);

     
    require(start != 0 && end != 0);
    require(now < start && start < end);
    startsAt = start;
    endsAt = end;
    configured = true;
  }

   
  function() payable public {
    buy();
  }

   
  function investInternal(address receiver, uint128 customerId) stopInEmergency notFinished private {
     
    if (getState() == State.PreFunding) {
       
      require(earlyParticipantWhitelist[msg.sender]);
    }

    uint weiAmount;
    uint tokenAmount;
    (weiAmount, tokenAmount) = calculateTokenAmount(msg.value, receiver);
     
    assert(weiAmount <= msg.value);
    
     
    require(tokenAmount != 0);

    if (investedAmountOf[receiver] == 0) {
       
      investorCount++;
    }
    updateInvestorFunds(tokenAmount, weiAmount, receiver, customerId);

     
    multisigWallet.transfer(weiAmount);

     
    returnExcedent(msg.value.sub(weiAmount), msg.sender);
  }

   
  function preallocate(address receiver, uint fullTokens, uint weiPrice) public onlyOwner notFinished {
    require(receiver != address(0));
    uint tokenAmount = fullTokens.mul(10**uint(token.decimals()));
    require(tokenAmount != 0);
    uint weiAmount = weiPrice.mul(tokenAmount);  
    updateInvestorFunds(tokenAmount, weiAmount, receiver , 0);
  }

   
  function updateInvestorFunds(uint tokenAmount, uint weiAmount, address receiver, uint128 customerId) private {
     
    investedAmountOf[receiver] = investedAmountOf[receiver].add(weiAmount);
    tokenAmountOf[receiver] = tokenAmountOf[receiver].add(tokenAmount);

     
    weiRaised = weiRaised.add(weiAmount);
    tokensSold = tokensSold.add(tokenAmount);

    assignTokens(receiver, tokenAmount);
     
    emit Invested(receiver, weiAmount, tokenAmount, customerId);
  }

   
  function buyOnBehalfWithSignedAddress(address receiver, uint128 customerId, uint8 v, bytes32 r, bytes32 s) public payable validCustomerId(customerId) {
    bytes32 hash = sha256(receiver);
    require(ecrecover(hash, v, r, s) == signerAddress);
    investInternal(receiver, customerId);
  }

   
  function buyOnBehalfWithCustomerId(address receiver, uint128 customerId) public payable validCustomerId(customerId) unsignedBuyAllowed {
    investInternal(receiver, customerId);
  }

   
  function buyOnBehalf(address receiver) public payable unsignedBuyAllowed {
    require(!requireCustomerId);  
    investInternal(receiver, 0);
  }

   
  function buyWithSignedAddress(uint128 customerId, uint8 v, bytes32 r, bytes32 s) public payable {
    buyOnBehalfWithSignedAddress(msg.sender, customerId, v, r, s);
  }


   
  function buyWithCustomerId(uint128 customerId) public payable {
    buyOnBehalfWithCustomerId(msg.sender, customerId);
  }

   
  function buy() public payable {
    buyOnBehalf(msg.sender);
  }

   
  function finalize() public inState(State.Success) onlyOwner stopInEmergency {
    finalized = true;
    emit Finalized();
  }

   
  function setRequireCustomerId(bool value) public onlyOwner {
    requireCustomerId = value;
    emit InvestmentPolicyChanged(requireCustomerId, requiredSignedAddress, signerAddress);
  }

   
  function setRequireSignedAddress(bool value, address signer) public onlyOwner {
    requiredSignedAddress = value;
    signerAddress = signer;
    emit InvestmentPolicyChanged(requireCustomerId, requiredSignedAddress, signerAddress);
  }

   
  function setEarlyParticipantWhitelist(address addr, bool status) public onlyOwner notFinished stopInEmergency {
    earlyParticipantWhitelist[addr] = status;
    emit Whitelisted(addr, status);
  }

   
  function setMultisig(address addr) internal {
    require(addr != 0);
    multisigWallet = addr;
  }

   
  function getState() public view returns (State) {
    if (finalized) return State.Finalized;
    else if (!configured) return State.PendingConfiguration;
    else if (now < startsAt) return State.PreFunding;
    else if (now <= endsAt && !isCrowdsaleFull()) return State.Funding;
    else return State.Success;
  }

   

   
  function assignTokens(address receiver, uint tokenAmount) internal;

   
  function isCrowdsaleFull() internal view returns (bool full);

   
  function returnExcedent(uint excedent, address receiver) internal {
    if (excedent > 0) {
      receiver.transfer(excedent);
    }
  }

   
  function calculateTokenAmount(uint weiAmount, address receiver) internal view returns (uint weiAllowed, uint tokenAmount);

   
   
   

  modifier inState(State state) {
    require(getState() == state);
    _;
  }

  modifier unsignedBuyAllowed() {
    require(!requiredSignedAddress);
    _;
  }

   
  modifier notFinished() {
    State current_state = getState();
    require(current_state == State.PreFunding || current_state == State.Funding);
    _;
  }

  modifier validCustomerId(uint128 customerId) {
    require(customerId != 0);   
    _;
  }
}
pragma solidity ^0.4.23;

 
contract DeploymentInfo {
  uint private deployed_on;

  constructor() public {
    deployed_on = block.number;
  }


  function getDeploymentBlock() public view returns (uint) {
    return deployed_on;
  }
}

 

pragma solidity ^0.4.23;


 
 
 
 
contract TokenTranchePricing {

  using SafeMath for uint;

   
  struct Tranche {
       
      uint amount;
       
       
      uint start;
       
      uint end;
       
      uint price;
  }
   
  uint private constant amount_offset = 0;
  uint private constant start_offset = 1;
  uint private constant end_offset = 2;
  uint private constant price_offset = 3;
  uint private constant tranche_size = 4;

  Tranche[] public tranches;

  function getTranchesLength() public view returns (uint) {
    return tranches.length;
  }
  
   
   
   
   
   
  function configurationTokenTranchePricing(uint[] init_tranches) internal {
     
    require(init_tranches.length % tranche_size == 0);
     
     
    require(init_tranches[amount_offset] > 0);

    uint input_tranches_length = init_tranches.length.div(tranche_size);
    Tranche memory last_tranche;
    for (uint i = 0; i < input_tranches_length; i++) {
      uint tranche_offset = i.mul(tranche_size);
      uint amount = init_tranches[tranche_offset.add(amount_offset)];
      uint start = init_tranches[tranche_offset.add(start_offset)];
      uint end = init_tranches[tranche_offset.add(end_offset)];
      uint price = init_tranches[tranche_offset.add(price_offset)];
       
      require(start < end && now < end);
       
       
      require(i == 0 || (end >= last_tranche.end && amount > last_tranche.amount) ||
              (end > last_tranche.end && amount >= last_tranche.amount));

      last_tranche = Tranche(amount, start, end, price);
      tranches.push(last_tranche);
    }
  }

   
   
   
  function getCurrentTranche(uint tokensSold) private view returns (Tranche storage) {
    for (uint i = 0; i < tranches.length; i++) {
      if (tranches[i].start <= now && now < tranches[i].end && tokensSold < tranches[i].amount) {
        return tranches[i];
      }
    }
     
    revert();
  }

   
   
   
  function getCurrentPrice(uint tokensSold) public view returns (uint result) {
    return getCurrentTranche(tokensSold).price;
  }

}

 
contract Crowdsale is GenericCrowdsale, LostAndFoundToken, DeploymentInfo, TokenTranchePricing {
  uint public sellable_tokens;
  uint public initial_tokens;
  uint public milieurs_per_eth;
   
  uint public minimum_buy_value;
  address public price_agent; 

   

  function configurationCrowdsale(address team_multisig, uint start, uint end,
  address token_retriever, uint[] init_tranches, uint multisig_supply, uint crowdsale_supply,
  uint8 token_decimals) public onlyOwner {

    initial_tokens = multisig_supply;
    minimum_buy_value = uint(100).mul(10 ** uint(token_decimals));
    token = new CrowdsaleToken(multisig_supply, token_decimals, team_multisig, token_retriever);
     
    token.setMintAgent(address(this), true);
     
    token.setReleaseAgent(address(this));
     
    token.setTransferAgent(address(this), true);
     
    token.setTransferAgent(team_multisig, true);
     
    token.mint(address(this), crowdsale_supply);
     
    token.setMintAgent(address(this), false);

    sellable_tokens = crowdsale_supply;

     
    configurationGenericCrowdsale(team_multisig, start, end);

     
    configurationTokenTranchePricing(init_tranches);
  }

   
  function assignTokens(address receiver, uint tokenAmount) internal {
    token.transfer(receiver, tokenAmount);
  }

   
  function calculateTokenAmount(uint weiAmount, address receiver) internal view returns (uint weiAllowed, uint tokenAmount) {
     
    uint tokensPerEth = getCurrentPrice(tokensSold).mul(milieurs_per_eth).div(1000);
    uint maxWeiAllowed = sellable_tokens.sub(tokensSold).mul(1 ether).div(tokensPerEth);
    weiAllowed = maxWeiAllowed.min256(weiAmount);

    if (weiAmount < maxWeiAllowed) {
      tokenAmount = tokensPerEth.mul(weiAmount).div(1 ether);
    }
     
    else {
      tokenAmount = sellable_tokens.sub(tokensSold);
    }

     
    require(token.balanceOf(receiver).add(tokenAmount) >= minimum_buy_value);
  }

   
  function isCrowdsaleFull() internal view returns (bool full) {
    return tokensSold >= sellable_tokens;
  }

   
  function finalize() public inState(State.Success) onlyOwner stopInEmergency {
     
    uint sold = tokensSold.add(initial_tokens);
    uint toShare = sold.mul(18).div(82);

     
    token.setMintAgent(address(this), true);
    token.mint(multisigWallet, toShare);
    token.setMintAgent(address(this), false);

     
    token.releaseTokenTransfer();
    token.burn(token.balanceOf(address(this)));

    super.finalize();
  }

   
  function getLostAndFoundMaster() internal view returns (address) {
    return owner;
  }

   
  function setStartingTime(uint startingTime) public onlyOwner inState(State.PreFunding) {
    require(now < startingTime && startingTime < endsAt);
    startsAt = startingTime;
  }

  function setEndingTime(uint endingTime) public onlyOwner notFinished {
    require(now < endingTime && startsAt < endingTime);
    endsAt = endingTime;
  }

  function updateEursPerEth (uint milieurs_amount) public notFinished {
    require(milieurs_amount >= 100);
    require(msg.sender == price_agent);
    milieurs_per_eth = milieurs_amount;
  }

  function updatePriceAgent(address new_price_agent) public onlyOwner notFinished {
    price_agent = new_price_agent;
  }

   
  function setMinimumBuyValue(uint new_minimum) public onlyOwner notFinished {
    minimum_buy_value = new_minimum;
  }
}