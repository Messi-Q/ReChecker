pragma solidity ^0.4.21;

 

contract Controlled {
     
     
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() public { controller = msg.sender;}

     
     
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }
}

 

 
contract TokenController {
     
     
     
    function proxyPayment(address _owner) public payable returns(bool);

     
     
     
     
     
     
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

     
     
     
     
     
     
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);
}

 

 

 
 
 
 
 
 
 



contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
}

 
 
 
contract MiniMeToken is Controlled {

    string public name;                 
    uint8 public decimals;              
    string public symbol;               
    string public version = 'MMT_0.2';  


     
     
     
    struct Checkpoint {

         
        uint128 fromBlock;

         
        uint128 value;
    }

     
     
    MiniMeToken public parentToken;

     
     
    uint public parentSnapShotBlock;

     
    uint public creationBlock;

     
     
     
    mapping (address => Checkpoint[]) balances;

     
    mapping (address => mapping (address => uint256)) allowed;

     
    Checkpoint[] totalSupplyHistory;

     
    bool public transfersEnabled;

     
    MiniMeTokenFactory public tokenFactory;

 
 
 

     
     
     
     
     
     
     
     
     
     
     
     
     
    function MiniMeToken(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                  
        decimals = _decimalUnits;                           
        symbol = _tokenSymbol;                              
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }


 
 
 

     
     
     
     
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

     
     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _amount
    ) public returns (bool success) {

         
         
         
         
        if (msg.sender != controller) {
            require(transfersEnabled);

             
            require(allowed[_from][msg.sender] >= _amount);
            allowed[_from][msg.sender] -= _amount;
        }
        doTransfer(_from, _to, _amount);
        return true;
    }

     
     
     
     
     
     
    function doTransfer(address _from, address _to, uint _amount
    ) internal {

           if (_amount == 0) {
               Transfer(_from, _to, _amount);     
               return;
           }

           require(parentSnapShotBlock < block.number);

            
           require((_to != 0) && (_to != address(this)));

            
            
           var previousBalanceFrom = balanceOfAt(_from, block.number);

           require(previousBalanceFrom >= _amount);

            
           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

            
            
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

            
            
           var previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo);  
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

            
           Transfer(_from, _to, _amount);

    }

     
     
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

     
     
     
     
     
     
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);

         
         
         
         
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

         
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

     
     
     
     
     
    function allowance(address _owner, address _spender
    ) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

     
     
     
     
     
     
     
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) public returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

     
     
    function totalSupply() public constant returns (uint) {
        return totalSupplyAt(block.number);
    }


 
 
 

     
     
     
     
    function balanceOfAt(address _owner, uint _blockNumber) public constant
        returns (uint) {

         
         
         
         
         
        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                 
                return 0;
            }

         
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

     
     
     
    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {

         
         
         
         
         
        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

         
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

 
 
 

     
     
     
     
     
     
     
     
     
     
    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) public returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

         
        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

 
 
 

     
     
     
     
    function generateTokens(address _owner, uint _amount
    ) public onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply);  
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo);  
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


     
     
     
     
    function destroyTokens(address _owner, uint _amount
    ) onlyController public returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }

 
 
 


     
     
    function enableTransfers(bool _transfersEnabled) public onlyController {
        transfersEnabled = _transfersEnabled;
    }

 
 
 

     
     
     
     
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

         
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

         
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

     
     
     
     
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

     
     
     
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

     
    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

     
     
     
    function () public payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }

 
 
 

     
     
     
     
    function claimTokens(address _token) public onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

 
 
 
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}


 
 
 

 
 
 
contract MiniMeTokenFactory {

     
     
     
     
     
     
     
     
     
     
    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public returns (MiniMeToken) {
        MiniMeToken newToken = new MiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}

 

contract SEED is MiniMeToken {
  function SEED()
    MiniMeToken(
      0x00,           
      0x00,           
      0,              
      "SEED",         
      18,             
      "SEED",         
      false           
    )
    public
  {}
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

 

 
contract Whitelist is Ownable {
  mapping(address => bool) public whitelist;

  event WhitelistedAddressAdded(address addr);
  event WhitelistedAddressRemoved(address addr);

   
  modifier onlyWhitelisted() {
    require(whitelist[msg.sender]);
    _;
  }

   
  function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
    if (!whitelist[addr]) {
      whitelist[addr] = true;
      emit WhitelistedAddressAdded(addr);
      success = true;
    }
  }

   
  function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addAddressToWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

   
  function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
    if (whitelist[addr]) {
      whitelist[addr] = false;
      emit WhitelistedAddressRemoved(addr);
      success = true;
    }
  }

   
  function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (removeAddressFromWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

}

 

contract SEEDWhitelist is Whitelist {

   
  mapping (address => bool) public admin;

   
  modifier onlyAdmin() {
    require(admin[msg.sender]);
    _;
  }

  event SetAdmin(address indexed _addr, bool _value);

  function SEEDWhitelist() public {
    admin[msg.sender] = true;
  }

   
  function setAdmin(address _addr, bool _value)
    public
    onlyAdmin
    returns (bool)
  {
    require(_addr != address(0));
    require(admin[_addr] == !_value);

    admin[_addr] = _value;

    emit SetAdmin(_addr, _value);

    return true;
  }

   
  function addAddressToWhitelist(address addr) onlyAdmin public returns(bool success) {
    if (!whitelist[addr]) {
      whitelist[addr] = true;
      emit WhitelistedAddressAdded(addr);
      success = true;
    }
  }

   
  function addAddressesToWhitelist(address[] addrs) onlyAdmin public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addAddressToWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

   
  function removeAddressFromWhitelist(address addr) onlyAdmin public returns(bool success) {
    if (whitelist[addr]) {
      whitelist[addr] = false;
      emit WhitelistedAddressRemoved(addr);
      success = true;
    }
  }

   
  function removeAddressesFromWhitelist(address[] addrs) onlyAdmin public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (removeAddressFromWhitelist(addrs[i])) {
        success = true;
      }
    }
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

 

 
contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

   
  function RefundVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

   
  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    emit Closed();
    wallet.transfer(address(this).balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    emit RefundsEnabled();
  }

   
  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    emit Refunded(investor, depositedValue);
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

 

 
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

 

 
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

   
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}

 

 
 
 
contract SEEDCrowdsale is Ownable, CanReclaimToken, Pausable {
  using SafeMath for uint256;

   
  SEED public token;
  RefundVault public vault;
  SEEDWhitelist public whitelist;
  address public newTokenOwner = 0xb34f87a1fda8ff1cf412acb8e8f40583968b7172;

   
  uint256 public constant OPERATION_AMOUNT = 1.2e27;               
  uint256 public constant BOUNTY_AMOUNT = 600e24;                  
  uint256 public constant COMMON_BUDGET_AMOUNT = 1.44e27;          
  uint256 public constant INITIAL_SEED_FARMING_AMOUNT = 1.2e27;    
  uint256 public constant FOUNDER_AMOUNT = 960e24;                 
  uint256 public constant RESERVE_AMOUNT = 4.8e27;                 

  address public operationAdress;
  address public bountyAdress;
  address public commonBudgetAdress;
  address public initialSeedFarmingAdress;
  address public founderAdress;
  address public reserveAdress;

   
  uint256 public constant phase1MaxEtherCap = 4800 ether;  

   
  uint256 public constant phase2MaxEtherCap = 9600 ether;  

  uint256 public startTime;  
  uint256 public phase2StartTime;  
  uint256 public endTime;  

   
  uint256 public privateWeiRaised;  

  uint256 public phase1WeiRaised;  
  uint256 public phase2WeiRaised;  

  bool public isFinalized;

   
  uint256 public constant phase1Rate = 30000;  

   
  uint256[6] public phase2Rates;  
  uint256[6] public phase2RateOffsets;  

  uint256 public minPurchase = 1 ether;

  mapping (address => uint256) public purchaserFunded;
  uint256 public numPurchasers;

  mapping (address => uint256) public privateHolderClaimed;

   
  event TokenPurchase(address indexed _purchaser, address indexed _beneficiary, uint256 _value, uint256 _tokens);
  event TokenRateDecline(uint256 _pre, uint256 _post, uint256 _decrement);

  function SEEDCrowdsale(
    SEED _token,
    RefundVault _vault,
    SEEDWhitelist _whitelist,
    uint256 _startTime,
    uint256 _phase2StartTime,
    uint256 _endTime,
    uint256 _privateEtherFunded,
    address[6] _tokenHolders,
    uint256[6] _phase2RateOffsets)
    public
  {
    uint256 i;
     
    phase2Rates = [
      25000,
      22000,
      19500,
      17000,
      14500,
      12000
    ];

    require(address(_token) != address(0));
    require(address(_vault) != address(0));
    require(address(_whitelist) != address(0));

    token = _token;
    vault = _vault;
    whitelist = _whitelist;

    require(_startTime != 0);
    require(_phase2StartTime != 0);
    require(_endTime != 0);
    require(_startTime < _phase2StartTime);
    require(_phase2StartTime < _endTime);
    require(_privateEtherFunded != 0);

    startTime = _startTime;
    phase2StartTime = _phase2StartTime;
    endTime = _endTime;
    privateWeiRaised = _privateEtherFunded;

    for (i = 0; i < _tokenHolders.length; i++) {
      require(_tokenHolders[i] != address(0));
    }

    operationAdress = _tokenHolders[0];
    bountyAdress = _tokenHolders[1];
    commonBudgetAdress = _tokenHolders[2];
    initialSeedFarmingAdress = _tokenHolders[3];
    founderAdress = _tokenHolders[4];
    reserveAdress = _tokenHolders[5];

    for (i = 0; i < _phase2RateOffsets.length - 1; i++) {
      require(_phase2RateOffsets[i] < _phase2RateOffsets[i + 1]);
    }

    phase2RateOffsets = _phase2RateOffsets;
  }

  function() public payable {
    buyTokens(msg.sender);
  }

  function claimPrivateTokens(address[] _addrs, uint[] _amounts) external onlyOwner {
    require(_addrs.length == _amounts.length);

    for (uint i = 0; i < _addrs.length; i++) {
      if (privateHolderClaimed[_addrs[i]] == 0) {
        privateHolderClaimed[_addrs[i]] = _amounts[i];

        token.generateTokens(_addrs[i], _amounts[i]);
      }
    }
  }

  function totalWeiRaised() external view returns (uint256) {
    return privateWeiRaised.add(phase1WeiRaised).add(phase2WeiRaised);
  }

   
  function getRate() public view returns (uint256) {
    if (block.timestamp < phase2StartTime) {  
      return phase1Rate;
    }

    uint offset = block.timestamp.sub(phase2StartTime);  

    for (uint256 i = 0; i < phase2RateOffsets.length; i++) {
      if (offset < phase2RateOffsets[i]) {
        return phase2Rates[i];
      }
    }

    return 0;
  }

   
   
  function buyTokens(address _beneficiary) public payable whenNotPaused {
    validatePurchase();

    uint256 toFund = calculateToFund();
    uint256 toReturn = msg.value.sub(toFund);

    require(toFund > 0);

    uint256 rate = getRate();
    uint256 tokens = rate.mul(toFund);

    require(tokens > 0);

    if (block.timestamp < phase2StartTime) {  
      phase1WeiRaised = phase1WeiRaised.add(toFund);
    } else {
      phase2WeiRaised = phase2WeiRaised.add(toFund);
    }

    if (purchaserFunded[msg.sender] == 0) {
      numPurchasers = numPurchasers.add(1);
    }

    purchaserFunded[msg.sender] = purchaserFunded[msg.sender].add(toFund);
    token.generateTokens(_beneficiary, tokens);

    emit TokenPurchase(msg.sender, _beneficiary, toFund, tokens);  

    if (toReturn > 0) {
      msg.sender.transfer(toReturn);
    }

    vault.deposit.value(toFund)(msg.sender);
  }

   
  function finalize() public onlyOwner {
    require(hasEnded());  
    require(!isFinalized);

    isFinalized = true;

    token.generateTokens(operationAdress, OPERATION_AMOUNT);
    token.generateTokens(bountyAdress, BOUNTY_AMOUNT);
    token.generateTokens(commonBudgetAdress, COMMON_BUDGET_AMOUNT);
    token.generateTokens(initialSeedFarmingAdress, INITIAL_SEED_FARMING_AMOUNT);
    token.generateTokens(founderAdress, FOUNDER_AMOUNT);
    token.generateTokens(reserveAdress, RESERVE_AMOUNT);

    vault.close();

    token.enableTransfers(true);
    token.changeController(newTokenOwner);
    vault.transferOwnership(owner);
  }

  function hasEnded() public returns (bool) {
    bool afterEndTime = block.timestamp > endTime;  
    bool phase2CapReached = phase2WeiRaised == phase2MaxEtherCap;

    return afterEndTime || phase2CapReached;
  }

   
  function validatePurchase() internal {
    require(msg.value >= minPurchase);
    require(block.timestamp >= startTime && block.timestamp <= endTime);  
    require(!isFinalized);
    require(whitelist.whitelist(msg.sender));
  }

  function calculateToFund() internal returns (uint256) {
    uint256 cap;
    uint256 weiRaised;

    if (block.timestamp < phase2StartTime) {  
      cap = phase1MaxEtherCap;
      weiRaised = privateWeiRaised.add(phase1WeiRaised);
    } else {
      cap = phase2MaxEtherCap;
      weiRaised = phase2WeiRaised;
    }

    uint256 postWeiRaised = weiRaised.add(msg.value);

    if (postWeiRaised > cap) {
      return cap.sub(weiRaised);
    } else {
      return msg.value;
    }
  }
}