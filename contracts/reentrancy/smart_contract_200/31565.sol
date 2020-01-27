pragma solidity ^0.4.18;


 
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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


contract Telcoin {
    using SafeMath for uint256;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    string public constant name = "Telcoin";
    string public constant symbol = "TEL";
    uint8 public constant decimals = 2;

     
    uint256 public constant totalSupply = 100000000000 * (10 ** uint256(decimals));

     
    mapping(address => uint256) balances;

     
    mapping (address => mapping (address => uint256)) internal allowed;

     
     
     
    function Telcoin(address _distributor) public {
        balances[_distributor] = totalSupply;
        Transfer(0x0, _distributor, totalSupply);
    }

     
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

     
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

         
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

     
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


contract TelcoinSaleToken {
    using SafeMath for uint256;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    event Redeem(address indexed beneficiary, uint256 sacrificedValue, uint256 grantedValue);
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    address public owner;

     
    uint256 public totalSupply;

     
    mapping(address => uint256) balances;
    mapping(address => uint256) redeemed;

     
    bool public mintingFinished = false;

     
    Telcoin telcoin;
    uint256 public totalRedeemed;

     
    uint256 vestingStart;
    uint256 vestingDuration;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function TelcoinSaleToken(
        Telcoin _telcoin,
        uint256 _vestingStart,
        uint256 _vestingDuration
    )
        public
    {
        owner = msg.sender;
        telcoin = _telcoin;
        vestingStart = _vestingStart;
        vestingDuration = _vestingDuration;
    }

    function finishMinting() onlyOwner public returns (bool) {
        require(!mintingFinished);

        mintingFinished = true;
        MintFinished();

        return true;
    }

    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        require(_to != 0x0);
        require(!mintingFinished);
        require(_amount > 0);

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);

        return true;
    }

    function redeemMany(address[] _beneficiaries) public {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            redeem(_beneficiaries[i]);
        }
    }

    function redeem(address _beneficiary) public returns (uint256) {
        require(mintingFinished);
        require(_beneficiary != 0x0);

        uint256 balance = redeemableBalance(_beneficiary);
        if (balance == 0) {
            return 0;
        }

        uint256 totalDistributable = telcoin.balanceOf(this).add(totalRedeemed);

         
         
        uint256 amount = balance.mul(10 ** 18).div(totalSupply).mul(totalDistributable).div(10 ** 18);

        balances[_beneficiary] = balances[_beneficiary].sub(balance);
        redeemed[_beneficiary] = redeemed[_beneficiary].add(balance);
        balances[telcoin] = balances[telcoin].add(balance);
        totalRedeemed = totalRedeemed.add(amount);

        Transfer(_beneficiary, telcoin, balance);
        Redeem(_beneficiary, balance, amount);

        telcoin.transfer(_beneficiary, amount);

        return amount;
    }

    function transferOwnership(address _to) onlyOwner public {
        require(_to != address(0));
        OwnershipTransferred(owner, _to);
        owner = _to;
    }

    function balanceOf(address _owner) public constant returns (uint256) {
        return balances[_owner];
    }

    function redeemableBalance(address _beneficiary) public constant returns (uint256) {
        return vestedBalance(_beneficiary).sub(redeemed[_beneficiary]);
    }

    function vestedBalance(address _beneficiary) public constant returns (uint256) {
        uint256 currentBalance = balances[_beneficiary];
        uint256 totalBalance = currentBalance.add(redeemed[_beneficiary]);

        if (now < vestingStart) {
            return 0;
        }

        if (now >= vestingStart.add(vestingDuration)) {
            return totalBalance;
        }

        return totalBalance.mul(now.sub(vestingStart)).div(vestingDuration);
    }
}


contract TelcoinSale {
    using SafeMath for uint256;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event WalletChanged(address indexed previousWallet, address indexed newWallet);
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount,
        uint256 bonusAmount
    );
    event TokenAltPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount,
        uint256 bonusAmount,
        string symbol,
        string transactionId
    );
    event Pause();
    event Unpause();
    event Withdrawal(address indexed wallet, uint256 weiAmount);
    event Extended(uint256 until);
    event Finalized();
    event Refunding();
    event Refunded(address indexed beneficiary, uint256 weiAmount);
    event Whitelisted(
        address indexed participant,
        uint256 minWeiAmount,
        uint256 maxWeiAmount,
        uint32 bonusRate
    );
    event CapFlexed(uint32 flex);

     
    address public owner;

     
     
     
    TelcoinSaleToken public saleToken;
    TelcoinSaleToken public bonusToken;

     
    Telcoin public telcoin;

     
     
     
     
     
     
     
     
     
     
    uint256 public softCap;
    uint256 public hardCap;
    uint32 public capFlex;

     
    uint256 public startTime;
    uint256 public endTime;
    uint256 public timeExtension;

     
    uint256 public rate;

     
     
     
    uint256 public weiRaised;

     
     
    address public wallet;

     
     
     
     
    mapping(address => uint256) public whitelistedMin;
    mapping(address => uint256) public whitelistedMax;
    mapping(address => uint32) public bonusRates;

     
    mapping(address => uint256) public deposited;
    mapping(address => uint256) public altDeposited;

     
    address[] public investors;

     
    bool public paused = false;

     
    bool public finished = false;
    uint256 public finishedAt;

     
    bool public refunding = false;

     
    uint256 public weiRefunded;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier saleOpen() {
        require(!finished);
        require(!paused);
        require(now >= startTime);
        require(now <= endTime + timeExtension);
        _;
    }

    function TelcoinSale(
        uint256 _softCap,
        uint256 _hardCap,
        uint32 _capFlex,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        Telcoin _telcoin,
        uint256 _bonusVestingStart,
        uint256 _bonusVestingDuration
    )
        public
        payable
    {
        require(msg.value > 0);
        require(_softCap > 0);
        require(_hardCap >= _softCap);
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != 0x0);

        owner = msg.sender;
        softCap = _softCap;
        hardCap = _hardCap;
        capFlex = _capFlex;
        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        wallet = _wallet;
        telcoin = _telcoin;

        saleToken = new TelcoinSaleToken(telcoin, 0, 0);
        bonusToken = new TelcoinSaleToken(
            telcoin,
            _bonusVestingStart,
            _bonusVestingDuration
        );

        wallet.transfer(msg.value);
    }

    function () public payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address _beneficiary) saleOpen public payable {
        require(_beneficiary != address(0));

        uint256 weiAmount = msg.value;
        require(weiAmount > 0);
        require(weiRaised.add(weiAmount) <= hardCap);

        uint256 totalPrior = totalDeposited(_beneficiary);
        uint256 totalAfter = totalPrior.add(weiAmount);
        require(totalAfter <= whitelistedMax[_beneficiary]);

        uint256 saleTokens;
        uint256 bonusTokens;

        (saleTokens, bonusTokens) = tokensForPurchase(_beneficiary, weiAmount);

        uint256 newDeposited = deposited[_beneficiary].add(weiAmount);
        deposited[_beneficiary] = newDeposited;
        investors.push(_beneficiary);

        weiRaised = weiRaised.add(weiAmount);

        saleToken.mint(_beneficiary, saleTokens);
        if (bonusTokens > 0) {
            bonusToken.mint(_beneficiary, bonusTokens);
        }

        TokenPurchase(
            msg.sender,
            _beneficiary,
            weiAmount,
            saleTokens,
            bonusTokens
        );
    }

    function changeWallet(address _wallet) onlyOwner public payable {
        require(_wallet != 0x0);
        require(msg.value > 0);

        WalletChanged(wallet, _wallet);
        wallet = _wallet;

        wallet.transfer(msg.value);
    }

    function extendTime(uint256 _timeExtension) onlyOwner public {
        require(!finished);
        require(now < endTime + timeExtension);
        require(_timeExtension > 0);

        timeExtension = timeExtension.add(_timeExtension);
        require(timeExtension <= 7 days);

        Extended(endTime.add(timeExtension));
    }

    function finish() onlyOwner public {
        require(!finished);
        require(hardCapReached() || now > endTime + timeExtension);

        finished = true;
        finishedAt = now;
        saleToken.finishMinting();
        bonusToken.finishMinting();

        uint256 distributableCoins = telcoin.balanceOf(this);

        if (softCapReached()) {
            uint256 saleTokens = saleToken.totalSupply();
            uint256 bonusTokens = bonusToken.totalSupply();
            uint256 totalTokens = saleTokens.add(bonusTokens);

             
             
            uint256 bonusPortion = bonusTokens.mul(10 ** 18).div(totalTokens).mul(distributableCoins).div(10 ** 18);
            uint256 salePortion = distributableCoins.sub(bonusPortion);

            saleToken.transferOwnership(owner);
            bonusToken.transferOwnership(owner);

            telcoin.transfer(saleToken, salePortion);
            telcoin.transfer(bonusToken, bonusPortion);

            withdraw();
        } else {
            refunding = true;
            telcoin.transfer(wallet, distributableCoins);
            Refunding();
        }

        Finalized();
    }

    function pause() onlyOwner public {
        require(!paused);
        paused = true;
        Pause();
    }

    function refundMany(address[] _investors) public {
        for (uint256 i = 0; i < _investors.length; i++) {
            refund(_investors[i]);
        }
    }

    function refund(address _investor) public {
        require(finished);
        require(refunding);
        require(deposited[_investor] > 0);

        uint256 weiAmount = deposited[_investor];
        deposited[_investor] = 0;
        weiRefunded = weiRefunded.add(weiAmount);
        Refunded(_investor, weiAmount);

        _investor.transfer(weiAmount);
    }

    function registerAltPurchase(
        address _beneficiary,
        string _symbol,
        string _transactionId,
        uint256 _weiAmount
    )
        saleOpen
        onlyOwner
        public
    {
        require(_beneficiary != address(0));
        require(totalDeposited(_beneficiary).add(_weiAmount) <= whitelistedMax[_beneficiary]);

        uint256 saleTokens;
        uint256 bonusTokens;

        (saleTokens, bonusTokens) = tokensForPurchase(_beneficiary, _weiAmount);

        uint256 newAltDeposited = altDeposited[_beneficiary].add(_weiAmount);
        altDeposited[_beneficiary] = newAltDeposited;
        investors.push(_beneficiary);

        weiRaised = weiRaised.add(_weiAmount);

        saleToken.mint(_beneficiary, saleTokens);
        if (bonusTokens > 0) {
            bonusToken.mint(_beneficiary, bonusTokens);
        }

        TokenAltPurchase(
            msg.sender,
            _beneficiary,
            _weiAmount,
            saleTokens,
            bonusTokens,
            _symbol,
            _transactionId
        );
    }

    function transferOwnership(address _to) onlyOwner public {
        require(_to != address(0));
        OwnershipTransferred(owner, _to);
        owner = _to;
    }

    function unpause() onlyOwner public {
        require(paused);
        paused = false;
        Unpause();
    }

    function updateCapFlex(uint32 _capFlex) onlyOwner public {
        require(!finished);
        capFlex = _capFlex;
        CapFlexed(capFlex);
    }

    function whitelistMany(
        address[] _participants,
        uint256 _minWeiAmount,
        uint256 _maxWeiAmount,
        uint32 _bonusRate
    )
        onlyOwner
        public
    {
        for (uint256 i = 0; i < _participants.length; i++) {
            whitelist(
                _participants[i],
                _minWeiAmount,
                _maxWeiAmount,
                _bonusRate
            );
        }
    }

    function whitelist(
        address _participant,
        uint256 _minWeiAmount,
        uint256 _maxWeiAmount,
        uint32 _bonusRate
    )
        onlyOwner
        public
    {
        require(_participant != 0x0);
        require(_bonusRate <= 400);

        whitelistedMin[_participant] = _minWeiAmount;
        whitelistedMax[_participant] = _maxWeiAmount;
        bonusRates[_participant] = _bonusRate;
        Whitelisted(
            _participant,
            _minWeiAmount,
            _maxWeiAmount,
            _bonusRate
        );
    }

    function withdraw() onlyOwner public {
        require(softCapReached() || (finished && now > finishedAt + 14 days));

        uint256 weiAmount = this.balance;

        if (weiAmount > 0) {
            wallet.transfer(weiAmount);
            Withdrawal(wallet, weiAmount);
        }
    }

    function hardCapReached() public constant returns (bool) {
        return weiRaised >= hardCap.mul(1000 + capFlex).div(1000);
    }

    function tokensForPurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
        public
        constant
        returns (uint256, uint256)
    {
        uint256 baseTokens = _weiAmount.mul(rate);
        uint256 totalPrior = totalDeposited(_beneficiary);
        uint256 totalAfter = totalPrior.add(_weiAmount);

         
        if (totalAfter < whitelistedMin[_beneficiary]) {
            return (baseTokens, 0);
        }

        uint32 bonusRate = bonusRates[_beneficiary];
        uint256 baseBonus = baseTokens.mul(1000 + bonusRate).div(1000).sub(baseTokens);

         
        if (totalPrior < whitelistedMin[_beneficiary]) {
            uint256 balancePrior = totalPrior.mul(rate);
            uint256 accumulatedBonus = balancePrior.mul(1000 + bonusRate).div(1000).sub(balancePrior);
            return (baseTokens, accumulatedBonus.add(baseBonus));
        }

        return (baseTokens, baseBonus);
    }

    function totalDeposited(address _investor) public constant returns (uint256) {
        return deposited[_investor].add(altDeposited[_investor]);
    }

    function softCapReached() public constant returns (bool) {
        return weiRaised >= softCap.mul(1000 + capFlex).div(1000);
    }
}


contract TelcoinSaleKYCEscrow {
    using SafeMath for uint256;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ValuePlaced(address indexed purchaser, address indexed beneficiary, uint256 amount);
    event Approved(address indexed participant);
    event Rejected(address indexed participant);
    event Closed();

     
    address public owner;

     
    TelcoinSale public sale;

     
    bool public closed = false;

     
    mapping(address => uint256) public deposited;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier escrowOpen() {
        require(!closed);
        _;
    }

    function TelcoinSaleKYCEscrow(TelcoinSale _sale) public {
        require(_sale != address(0));

        owner = msg.sender;
        sale = _sale;
    }

    function () public payable {
        placeValue(msg.sender);
    }

    function approve(address _participant) onlyOwner public {
        uint256 weiAmount = deposited[_participant];
        require(weiAmount > 0);

        deposited[_participant] = 0;
        Approved(_participant);
        sale.buyTokens.value(weiAmount)(_participant);
    }

    function approveMany(address[] _participants) onlyOwner public {
        for (uint256 i = 0; i < _participants.length; i++) {
            approve(_participants[i]);
        }
    }

    function close() onlyOwner public {
        require(!closed);

        closed = true;
        Closed();
    }

    function placeValue(address _beneficiary) escrowOpen public payable {
        require(_beneficiary != address(0));

        uint256 weiAmount = msg.value;
        require(weiAmount > 0);

        uint256 newDeposited = deposited[_beneficiary].add(weiAmount);
        deposited[_beneficiary] = newDeposited;

        ValuePlaced(
            msg.sender,
            _beneficiary,
            weiAmount
        );
    }

    function reject(address _participant) onlyOwner public {
        uint256 weiAmount = deposited[_participant];
        require(weiAmount > 0);

        deposited[_participant] = 0;
        Rejected(_participant);
        require(_participant.call.value(weiAmount)());
    }

    function rejectMany(address[] _participants) onlyOwner public {
        for (uint256 i = 0; i < _participants.length; i++) {
            reject(_participants[i]);
        }
    }

    function transferOwnership(address _to) onlyOwner public {
        require(_to != address(0));
        OwnershipTransferred(owner, _to);
        owner = _to;
    }
}