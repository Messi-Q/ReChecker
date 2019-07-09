code:pragma solidity ^0.4.24;


library SafeMath {

     
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
         
         
         
        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

     
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
         
         
         
        return _a / _b;
    }

     
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

     
    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}

contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


     
    constructor() public {
        owner = msg.sender;
    }

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

     
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

     
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
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

     
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

     
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

contract ERC20Basic {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address _owner, address _spender)
    public view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeERC20 {
    function safeTransfer(
        ERC20Basic _token,
        address _to,
        uint256 _value
    )
    internal
    {
        require(_token.transfer(_to, _value));
    }

    function safeTransferFrom(
        ERC20 _token,
        address _from,
        address _to,
        uint256 _value
    )
    internal
    {
        require(_token.transferFrom(_from, _to, _value));
    }

    function safeApprove(
        ERC20 _token,
        address _spender,
        uint256 _value
    )
    internal
    {
        require(_token.approve(_spender, _value));
    }
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) internal balances;

    uint256 internal totalSupply_;

     
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

     
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

     
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}

contract StandardToken is ERC20, BasicToken {

    mapping(address => mapping(address => uint256)) internal allowed;


     
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns (bool)
    {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns (uint256)
    {
        return allowed[_owner][_spender];
    }

     
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
    public
    returns (bool)
    {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
    public
    returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract DetailedERC20 is ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
}

contract MultiSigWallet {
    uint constant public MAX_OWNER_COUNT = 50;

    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);

    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;

    address[] public owners;
    uint public required;
    uint public transactionCount;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != 0);
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }

    modifier notNull(address _address) {
        require(_address != address(0));
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        bool ownerValid = ownerCount <= MAX_OWNER_COUNT;
        bool ownerNotZero = ownerCount != 0;
        bool requiredValid = _required <= ownerCount;
        bool requiredNotZero = _required != 0;
        require(ownerValid && ownerNotZero && requiredValid && requiredNotZero);
        _;
    }

     
    function() payable public {
        fallback();
    }

    function fallback() payable public {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

     
     
     
     
    constructor(
        address[] _owners,
        uint _required
    ) public validRequirement(_owners.length, _required)
    {
        for (uint i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != 0);
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

     
     
    function addOwner(address owner)
    public
    onlyWallet
    ownerDoesNotExist(owner)
    notNull(owner)
    validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

     
     
    function removeOwner(address owner)
    public
    onlyWallet
    ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint i = 0; i < owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

     
     
     
    function replaceOwner(address owner, address newOwner)
    public
    onlyWallet
    ownerExists(owner)
    ownerDoesNotExist(newOwner)
    {
        for (uint i = 0; i < owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

     
     
    function changeRequirement(uint _required)
    public
    onlyWallet
    validRequirement(owners.length, _required)
    {
        required = _required;
        emit RequirementChange(_required);
    }

     
     
     
     
     
    function submitTransaction(address destination, uint value, bytes data)
    public
    returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

     
     
    function confirmTransaction(uint transactionId) public ownerExists(msg.sender) transactionExists(transactionId) notConfirmed(transactionId, msg.sender) {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

     
     
    function revokeConfirmation(uint transactionId) public ownerExists(msg.sender) confirmed(transactionId, msg.sender) notExecuted(transactionId) {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

     
     
    function executeTransaction(uint transactionId) public ownerExists(msg.sender) confirmed(transactionId, msg.sender) notExecuted(transactionId) {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (txn.destination.call.value(txn.value)(txn.data))
                emit Execution(transactionId);
            else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

     
     
     
    function isConfirmed(uint transactionId) public view returns (bool) {
        uint count = 0;
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

     
     
     
     
     
     
    function addTransaction(address destination, uint value, bytes data)
    internal
    notNull(destination)
    returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination : destination,
            value : value,
            data : data,
            executed : false
            });
        transactionCount += 1;
        emit Submission(transactionId);
    }

     
     
     
     
    function getConfirmationCount(uint transactionId) public view returns (uint count) {
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                count += 1;
            }
        }
    }

     
     
     
     
    function getTransactionCount(
        bool pending,
        bool executed
    ) public view returns (uint count) {
        for (uint i = 0; i < transactionCount; i++) {
            if (pending &&
                !transactions[i].executed ||
                executed &&
                transactions[i].executed
            ) {
                count += 1;
            }
        }
    }

     
     
    function getOwners() public view returns (address[]) {
        return owners;
    }

     
     
     
    function getConfirmations(
        uint transactionId
    ) public view returns (address[] _confirmations) {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

     
     
     
     
     
     
    function getTransactionIds(
        uint from,
        uint to,
        bool pending,
        bool executed
    ) public view returns (uint[] _transactionIds) {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i = 0; i < transactionCount; i++)
            if (pending &&
                !transactions[i].executed ||
                executed &&
                transactions[i].executed
            ) {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i = from; i < to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}

contract JavvyMultiSig is MultiSigWallet {
    constructor(
        address[] _owners,
        uint _required
    )
    MultiSigWallet(_owners, _required)
    public {}
}

contract Config {
    uint256 public constant jvySupply = 333333333333333;
    uint256 public constant bonusSupply = 83333333333333;
    uint256 public constant saleSupply = 250000000000000;
    uint256 public constant hardCapUSD = 8000000;

    uint256 public constant preIcoBonus = 25;
    uint256 public constant minimalContributionAmount = 0.4 ether;

    function getStartPreIco() public view returns (uint256) {
         
        uint256 _preIcoStartTime = block.timestamp + 1 minutes;
        return _preIcoStartTime;
    }

    function getStartIco() public view returns (uint256) {
         
         
        uint256 _icoStartTime = block.timestamp + 2 minutes;
        return _icoStartTime;
    }

    function getEndIco() public view returns (uint256) {
         
         
         
        uint256 _icoEndTime = 1556668799;
        return _icoEndTime;
    }
}


contract JavvyToken is DetailedERC20, StandardToken, Ownable, Config {
    address public crowdsaleAddress;
    address public bonusAddress;
    address public multiSigAddress;

    constructor(
        string _name,
        string _symbol,
        uint8 _decimals
    ) public
    DetailedERC20(_name, _symbol, _decimals) {
        require(
            jvySupply == saleSupply + bonusSupply,
            "Sum of provided supplies is not equal to declared total Javvy supply. Check config!"
        );
        totalSupply_ = tokenToDecimals(jvySupply);
    }

    function initializeBalances(
        address _crowdsaleAddress,
        address _bonusAddress,
        address _multiSigAddress
    ) public
    onlyOwner() {
        crowdsaleAddress = _crowdsaleAddress;
        bonusAddress = _bonusAddress;
        multiSigAddress = _multiSigAddress;

        _initializeBalance(_crowdsaleAddress, saleSupply);
        _initializeBalance(_bonusAddress, bonusSupply);
    }

    function _initializeBalance(address _address, uint256 _supply) private {
        require(_address != address(0), "Address cannot be equal to 0x0!");
        require(_supply != 0, "Supply cannot be equal to 0!");
        balances[_address] = tokenToDecimals(_supply);
        emit Transfer(address(0), _address, _supply);
    }

    function tokenToDecimals(uint256 _amount) private view returns (uint256){
         
        return _amount * (10 ** 12);
    }

    function getRemainingSaleTokens() external view returns (uint256) {
        return balanceOf(crowdsaleAddress);
    }

}

contract Escrow is Ownable {
    using SafeMath for uint256;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private deposits;

    function depositsOf(address _payee) public view returns (uint256) {
        return deposits[_payee];
    }

     
    function deposit(address _payee) public onlyOwner payable {
        uint256 amount = msg.value;
        deposits[_payee] = deposits[_payee].add(amount);

        emit Deposited(_payee, amount);
    }

     
    function withdraw(address _payee) public onlyOwner {
        uint256 payment = deposits[_payee];
        assert(address(this).balance >= payment);

        deposits[_payee] = 0;

        _payee.transfer(payment);

        emit Withdrawn(_payee, payment);
    }
}

contract ConditionalEscrow is Escrow {
     
    function withdrawalAllowed(address _payee) public view returns (bool);

    function withdraw(address _payee) public {
        require(withdrawalAllowed(_payee));
        super.withdraw(_payee);
    }
}

contract RefundEscrow is Ownable, ConditionalEscrow {
    enum State {Active, Refunding, Closed}

    event Closed();
    event RefundsEnabled();

    State public state;
    address public beneficiary;

     
    constructor(address _beneficiary) public {
        require(_beneficiary != address(0));
        beneficiary = _beneficiary;
        state = State.Active;
    }

     
    function deposit(address _refundee) public payable {
        require(state == State.Active);
        super.deposit(_refundee);
    }

     
    function close() public onlyOwner {
        require(state == State.Active);
        state = State.Closed;
        emit Closed();
    }

     
    function enableRefunds() public onlyOwner {
        require(state == State.Active);
        state = State.Refunding;
        emit RefundsEnabled();
    }

     
    function beneficiaryWithdraw() public {
        require(state == State.Closed);
        beneficiary.transfer(address(this).balance);
    }

     
    function withdrawalAllowed(address _payee) public view returns (bool) {
        return state == State.Refunding;
    }
}

contract Crowdsale {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

     
    ERC20 public token;

     
    address public wallet;

     
     
     
     
    uint256 public rate;

     
    uint256 public weiRaised;

     
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

     
    constructor(uint256 _rate, address _wallet, ERC20 _token) public {
        require(_rate > 0);
        require(_wallet != address(0));
        require(_token != address(0));

        rate = _rate;
        wallet = _wallet;
        token = _token;
    }

     
     
     

     
    function() external payable {
        buyTokens(msg.sender);
    }

     
    function buyTokens(address _beneficiary) public payable {

        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

         
        uint256 tokens = _getTokenAmount(weiAmount);

         
        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(
            msg.sender,
            _beneficiary,
            weiAmount,
            tokens
        );

        _updatePurchasingState(_beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(_beneficiary, weiAmount);
    }

     
     
     

     
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
    internal
    {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }

     
    function _postValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
    internal
    {
         
    }

     
    function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount
    )
    internal
    {
        token.safeTransfer(_beneficiary, _tokenAmount);
    }

     
    function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount
    )
    internal
    {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

     
    function _updatePurchasingState(
        address _beneficiary,
        uint256 _weiAmount
    )
    internal
    {
         
    }

     
    function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
    {
        return _weiAmount.mul(rate);
    }

     
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }
}

contract CappedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 public cap;

     
    constructor(uint256 _cap) public {
        require(_cap > 0);
        cap = _cap;
    }

     
    function capReached() public view returns (bool) {
        return weiRaised >= cap;
    }

     
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
    internal
    {
        super._preValidatePurchase(_beneficiary, _weiAmount);
        require(weiRaised.add(_weiAmount) <= cap);
    }

}

contract TimedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 public openingTime;
    uint256 public closingTime;

     
    modifier onlyWhileOpen {
         
        require(block.timestamp >= openingTime && block.timestamp <= closingTime);
        _;
    }

     
    constructor(uint256 _openingTime, uint256 _closingTime) public {
         
        require(_openingTime >= block.timestamp);
        require(_closingTime >= _openingTime);

        openingTime = _openingTime;
        closingTime = _closingTime;
    }

     
    function hasClosed() public view returns (bool) {
         
        return block.timestamp > closingTime;
    }

     
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
    internal
    onlyWhileOpen
    {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }

}

contract FinalizableCrowdsale is Ownable, TimedCrowdsale {
    using SafeMath for uint256;

    bool public isFinalized = false;

    event Finalized();

     
    function finalize() public onlyOwner {
        require(!isFinalized);
        require(hasClosed());

        finalization();
        emit Finalized();

        isFinalized = true;
    }

     
    function finalization() internal {
    }

}

contract RefundableCrowdsale is FinalizableCrowdsale {
    using SafeMath for uint256;

     
    uint256 public goal;

     
    RefundEscrow private escrow;

     
    constructor(uint256 _goal) public {
        require(_goal > 0);
        escrow = new RefundEscrow(wallet);
        goal = _goal;
    }

     
    function claimRefund() public {
        require(isFinalized);
        require(!goalReached());

        escrow.withdraw(msg.sender);
    }

     
    function goalReached() public view returns (bool) {
        return weiRaised >= goal;
    }

     
    function finalization() internal {
        if (goalReached()) {
            escrow.close();
            escrow.beneficiaryWithdraw();
        } else {
            escrow.enableRefunds();
        }

        super.finalization();
    }

     
    function _forwardFunds() internal {
        escrow.deposit.value(msg.value)(msg.sender);
    }

}

contract JavvyCrowdsale is RefundableCrowdsale, CappedCrowdsale, Pausable, Config {
    uint256 public icoStartTime;
    address public transminingAddress;
    address public bonusAddress;
    uint256 private USDETHRate;

    mapping(address => bool) public blacklisted;

    JavvyToken token;

    enum Stage {
        NotStarted,
        PreICO,
        ICO,
        AfterICO
    }

    function getStage() public view returns (Stage) {
         
        uint256 blockTime = block.timestamp;
        if (blockTime < openingTime) return Stage.NotStarted;
        if (blockTime < icoStartTime) return Stage.PreICO;
        if (blockTime < closingTime) return Stage.ICO;
        else return Stage.AfterICO;
    }

    constructor(
        uint256 _rate,
        JavvyMultiSig _wallet,
        JavvyToken _token,
     
     
        uint256 _cap,
        uint256 _goal,
        address _bonusAddress,
        address[] _blacklistAddresses,
        uint256 _USDETHRate
    )
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap)
    TimedCrowdsale(getStartPreIco(), getEndIco())
    RefundableCrowdsale(_goal)
    public {
         
        require(getStartIco() > block.timestamp, "ICO has to begin in the future");
        require(getEndIco() > block.timestamp, "ICO has to end in the future");
        require(_goal <= _cap, "Soft cap should be equal or smaller than hard cap");
        icoStartTime = getStartIco();
        bonusAddress = _bonusAddress;
        token = _token;
        for (uint256 i = 0; i < _blacklistAddresses.length; i++) {
            blacklisted[_blacklistAddresses[i]] = true;
        }
        setUSDETHRate(_USDETHRate);
         
         
        weiRaised = 46461161522138564065713;
    }

    function buyTokens(address _beneficiary) public payable {
        require(!blacklisted[msg.sender], "Sender is blacklisted");
        bool preallocated = false;
        uint256 preallocatedTokens = 0;

        _buyTokens(
            _beneficiary,
            msg.sender,
            msg.value,
            preallocated,
            preallocatedTokens
        );
    }

    function bulkPreallocate(address[] _owners, uint256[] _tokens, uint256[] _paid)
    public
    onlyOwner() {
        require(
            _owners.length == _tokens.length,
            "Lengths of parameter lists have to be equal"
        );
        require(
            _owners.length == _paid.length,
            "Lengths of parameter lists have to be equal"
        );
        for (uint256 i = 0; i < _owners.length; i++) {
            preallocate(_owners[i], _tokens[i], _paid[i]);
        }
    }

    function preallocate(address _owner, uint256 _tokens, uint256 _paid)
    public
    onlyOwner() {
        require(!blacklisted[_owner], "Address where tokens will be sent is blacklisted");
        bool preallocated = true;
        uint256 preallocatedTokens = _tokens;

        _buyTokens(
            _owner,
            _owner,
            _paid,
            preallocated,
            preallocatedTokens
        );
    }

    function setTransminingAddress(address _transminingAddress) public
    onlyOwner() {
        transminingAddress = _transminingAddress;
    }

     
    function moveTokensToTransmining(uint256 _amount) public
    onlyOwner() {
        uint256 remainingTokens = token.getRemainingSaleTokens();
        require(
            transminingAddress != address(0),
            "Transmining address must be set!"
        );
        require(
            remainingTokens >= _amount,
            "Balance of remaining tokens for sale is smaller than requested amount for trans-mining"
        );
        uint256 weiNeeded = cap - weiRaised;
        uint256 tokensNeeded = weiNeeded * rate;

        if (getStage() != Stage.AfterICO) {
            require(remainingTokens - _amount > tokensNeeded, "You need to leave enough tokens to reach hard cap");
        }
        _deliverTokens(transminingAddress, _amount, this);
    }

    function _buyTokens(
        address _beneficiary,
        address _sender,
        uint256 _value,
        bool _preallocated,
        uint256 _tokens
    ) internal
    whenNotPaused() {
        uint256 tokens;

        if (!_preallocated) {
             
            require(
                _value >= minimalContributionAmount,
                "Amount contributed should be greater than required minimal contribution"
            );
            require(_tokens == 0, "Not preallocated tokens should be zero");
            _preValidatePurchase(_beneficiary, _value);
        } else {
            require(_tokens != 0, "Preallocated tokens should be greater than zero");
            require(weiRaised.add(_value) <= cap, "Raised tokens should not exceed hard cap");
        }

         
        if (!_preallocated) {
            tokens = _getTokenAmount(_value);
        } else {
            tokens = _tokens;
        }

         
        weiRaised = weiRaised.add(_value);

        _processPurchase(_beneficiary, tokens, this);

        emit TokenPurchase(
            _sender,
            _beneficiary,
            _value,
            tokens
        );

         
        _updatePurchasingState(_beneficiary, _value);
        _forwardFunds();

         
        if (!_preallocated) {
            _postValidatePurchase(_beneficiary, _value);
        }
    }

    function _getBaseTokens(uint256 _value) internal view returns (uint256) {
        return _value.mul(rate);
    }

    function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256) {
        uint256 baseTokens = _getBaseTokens(_weiAmount);
        if (getStage() == Stage.PreICO) {
            return baseTokens.mul(100 + preIcoBonus).div(100);
        } else {
            return baseTokens;
        }
    }

    function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount,
        address _sourceAddress
    ) internal {
        _deliverTokens(_beneficiary, _tokenAmount, _sourceAddress);
    }

    function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount,
        address _sourceAddress
    ) internal {
        if (_sourceAddress == address(this)) {
            token.transfer(_beneficiary, _tokenAmount);
        } else {
            token.transferFrom(_sourceAddress, _beneficiary, _tokenAmount);
        }
    }

    function finalization() internal {
        require(
            transminingAddress != address(0),
            "Transmining address must be set!"
        );
        super.finalization();

        _deliverTokens(transminingAddress, token.getRemainingSaleTokens(), this);
    }

    function setUSDETHRate(uint256 _USDETHRate) public
    onlyOwner() {
        require(_USDETHRate > 0, "USDETH rate should not be zero");
        USDETHRate = _USDETHRate;
        cap = hardCapUSD.mul(USDETHRate);
    }
}