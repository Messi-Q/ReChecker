pragma solidity ^0.4.24;

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract SafeMath {
  function safeMul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal pure returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

  function toWei(uint256 a) internal pure returns (uint256){
    assert(a>0);
    return a * 10 ** 18;
  }
}

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; 
}

contract TokenERC20 is SafeMath{

     
     
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;


     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Burn(address indexed from, uint256 value);

     
    constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * 10 ** uint256(decimals);
    }

     
    function _transfer(address _from, address _to, uint _value) internal {
         
        require(_to != 0x0);
         
        require(balanceOf[_from] >= _value);
         
        require(safeAdd(balanceOf[_to], _value) > balanceOf[_to]);
         
        uint previousBalances = safeAdd(balanceOf[_from],balanceOf[_to]);
         
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
         
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        emit Transfer(_from, _to, _value);
         
        assert(safeAdd(balanceOf[_from],balanceOf[_to]) == previousBalances);
    }

     
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);      
        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender],_value);
        _transfer(_from, _to, _value);
        return true;
    }
      
     
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

     
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);    
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);             
        totalSupply = safeSub(totalSupply,_value);                       
        emit Burn(msg.sender, _value);
        return true;
    }

     
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                 
        require(_value <= allowance[_from][msg.sender]);     
        balanceOf[_from] = safeSub(balanceOf[_from], _value);                          
        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);              
        totalSupply = safeSub(totalSupply,_value);                               
        emit Burn(_from, _value);
        return true;
    }
}

 
 
 

contract GameRewardToken is owned, TokenERC20 {

     
    enum State{PrivateFunding, PreFunding, Funding, Success, Failure}


    mapping (address => bool) public frozenAccount;
    mapping (address => address) public applications;
    mapping (address => uint256) public bounties;
    mapping (address => uint256) public bonus;
    mapping (address => address) public referrals;
    mapping (address => uint256) public investors;
    mapping (address => uint256) public funders;

     
    event FrozenFunds(address indexed target, bool frozen);
    event FundTransfer(address indexed to, uint256 eth , uint256 value, uint block);
    event SetApplication(address indexed target, address indexed parent);
    event Fee(address indexed from, address indexed collector, uint256 fee);
    event FreeDistribution(address indexed to, uint256 value, uint block);
    event Refund(address indexed to, uint256 value, uint block);
    event BonusTransfer(address indexed to, uint256 value, uint block);
    event BountyTransfer(address indexed to, uint256 value, uint block);
    event SetReferral(address indexed target, address indexed broker);
    event ChangeCampaign(uint256 fundingStartBlock, uint256 fundingEndBlock);
    event AddBounty(address indexed bountyHunter, uint256 value);
    event ReferralBonus(address indexed investor, address indexed broker, uint256 value);

      
    bool public finalizedCrowdfunding = false;

    uint256 public fundingStartBlock = 0;  
    uint256 public fundingEndBlock = 0;    
    uint256 public constant lockedTokens =                250000000*10**18;  
    uint256 public bonusAndBountyTokens =                  50000000*10**18;  
    uint256 public constant devsTokens =                  100000000*10**18;  
    uint256 public constant hundredPercent =                           100;
    uint256 public constant tokensPerEther =                         20000;  
    uint256 public constant tokenCreationMax =            600000000*10**18;  
    uint256 public constant tokenCreationMin =             60000000*10**18;  

    uint256 public constant tokenPrivateMax =             100000000*10**18;  

    uint256 public constant minContributionAmount =             0.1*10**18;  
    uint256 public constant maxContributionAmount =             100*10**18;  

    uint256 public constant minPrivateContribution =              5*10**18;  
    uint256 public constant minPreContribution =                  1*10**18;  

    uint256 public constant minAmountToGetBonus =                 1*10**18;  
    uint256 public constant referralBonus =                              5;  
    uint256 public constant privateBonus =                              40;  
    uint256 public constant preBonus =                                  20;  

    uint256 public tokensSold;
    uint256 public collectedETH;

    uint256 public constant numBlocksLocked = 1110857;   
    bool public releasedBountyTokens = false;  
    uint256 public unlockedAtBlockNumber;

    address public lockedTokenHolder;
    address public releaseTokenHolder;
    address public devsHolder;


    constructor(address _lockedTokenHolder,
                address _releaseTokenHolder,
                address _devsAddress
    ) TokenERC20("GameReward",  
                 "GRD",         
                  18,           
                  1000000000    
                  ) public {
        
        require (_lockedTokenHolder != 0x0);
        require (_releaseTokenHolder != 0x0);
        require (_devsAddress != 0x0);
        lockedTokenHolder = _lockedTokenHolder;
        releaseTokenHolder = _releaseTokenHolder;
        devsHolder = _devsAddress;
    }

     
    function _transfer(address _from, address _to, uint _value) internal {
        require (getState() == State.Success);
        require (_to != 0x0);                                       
        require (balanceOf[_from] >= _value);                       
        require (safeAdd(balanceOf[_to],_value) > balanceOf[_to]);  
        require (!frozenAccount[_from]);                            
        require (!frozenAccount[_to]);                              
        require (_from != lockedTokenHolder);
        balanceOf[_from] = safeSub(balanceOf[_from],_value);        
        balanceOf[_to] = safeAdd(balanceOf[_to],_value);            
        emit Transfer(_from, _to, _value);
        if(applications[_to] != 0x0){                               
            balanceOf[_to] = safeSub(balanceOf[_to],_value);        
            balanceOf[applications[_to]] =safeAdd(balanceOf[applications[_to]],_value);    
            emit Transfer(_to, applications[_to], _value);
        }
    }

     
    function updateNameAndSymbol(string _newname, string _newsymbol) onlyOwner public{
      name = _newname;
      symbol = _newsymbol;
    }

     
     
     
     
     
     
    function withdraw(address _from, address _to, uint _value, uint _fee, address _collector) onlyOwner public {
        require (getState() == State.Success);
        require (applications[_from]!=0x0);                              
        address app = applications[_from];
        require (_collector != 0x0);
        require (_to != 0x0);                                            
        require (balanceOf[app] >= safeAdd(_value, _fee));               
        require (safeAdd(balanceOf[_to], _value)> balanceOf[_to]);       
        require (!frozenAccount[app]);                                   
        require (!frozenAccount[_to]);                                   
        require (_from != lockedTokenHolder);
        balanceOf[app] = safeSub(balanceOf[app],safeAdd(_value, _fee));  
        balanceOf[_to] = safeAdd(balanceOf[_to],_value);                 
        balanceOf[_collector] = safeAdd(balanceOf[_collector], _fee);    
        emit Fee(app,_collector,_fee);
        emit Transfer(app, _collector, _fee);
        emit Transfer(app, _to, _value);
    }
    
     
     
     
    function setApplication(address _target, address _parent) onlyOwner public {
        require (getState() == State.Success);
        require(_parent!=0x0);
        applications[_target]=_parent;
        uint256 currentBalance=balanceOf[_target];
        emit SetApplication(_target,_parent);
        if(currentBalance>0x0){
            balanceOf[_target] = safeDiv(balanceOf[_target],currentBalance);
            balanceOf[_parent] = safeAdd(balanceOf[_parent],currentBalance);
            emit Transfer(_target,_parent,currentBalance);
        }
    }

     
     
     
    function freezeAccount(address _target, bool _freeze) onlyOwner public {
        frozenAccount[_target] = _freeze;
        emit FrozenFunds(_target, _freeze);
    }



     

     
    function _getEarlyBonus() internal view returns(uint){
        if(getState()==State.PrivateFunding) return privateBonus;  
        else if(getState()==State.PreFunding) return preBonus; 
        else return 0;
    }

     
     
     
    function setCampaign(uint256 _fundingStartBlock, uint256 _fundingEndBlock) onlyOwner public{
        if(block.number < _fundingStartBlock){
            fundingStartBlock = _fundingStartBlock;
        }
        if(_fundingEndBlock > fundingStartBlock && _fundingEndBlock > block.number){
            fundingEndBlock = _fundingEndBlock;
        }
        emit ChangeCampaign(_fundingStartBlock,_fundingEndBlock);
    }

    function releaseBountyTokens() onlyOwner public{
      require(!releasedBountyTokens);
      require(getState()==State.Success);
      releasedBountyTokens = true;
    }


     
     
     
    function setReferral(address _target, address _broker, uint256 _amount) onlyOwner public {
        require (_target != 0x0);
        require (_broker != 0x0);
        referrals[_target] = _broker;
        emit SetReferral(_target, _broker);
        if(_amount>0x0){
            uint256 brokerBonus = safeDiv(safeMul(_amount,referralBonus),hundredPercent);
            bonus[_broker] = safeAdd(bonus[_broker],brokerBonus);
            emit ReferralBonus(_target,_broker,brokerBonus);
        }
    }

     
    function addBounty(address _hunter, uint256 _amount) onlyOwner public{
        require(_hunter!=0x0);
        require(toWei(_amount)<=safeSub(bonusAndBountyTokens,toWei(_amount)));
        bounties[_hunter] = safeAdd(bounties[_hunter],toWei(_amount));
        bonusAndBountyTokens = safeSub(bonusAndBountyTokens,toWei(_amount));
        emit AddBounty(_hunter, toWei(_amount));
    }

     
     
     
    function() payable public{
         
         
        require (getState() != State.Success);
        require (getState() != State.Failure);
        require (msg.value != 0);

        if(getState()==State.PrivateFunding){
            require(msg.value>=minPrivateContribution);
        }else if(getState()==State.PreFunding){
            require(msg.value>=minPreContribution && msg.value < maxContributionAmount);
        }else if(getState()==State.Funding){
            require(msg.value>=minContributionAmount && msg.value < maxContributionAmount);
        }

         
        uint256 createdTokens = safeMul(msg.value, tokensPerEther);
        uint256 brokerBonus = 0;
        uint256 earlyBonus = safeDiv(safeMul(createdTokens,_getEarlyBonus()),hundredPercent);

        createdTokens = safeAdd(createdTokens,earlyBonus);

         
        if(getState()==State.PrivateFunding){
            require(safeAdd(tokensSold,createdTokens) <= tokenPrivateMax);
        }else{
            require (safeAdd(tokensSold,createdTokens) <= tokenCreationMax);
        }

         
        tokensSold = safeAdd(tokensSold, createdTokens);
        collectedETH = safeAdd(collectedETH,msg.value);
        
         
        if(referrals[msg.sender]!= 0x0){
            brokerBonus = safeDiv(safeMul(createdTokens,referralBonus),hundredPercent);
            bonus[referrals[msg.sender]] = safeAdd(bonus[referrals[msg.sender]],brokerBonus);
            emit ReferralBonus(msg.sender,referrals[msg.sender],brokerBonus);
        }

         
        funders[msg.sender] = safeAdd(funders[msg.sender],msg.value);
        investors[msg.sender] = safeAdd(investors[msg.sender],createdTokens);

         
        balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], createdTokens);
         
        emit FundTransfer(msg.sender,msg.value, createdTokens, block.number);
        emit Transfer(0, msg.sender, createdTokens);
    }

     
    function requestBonus() external{
      require(getState()==State.Success);
      uint256 bonusAmount = bonus[msg.sender];
      assert(bonusAmount>0);
      require(bonusAmount<=safeSub(bonusAndBountyTokens,bonusAmount));
      balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender],bonusAmount);
      bonus[msg.sender] = 0;
      bonusAndBountyTokens = safeSub(bonusAndBountyTokens,bonusAmount);
      emit BonusTransfer(msg.sender,bonusAmount,block.number);
      emit Transfer(0,msg.sender,bonusAmount);
    }

     
     
     
    function releaseLockedToken() external {
        require (getState() == State.Success);
        require (balanceOf[lockedTokenHolder] > 0x0);
        require (block.number >= unlockedAtBlockNumber);
        balanceOf[devsHolder] = safeAdd(balanceOf[devsHolder],balanceOf[lockedTokenHolder]);
        emit Transfer(lockedTokenHolder,devsHolder,balanceOf[lockedTokenHolder]);
        balanceOf[lockedTokenHolder] = 0;
    }
    
     
     
    function requestBounty() external{
        require(releasedBountyTokens);  
        require(getState()==State.Success);
        assert (bounties[msg.sender]>0);
        balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender],bounties[msg.sender]);
        emit BountyTransfer(msg.sender,bounties[msg.sender],block.number);
        emit Transfer(0,msg.sender,bounties[msg.sender]);
        bounties[msg.sender] = 0;
    }

     
     
     
     
     
    function finalizeCrowdfunding() external {
         
        require (getState() == State.Success);  
        require (!finalizedCrowdfunding);  

         
        finalizedCrowdfunding = true;
         
        balanceOf[lockedTokenHolder] = safeAdd(balanceOf[lockedTokenHolder], lockedTokens);

         
        unlockedAtBlockNumber = block.number + numBlocksLocked;
        emit Transfer(0, lockedTokenHolder, lockedTokens);

         
        balanceOf[devsHolder] = safeAdd(balanceOf[devsHolder], devsTokens);
        emit Transfer(0, devsHolder, devsTokens);

         
        devsHolder.transfer(address(this).balance);
    }

     
    function requestFreeDistribution() external{
      require(getState()==State.Success);
      assert(investors[msg.sender]>0);
      uint256 unSoldTokens = safeSub(tokenCreationMax,tokensSold);
      require(unSoldTokens>0);
      uint256 freeTokens = safeDiv(safeMul(unSoldTokens,investors[msg.sender]),tokensSold);
      balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender],freeTokens);
      investors[msg.sender] = 0;
      emit FreeDistribution(msg.sender,freeTokens,block.number);
      emit Transfer(0,msg.sender, freeTokens);

    }

     
     
     
    function requestRefund() external {
         
        assert (getState() == State.Failure);
        assert (funders[msg.sender]>0);
        msg.sender.transfer(funders[msg.sender]);  
        emit Refund( msg.sender, funders[msg.sender],block.number);
        funders[msg.sender]=0;
    }

     
     
     
    function getState() public constant returns (State){
       
      if (finalizedCrowdfunding) return State.Success;
      if(fundingStartBlock ==0 && fundingEndBlock==0) return State.PrivateFunding;
      else if (block.number < fundingStartBlock) return State.PreFunding;
      else if (block.number <= fundingEndBlock && tokensSold < tokenCreationMax) return State.Funding;
      else if (tokensSold >= tokenCreationMin) return State.Success;
      else return State.Failure;
    }
}