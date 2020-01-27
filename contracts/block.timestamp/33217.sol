pragma solidity ^0.4.11;

contract BlockchainDeposit {
   modifier onlyBy(address _account)
    {
        require(msg.sender == _account);
        _;
    }
  event GainsCalculated(
    address receiver,
    uint payedAmount,
    uint gains,
    uint contractBalance,
    uint currentPayoutIndex
  );

  event FeesCalculated(
    uint gains,
    uint fees
  );

  event Payout(
    address receiver,
    uint value
  );

  event FeesPayout(
    uint value
  );

  event FundsDeposited(
    address depositor,
    uint termDeposit,
    uint procent,
    uint typeDeposit,
    uint amount
  );

  event ComputedGainsRate(
    address depositor,
    uint gainsRate
  );

  struct Deposit {
    address depositor;
    uint amount;
  }

  struct PayoutItem {
    address receiver;
    uint amount;
  }

  string[] Currencies = ["DBC", "ETH", "BTC"]; // or other erc20 token
  uint[] Term = [3,7,14,21,30,90,180,365]; // Term deposit in day
  address public master;
  uint public feesRate;
  uint public feesRateTeam;
  uint public feesRateCongres;
  uint public feesProfitDeposit;
  uint public garanteSystemDepositInOneFund;
  uint public garanteSystemDepositInAllFunds;
  uint public numDeposits;
  uint public totalDeposited;
  uint public totalGains;
  uint public lastDeposit;
  uint public profitsRatePercent;
  uint public refferalsRateBonus;
  uint public refereesRateBonus;
  bool public active;
  uint private currentPayoutIndex;

  mapping (uint => Deposit) public depositsStack;

  mapping (address => uint) public refereesCount;
  mapping (address => uint) public pendingReferals;
  mapping (address => uint) public addressGains;
  mapping (address => uint[]) public addressPositions;
  mapping (address => address) public refereeInvitations;
  mapping (address => bool) public refereds;

  PayoutItem[] public lastPayouts;
  function BlockchainDeposit() {
    master = msg.sender;
    feesRate =0;
    feesRateTeam = 20; //0.2%
    feesRateCongres = 30; // 0.3%
    feesProfitDeposit = 1000; // 10%
    garanteSystemDepositInOneFund = 100000000000; // < 1000 USD (this value confifured Congres)
    garanteSystemDepositInAllFunds = 500000000000; // < 5000 USD (this value confifured Congres)
    numDeposits = 0;
    currentPayoutIndex = 0;
    profitsRatePercent = 0;
    refferalsRateBonus = 5;
    refereesRateBonus = 0;
    totalDeposited = 0;
    totalGains = 0;
    active = true;
  }

  function deposit() payable {
    if(msg.value <= 0) throw;
    lastDeposit = block.timestamp;
    depositsStack[numDeposits] = Deposit(msg.sender, msg.value);
    totalDeposited += msg.value;

    checkIfReferee(msg.sender);
    FundsDeposited(msg.sender, 3, 10, 0, msg.value);
    ++numDeposits;

    addressPositions[msg.sender].push(numDeposits);

    if(active) {
      dispatchGains();
    }
  }


  function getPayout(uint index) public constant returns (address receiver, uint amount) {
    PayoutItem memory payout;
    payout = lastPayouts[index];
    return (payout.receiver, payout.amount);
  }

  function getLastPayouts() public constant returns (address[10] lastReceivers, uint[10] lastAmounts) {
    uint j = 0;
    PayoutItem memory currentPayout;
    uint length = lastPayouts.length;
    uint startIndex = 0;

    if (length > 10) {
      startIndex = length - 10;
    }

    for(uint i = startIndex; i < length; i++) {
      currentPayout = lastPayouts[i];
      lastReceivers[j] = currentPayout.receiver;
      lastAmounts[j] = currentPayout.amount;
      j++;
    }

    return (lastReceivers, lastAmounts);
  }

  function getMaster() constant returns (address masterAddress) {
    return master;
  }

  function getnumDeposits() constant returns (uint) {
    return numDeposits;
  }

  function getContractMetrics() constant returns (uint, uint, uint, uint, bool) {
    return (
      this.balance,
      totalDeposited,
      totalGains,
      numDeposits,
      active
    );
  }

  function inviteReferee(address referer, address referee) returns (bool success) {
    success = true;

    refereeInvitations[referee] = referer;
    pendingReferals[referer] += 1;
    return success;
  }

  function createReferee(address referer, address referee) private {
    refereds[referee] = true;
    refereesCount[referer] += 1;
    pendingReferals[referer] -= 1;
  }

  function checkIfReferee(address referee) private {
    address referer = refereeInvitations[referee];
    if(referer != address(0)) {
      createReferee(referer, referee);
      delete refereeInvitations[referee];
    }
  }

  function getAddressGains(address addr) constant returns(uint) {
    return addressGains[addr];
  }

  function getCurrentPayoutIndex() constant returns(uint) {
    return currentPayoutIndex;
  }

  function getEarliestPosition(address addr) constant returns(uint[]) {
    return  addressPositions[addr];
  }


  function resetBonuses(address depositor) private {
    resetReferee(depositor);
    resetReferedCount(depositor);
  }


  function resetReferee(address depositor) private {
    refereds[depositor] = false;
  }

  function resetReferedCount(address depositor) private {
    refereesCount[depositor] = 0;
  }

  function getAccountReferalsStats(address addr) constant returns(uint, uint) {

    return (
      getPendingReferals(addr),
      getReferedCount(addr)
    );
  }

  function computeGainsRate(address depositor) constant returns(uint gainsPercentage) {
    gainsPercentage = profitsRatePercent;
    if(isReferee(depositor)) {
      gainsPercentage += refferalsRateBonus;
    }

    gainsPercentage += getReferedCount(depositor) * refereesRateBonus;

    ComputedGainsRate(depositor, gainsPercentage);
    return gainsPercentage;
  }

 function computeGains(Deposit deposit) private constant returns (uint gains, uint fees) {
    gains = 0;

    if(deposit.amount > 0) {
      gains = (deposit.amount * computeGainsRate(deposit.depositor)) / 100;
      fees = (gains * feesRate) / 100;

      GainsCalculated(deposit.depositor, deposit.amount, gains, this.balance, currentPayoutIndex);
      FeesCalculated(gains, fees);
    }

    return (
      gains - fees,
      fees
    );
  }

  function isReferee(address referee) private constant returns (bool) {
    return refereds[referee];
  }

  function getReferedCount(address referer) private constant returns (uint referedsCount) {
    referedsCount = refereesCount[referer];
    return referedsCount;
  }

  function getPendingReferals(address addr) private constant returns (uint) {
    return  pendingReferals[addr];
  }

  function addNewPayout(PayoutItem payout) private {
    lastPayouts.length++;
    lastPayouts[lastPayouts.length-1] = payout;
  }

  function payout(Deposit deposit) private {

    var (gains, fees) = computeGains(deposit);
    bool success = false;
    bool feesSuccess = false;
    uint payableAmount = deposit.amount + gains;
    address currentDepositor = deposit.depositor;

    if(gains > 0 && this.balance > payableAmount) {
      success = currentDepositor.send( payableAmount );
      if (success) {
        Payout(currentDepositor, payableAmount);
        addNewPayout(PayoutItem(currentDepositor, payableAmount));
        feesSuccess = master.send(fees);
        if(feesSuccess) {
          FeesPayout(fees);
        }
        resetBonuses(currentDepositor);
        addressGains[currentDepositor] += gains;
        totalGains += gains;
        currentPayoutIndex ++;
      }
    }
  }

  function dispatchGains() public {

    for (uint i = currentPayoutIndex; i<numDeposits; i++){
      payout(depositsStack[i]);
    }
  }

  function() public payable {
    deposit();
  }
}