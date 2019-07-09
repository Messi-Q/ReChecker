 

 
 
library AccountingLib {
         
        struct Bank {
            mapping (address => uint) accountBalances;
        }

         
         
         
         
        function addFunds(Bank storage self, address accountAddress, uint value) public {
                if (self.accountBalances[accountAddress] + value < self.accountBalances[accountAddress]) {
                         
                        throw;
                }
                self.accountBalances[accountAddress] += value;
        }

        event _Deposit(address indexed _from, address indexed accountAddress, uint value);
         
         
         
         
        function Deposit(address _from, address accountAddress, uint value) public {
            _Deposit(_from, accountAddress, value);
        }


         
         
         
         
        function deposit(Bank storage self, address accountAddress, uint value) public returns (bool) {
                addFunds(self, accountAddress, value);
                return true;
        }

        event _Withdrawal(address indexed accountAddress, uint value);

         
         
         
        function Withdrawal(address accountAddress, uint value) public {
            _Withdrawal(accountAddress, value);
        }

        event _InsufficientFunds(address indexed accountAddress, uint value, uint balance);

         
         
         
         
        function InsufficientFunds(address accountAddress, uint value, uint balance) public {
            _InsufficientFunds(accountAddress, value, balance);
        }

         
         
         
         
        function deductFunds(Bank storage self, address accountAddress, uint value) public {
                 
                if (value > self.accountBalances[accountAddress]) {
                         
                        throw;
                }
                self.accountBalances[accountAddress] -= value;
        }

         
         
         
         
        function withdraw(Bank storage self, address accountAddress, uint value) public returns (bool) {
                 
                if (self.accountBalances[accountAddress] >= value) {
                        deductFunds(self, accountAddress, value);
                        if (!accountAddress.send(value)) {

                                if (!accountAddress.call.value(value)()) {

                                        throw;
                                }
                        }
                        return true;
                }
                return false;
        }

        uint constant DEFAULT_SEND_GAS = 100000;

        function sendRobust(address toAddress, uint value) public returns (bool) {
                if (msg.gas < DEFAULT_SEND_GAS) {
                    return sendRobust(toAddress, value, msg.gas);
                }
                return sendRobust(toAddress, value, DEFAULT_SEND_GAS);
        }

        function sendRobust(address toAddress, uint value, uint maxGas) public returns (bool) {
                if (value > 0 && !toAddress.send(value)) {

                        if (!toAddress.call.gas(maxGas).value(value)()) {
                                return false;
                        }
                }
                return true;
        }
}


library CallLib {
     
    struct Call {
        address contractAddress;
        bytes4 abiSignature;
        bytes callData;
        uint callValue;
        uint anchorGasPrice;
        uint requiredGas;
        uint16 requiredStackDepth;

        address claimer;
        uint claimAmount;
        uint claimerDeposit;

        bool wasSuccessful;
        bool wasCalled;
        bool isCancelled;
    }

    enum State {
        Pending,
        Unclaimed,
        Claimed,
        Frozen,
        Callable,
        Executed,
        Cancelled,
        Missed
    }

    function state(Call storage self) constant returns (State) {
        if (self.isCancelled) return State.Cancelled;
        if (self.wasCalled) return State.Executed;

        var call = FutureBlockCall(this);

        if (block.number + CLAIM_GROWTH_WINDOW + MAXIMUM_CLAIM_WINDOW + BEFORE_CALL_FREEZE_WINDOW < call.targetBlock()) return State.Pending;
        if (block.number + BEFORE_CALL_FREEZE_WINDOW < call.targetBlock()) {
            if (self.claimer == 0x0) {
                return State.Unclaimed;
            }
            else {
                return State.Claimed;
            }
        }
        if (block.number < call.targetBlock()) return State.Frozen;
        if (block.number < call.targetBlock() + call.gracePeriod()) return State.Callable;
        return State.Missed;
    }

     
     
    uint constant CALL_WINDOW_SIZE = 16;

    address constant creator = 0xd3cda913deb6f67967b99d67acdfa1712c293601;

    function extractCallData(Call storage call, bytes data) public {
        call.callData.length = data.length - 4;
        if (data.length > 4) {
                for (uint i = 0; i < call.callData.length; i++) {
                        call.callData[i] = data[i + 4];
                }
        }
    }

    uint constant GAS_PER_DEPTH = 700;

    function checkDepth(uint n) constant returns (bool) {
        if (n == 0) return true;
        return address(this).call.gas(GAS_PER_DEPTH * n)(bytes4(sha3("__dig(uint256)")), n - 1);
    }

    function sendSafe(address to_address, uint value) public returns (uint) {
        if (value > address(this).balance) {
            value = address(this).balance;
        }
        if (value > 0) {
            AccountingLib.sendRobust(to_address, value);
            return value;
        }
        return 0;
    }

    function getGasScalar(uint base_gas_price, uint gas_price) constant returns (uint) {
         
        if (gas_price > base_gas_price) {
            return 100 * base_gas_price / gas_price;
        }
        else {
            return 200 - 100 * base_gas_price / (2 * base_gas_price - gas_price);
        }
    }

    event CallExecuted(address indexed executor, uint gasCost, uint payment, uint donation, bool success);

    bytes4 constant EMPTY_SIGNATURE = 0x0000;

    event CallAborted(address executor, bytes32 reason);

    function execute(Call storage self, uint start_gas, address executor, uint overhead, uint extraGas) public {
        FutureCall call = FutureCall(this);
        
         
        self.wasCalled = true;
         
        if (self.abiSignature == EMPTY_SIGNATURE && self.callData.length == 0) {
            self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)();
        }
        else if (self.abiSignature == EMPTY_SIGNATURE) {
            self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.callData);
        }
        else if (self.callData.length == 0) {
            self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature);
        }
        else {
            self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature, self.callData);
        }

        call.origin().call(bytes4(sha3("updateDefaultPayment()")));

         
        uint gasScalar = getGasScalar(self.anchorGasPrice, tx.gasprice);

        uint basePayment;
        if (self.claimer == executor) {
            basePayment = self.claimAmount;
        }
        else {
            basePayment = call.basePayment();
        }
        uint payment = self.claimerDeposit + basePayment * gasScalar / 100; 
        uint donation = call.baseDonation() * gasScalar / 100;

         
        self.claimerDeposit = 0;

         
         
         
        uint gasCost = tx.gasprice * (start_gas - msg.gas + extraGas);

         
        payment = sendSafe(executor, payment + gasCost);
        donation = sendSafe(creator, donation);

         
        CallExecuted(executor, gasCost, payment, donation, self.wasSuccessful);
    }

    event Cancelled(address indexed cancelled_by);

    function cancel(Call storage self, address sender) public {
        Cancelled(sender);
        if (self.claimerDeposit >= 0) {
            sendSafe(self.claimer, self.claimerDeposit);
        }
        var call = FutureCall(this);
        sendSafe(call.schedulerAddress(), address(this).balance);
        self.isCancelled = true;
    }

     
    event Claimed(address executor, uint claimAmount);

     
     
    uint constant CLAIM_GROWTH_WINDOW = 240;

     
     
    uint constant MAXIMUM_CLAIM_WINDOW = 15;

     
     
     
    uint constant BEFORE_CALL_FREEZE_WINDOW = 10;

     
    function getClaimAmountForBlock(uint block_number) constant returns (uint) {
         
        var call = FutureBlockCall(this);

        uint cutoff = call.targetBlock() - BEFORE_CALL_FREEZE_WINDOW;
        
         
        if (block_number > cutoff) return call.basePayment();

        cutoff -= MAXIMUM_CLAIM_WINDOW;

         
        if (block_number > cutoff) return call.basePayment();

        cutoff -= CLAIM_GROWTH_WINDOW;

        if (block_number > cutoff) {
            uint x = block_number - cutoff;

            return call.basePayment() * x / CLAIM_GROWTH_WINDOW;
        }

        return 0;
    }

    function lastClaimBlock() constant returns (uint) {
        var call = FutureBlockCall(this);
        return call.targetBlock() - BEFORE_CALL_FREEZE_WINDOW;
    }

    function maxClaimBlock() constant returns (uint) {
        return lastClaimBlock() - MAXIMUM_CLAIM_WINDOW;
    }

    function firstClaimBlock() constant returns (uint) {
        return maxClaimBlock() - CLAIM_GROWTH_WINDOW;
    }

    function claim(Call storage self, address executor, uint deposit_amount, uint basePayment) public returns (bool) {
         
         
        if (deposit_amount < 2 * basePayment) return false;

        self.claimAmount = getClaimAmountForBlock(block.number);
        self.claimer = executor;
        self.claimerDeposit = deposit_amount;

         
        Claimed(executor, self.claimAmount);
    }

    function checkExecutionAuthorization(Call storage self, address executor, uint block_number) returns (bool) {
         
        var call = FutureBlockCall(this);

        uint targetBlock = call.targetBlock();

         
        if (block_number < targetBlock || block_number > targetBlock + call.gracePeriod()) throw;

         
         
        if (block_number - targetBlock < CALL_WINDOW_SIZE) {
        return (self.claimer == 0x0 || self.claimer == executor);
        }

         
        return true;
    }

    function isCancellable(Call storage self, address caller) returns (bool) {
        var _state = state(self);
        var call = FutureBlockCall(this);

        if (_state == State.Pending && caller == call.schedulerAddress()) {
            return true;
        }

        if (_state == State.Missed) return true;

        return false;
    }

    function beforeExecuteForFutureBlockCall(Call storage self, address executor, uint startGas) returns (bool) {
        bytes32 reason;

        var call = FutureBlockCall(this);

        if (startGas < self.requiredGas) {
             
            reason = "NOT_ENOUGH_GAS";
        }
        else if (self.wasCalled) {
             
            reason = "ALREADY_CALLED";
        }
        else if (block.number < call.targetBlock() || block.number > call.targetBlock() + call.gracePeriod()) {
             
            reason = "NOT_IN_CALL_WINDOW";
        }
        else if (!checkExecutionAuthorization(self, executor, block.number)) {
             
             
            reason = "NOT_AUTHORIZED";
        }
        else if (self.requiredStackDepth > 0 && executor != tx.origin && !checkDepth(self.requiredStackDepth)) {
            reason = "STACK_TOO_DEEP";
        }

        if (reason != 0x0) {
            CallAborted(executor, reason);
            return false;
        }

        return true;
    }
}


contract FutureCall {
     
    address constant creator = 0xd3cda913deb6f67967b99d67acdfa1712c293601;

    address public schedulerAddress;

    uint public basePayment;
    uint public baseDonation;

    CallLib.Call call;

    address public origin;

    function FutureCall(address _schedulerAddress,
                        uint _requiredGas,
                        uint16 _requiredStackDepth,
                        address _contractAddress,
                        bytes4 _abiSignature,
                        bytes _callData,
                        uint _callValue,
                        uint _basePayment,
                        uint _baseDonation)
    {
        origin = msg.sender;
        schedulerAddress = _schedulerAddress;

        basePayment = _basePayment;
        baseDonation = _baseDonation;

        call.requiredGas = _requiredGas;
        call.requiredStackDepth = _requiredStackDepth;
        call.anchorGasPrice = tx.gasprice;
        call.contractAddress = _contractAddress;
        call.abiSignature = _abiSignature;
        call.callData = _callData;
        call.callValue = _callValue;
    }

    enum State {
        Pending,
        Unclaimed,
        Claimed,
        Frozen,
        Callable,
        Executed,
        Cancelled,
        Missed
    }

    modifier in_state(State _state) { if (state() == _state) _ }

    function state() constant returns (State) {
        return State(CallLib.state(call));
    }

     
    function beforeExecute(address executor, uint startGas) public returns (bool);
    function afterExecute(address executor) internal;
    function getOverhead() constant returns (uint);
    function getExtraGas() constant returns (uint);

     
    function contractAddress() constant returns (address) {
        return call.contractAddress;
    }

    function abiSignature() constant returns (bytes4) {
        return call.abiSignature;
    }

    function callData() constant returns (bytes) {
        return call.callData;
    }

    function callValue() constant returns (uint) {
        return call.callValue;
    }

    function anchorGasPrice() constant returns (uint) {
        return call.anchorGasPrice;
    }

    function requiredGas() constant returns (uint) {
        return call.requiredGas;
    }

    function requiredStackDepth() constant returns (uint16) {
        return call.requiredStackDepth;
    }

    function claimer() constant returns (address) {
        return call.claimer;
    }

    function claimAmount() constant returns (uint) {
        return call.claimAmount;
    }

    function claimerDeposit() constant returns (uint) {
        return call.claimerDeposit;
    }

    function wasSuccessful() constant returns (bool) {
        return call.wasSuccessful;
    }

    function wasCalled() constant returns (bool) {
        return call.wasCalled;
    }

    function isCancelled() constant returns (bool) {
        return call.isCancelled;
    }

     
    function getClaimAmountForBlock() constant returns (uint) {
        return CallLib.getClaimAmountForBlock(block.number);
    }

    function getClaimAmountForBlock(uint block_number) constant returns (uint) {
        return CallLib.getClaimAmountForBlock(block_number);
    }

     
    function () returns (bool) {
         
         
        if (msg.sender != schedulerAddress) return false;
         
        if (call.callData.length > 0) return false;

        var _state = state();
        if (_state != State.Pending && _state != State.Unclaimed && _state != State.Claimed) return false;

        call.callData = msg.data;
        return true;
    }

    function registerData() public returns (bool) {
         
        if (msg.sender != schedulerAddress) return false;
         
        if (call.callData.length > 0) return false;

        var _state = state();
        if (_state != State.Pending && _state != State.Unclaimed && _state != State.Claimed) return false;

        CallLib.extractCallData(call, msg.data);
    }

    function firstClaimBlock() constant returns (uint) {
        return CallLib.firstClaimBlock();
    }

    function maxClaimBlock() constant returns (uint) {
        return CallLib.maxClaimBlock();
    }

    function lastClaimBlock() constant returns (uint) {
        return CallLib.lastClaimBlock();
    }

    function claim() public in_state(State.Unclaimed) returns (bool) {
        bool success = CallLib.claim(call, msg.sender, msg.value, basePayment);
        if (!success) {
            if (!AccountingLib.sendRobust(msg.sender, msg.value)) throw;
        }
        return success;
    }

    function checkExecutionAuthorization(address executor, uint block_number) constant returns (bool) {
        return CallLib.checkExecutionAuthorization(call, executor, block_number);
    }

    function sendSafe(address to_address, uint value) internal {
        CallLib.sendSafe(to_address, value);
    }

    function execute() public in_state(State.Callable) {
        uint start_gas = msg.gas;

         
        if (!beforeExecute(msg.sender, start_gas)) return;

         
        CallLib.execute(call, start_gas, msg.sender, getOverhead(), getExtraGas());

         
         
        afterExecute(msg.sender);
    }
}


contract FutureBlockCall is FutureCall {
    uint public targetBlock;
    uint8 public gracePeriod;

    uint constant CALL_API_VERSION = 2;

    function callAPIVersion() constant returns (uint) {
        return CALL_API_VERSION;
    }

    function FutureBlockCall(address _schedulerAddress,
                             uint _targetBlock,
                             uint8 _gracePeriod,
                             address _contractAddress,
                             bytes4 _abiSignature,
                             bytes _callData,
                             uint _callValue,
                             uint _requiredGas,
                             uint16 _requiredStackDepth,
                             uint _basePayment,
                             uint _baseDonation)
        FutureCall(_schedulerAddress, _requiredGas, _requiredStackDepth, _contractAddress, _abiSignature, _callData, _callValue, _basePayment, _baseDonation)
    {
         
        schedulerAddress = _schedulerAddress;

        targetBlock = _targetBlock;
        gracePeriod = _gracePeriod;
    }

    uint constant GAS_PER_DEPTH = 700;

    function __dig(uint n) constant returns (bool) {
        if (n == 0) return true;
        if (!address(this).callcode(bytes4(sha3("__dig(uint256)")), n - 1)) throw;
    }


    function beforeExecute(address executor, uint startGas) public returns (bool) {
        return CallLib.beforeExecuteForFutureBlockCall(call, executor, startGas);
    }

    function afterExecute(address executor) internal {
         
        CallLib.sendSafe(schedulerAddress, address(this).balance);
    }

    uint constant GAS_OVERHEAD = 100000;

    function getOverhead() constant returns (uint) {
            return GAS_OVERHEAD;
    }

    uint constant EXTRA_GAS = 77000;

    function getExtraGas() constant returns (uint) {
            return EXTRA_GAS;
    }

    uint constant CLAIM_GROWTH_WINDOW = 240;
    uint constant MAXIMUM_CLAIM_WINDOW = 15;
    uint constant BEFORE_CALL_FREEZE_WINDOW = 10;

    function isCancellable() constant public returns (bool) {
        return CallLib.isCancellable(call, msg.sender);
    }

    function cancel() public {
        if (CallLib.isCancellable(call, msg.sender)) {
            CallLib.cancel(call, msg.sender);
        }
    }
}