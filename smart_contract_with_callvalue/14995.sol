pragma solidity ^0.4.23;

 

 
interface _ICompTreasury {
     
    function addCapital() external payable;
     
    function capitalNeeded() external view returns (uint);
}
contract Comptroller {
     
    address public wallet;               
    _ICompTreasury public treasury;      
    DividendToken public token;          
    DividendTokenLocker public locker;   

     
    uint public dateSaleStarted;     
    uint public dateSaleEnded;       
    uint public softCap;             
    uint public hardCap;             
    uint public bonusCap;            
    uint public capitalPctBips;      

     
    uint public totalRaised;
    bool public wasSaleStarted;              
    bool public wasSaleEnded;                
    bool public wasSoftCapMet;               
     
    mapping (address => uint) public amtFunded; 

    event Created(uint time, address wallet, address treasury, address token, address locker);
     
    event SaleInitalized(uint time);         
    event SaleStarted(uint time);            
    event SaleSuccessful(uint time);         
    event SaleFailed(uint time);             
     
    event BuyTokensSuccess(uint time, address indexed account, uint funded, uint numTokens);
    event BuyTokensFailure(uint time, address indexed account, string reason);
     
    event UserRefunded(uint time, address indexed account, uint refund);

    constructor(address _wallet, address _treasury)
        public
    {
        wallet = _wallet;
        treasury = _ICompTreasury(_treasury);
        token = new DividendToken("PennyEtherToken", "PENNY");
        locker = new DividendTokenLocker(token, _wallet);
        token.freeze(true);
        emit Created(now, wallet, treasury, token, locker);
    }


     
     
     

     
     
    function initSale(uint _dateStarted, uint _dateEnded, uint _softCap, uint _hardCap, uint _bonusCap, uint _capitalPctBips)
        public
    {
        require(msg.sender == wallet);
        require(!wasSaleStarted);
        require(_softCap <= _hardCap);
        require(_bonusCap <= _hardCap);
        require(_capitalPctBips <= 10000);
        dateSaleStarted = _dateStarted;
        dateSaleEnded = _dateEnded;
        softCap = _softCap;
        hardCap = _hardCap;
        bonusCap = _bonusCap;
        capitalPctBips = _capitalPctBips;
        emit SaleInitalized(now);
    }

    function () public payable {
        fund();
    }


    function fund() public payable {
        if (dateSaleStarted==0 || now < dateSaleStarted)
            return _errorBuyingTokens("CrowdSale has not yet started.");
        if (now > dateSaleEnded)
            return _errorBuyingTokens("CrowdSale has ended.");
        if (totalRaised >= hardCap)
            return _errorBuyingTokens("HardCap has been reached.");
        if (msg.value % 1000000000 != 0)
            return _errorBuyingTokens("Must send an even amount of GWei.");

         
        if (!wasSaleStarted) {
            wasSaleStarted = true;
            emit SaleStarted(now);
        }

         
        uint _amtToFund = (totalRaised + msg.value) > hardCap
            ? hardCap - totalRaised
            : msg.value;

         
        uint _numTokens = getTokensFromEth(_amtToFund);
        token.mint(msg.sender, _numTokens);
        totalRaised += _amtToFund;
        emit BuyTokensSuccess(now, msg.sender, _amtToFund, _numTokens);

         
        if (totalRaised < softCap) {
            amtFunded[msg.sender] += _amtToFund;
        }

        uint _refund = msg.value > _amtToFund ? msg.value - _amtToFund : 0;
        if (_refund > 0){
            require(msg.sender.call.value(_refund)());
            emit UserRefunded(now, msg.sender, _refund);
        }
    }

    function endSale() public {
         
        require(wasSaleStarted && !wasSaleEnded);
         
        require(totalRaised >= hardCap || now > dateSaleEnded);
        
         
        wasSaleEnded = true;
        wasSoftCapMet = totalRaised >= softCap;

         
        if (!wasSoftCapMet) {
            token.mint(wallet, 1e30);
            emit SaleFailed(now);
            return;
        }

         
        token.freeze(false);

         
        uint _lockerAmt = token.totalSupply() / 4;
        token.mint(locker, _lockerAmt);
        locker.startVesting(_lockerAmt, 600);    

         
        uint _capitalAmt = (totalRaised * capitalPctBips) / 10000;
        if (address(this).balance < _capitalAmt) _capitalAmt = address(this).balance;
        treasury.addCapital.value(_capitalAmt)();
        
         
        if (wallet.call.value(address(this).balance)()) {}
         
        emit SaleSuccessful(now);
    }

    function refund() public {
         
        require(wasSaleEnded && !wasSoftCapMet);
        require(amtFunded[msg.sender] > 0);
         
        uint _amt = amtFunded[msg.sender];
        amtFunded[msg.sender] = 0;
        require(msg.sender.call.value(_amt)());
        emit UserRefunded(now, msg.sender, _amt);
    }

    function fundCapital() public payable {
        if (!wasSaleEnded)
            return _errorBuyingTokens("Sale has not ended.");
        if (!wasSoftCapMet)
            return _errorBuyingTokens("SoftCap was not met.");
            
         
        uint _amtNeeded = capitalFundable();
        uint _amount = msg.value > _amtNeeded ? _amtNeeded : msg.value;
        if (_amount == 0) {
            return _errorBuyingTokens("No capital is needed.");
        }

         
        totalRaised += _amount;
        token.mint(msg.sender, _amount);
        treasury.addCapital.value(_amount)();
        emit BuyTokensSuccess(now, msg.sender, _amount, _amount);

         
        uint _refund = msg.value > _amount ? msg.value - _amount : 0;
        if (_refund > 0) {
            require(msg.sender.call.value(_refund)());
            emit UserRefunded(now, msg.sender, _refund);
        }
    }

    function _errorBuyingTokens(string _reason) private {
        require(msg.sender.call.value(msg.value)());
        emit BuyTokensFailure(now, msg.sender, _reason);
    }


    function capitalFundable()
        public
        view
        returns (uint _amt)
    {
        return treasury.capitalNeeded();
    }

     
     
     
     
    function getTokensMintedAt(uint _ethAmt)
        public
        view
        returns (uint _numTokens)
    {
        if (_ethAmt > hardCap) {
             
            _numTokens = (5*bonusCap/4) + (hardCap - bonusCap);
        } else if (_ethAmt > bonusCap) {
             
            _numTokens = (5*bonusCap/4) + (_ethAmt - bonusCap);
        } else {
             
             
             
             
             
             
             
             
             
             
             
            _numTokens = (3*_ethAmt/2) - (_ethAmt*_ethAmt)/(4*bonusCap);
        }
    }

     
     
    function getTokensFromEth(uint _amt)
        public
        view
        returns (uint _numTokens)
    {
        return getTokensMintedAt(totalRaised + _amt) - getTokensMintedAt(totalRaised);
    }
}


 
contract ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint public totalSupply;
    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Created(uint time);
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    event AllowanceUsed(address indexed owner, address indexed spender, uint amount);

    constructor(string _name, string _symbol)
        public
    {
        name = _name;
        symbol = _symbol;
        emit Created(now);
    }

    function transfer(address _to, uint _value)
        public
        returns (bool success)
    {
        return _transfer(msg.sender, _to, _value);
    }

    function approve(address _spender, uint _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
     
    function transferFrom(address _from, address _to, uint256 _value)
        public
        returns (bool success)
    {
        address _spender = msg.sender;
        require(allowance[_from][_spender] >= _value);
        allowance[_from][_spender] -= _value;
        emit AllowanceUsed(_from, _spender, _value);
        return _transfer(_from, _to, _value);
    }

     
     
    function _transfer(address _from, address _to, uint _value)
        private
        returns (bool success)
    {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}

interface HasTokenFallback {
    function tokenFallback(address _from, uint256 _amount, bytes _data)
        external
        returns (bool success);
}
contract ERC667 is ERC20 {
    constructor(string _name, string _symbol)
        public
        ERC20(_name, _symbol)
    {}

    function transferAndCall(address _to, uint _value, bytes _data)
        public
        returns (bool success)
    {
        require(super.transfer(_to, _value));
        require(HasTokenFallback(_to).tokenFallback(msg.sender, _value, _data));
        return true;
    }
}



 
contract DividendToken is ERC667
{
     
    bool public isFrozen;

     
    address public comptroller = msg.sender;
    modifier onlyComptroller(){ require(msg.sender==comptroller); _; }

     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
    uint constant POINTS_PER_WEI = 1e32;
    uint public dividendsTotal;
    uint public dividendsCollected;
    uint public totalPointsPerToken;
    uint public totalBurned;
    mapping (address => uint) public creditedPoints;
    mapping (address => uint) public lastPointsPerToken;

     
    event Frozen(uint time);
    event UnFrozen(uint time);
    event TokensMinted(uint time, address indexed account, uint amount, uint newTotalSupply);
    event TokensBurned(uint time, address indexed account, uint amount, uint newTotalSupply);
    event CollectedDividends(uint time, address indexed account, uint amount);
    event DividendReceived(uint time, address indexed sender, uint amount);

    constructor(string _name, string _symbol)
        public
        ERC667(_name, _symbol)
    {}

     
    function ()
        payable
        public
    {
        if (msg.value == 0) return;
         
         
        totalPointsPerToken += (msg.value * POINTS_PER_WEI) / totalSupply;
        dividendsTotal += msg.value;
        emit DividendReceived(now, msg.sender, msg.value);
    }

     
     
     
     
    function mint(address _to, uint _amount)
        onlyComptroller
        public
    {
        _updateCreditedPoints(_to);
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit TokensMinted(now, _to, _amount, totalSupply);
    }
    
     
    function burn(address _account, uint _amount)
        onlyComptroller
        public
    {
        require(balanceOf[_account] >= _amount);
        _updateCreditedPoints(_account);
        balanceOf[_account] -= _amount;
        totalSupply -= _amount;
        totalBurned += _amount;
        emit TokensBurned(now, _account, _amount, totalSupply);
    }

     
    function freeze(bool _isFrozen)
        onlyComptroller
        public
    {
        if (isFrozen == _isFrozen) return;
        isFrozen = _isFrozen;
        if (_isFrozen) emit Frozen(now);
        else emit UnFrozen(now);
    }

     
     
     
    
     
     
    function transfer(address _to, uint _value)
        public
        returns (bool success)
    {   
         
        require(!isFrozen);
        _updateCreditedPoints(msg.sender);
        _updateCreditedPoints(_to);
        return ERC20.transfer(_to, _value);
    }

     
     
    function transferFrom(address _from, address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(!isFrozen);
        _updateCreditedPoints(_from);
        _updateCreditedPoints(_to);
        return ERC20.transferFrom(_from, _to, _value);
    }
    
     
     
    function transferAndCall(address _to, uint _value, bytes _data)
        public
        returns (bool success)
    {
        require(!isFrozen);
        _updateCreditedPoints(msg.sender);
        _updateCreditedPoints(_to);
        return ERC667.transferAndCall(_to, _value, _data);  
    }

     
    function collectOwedDividends() public returns (uint _amount) {
         
        _updateCreditedPoints(msg.sender);
        _amount = creditedPoints[msg.sender] / POINTS_PER_WEI;
        creditedPoints[msg.sender] = 0;
        dividendsCollected += _amount;
        emit CollectedDividends(now, msg.sender, _amount);
        require(msg.sender.call.value(_amount)());
    }


     
     
     
     
     
     
    function _updateCreditedPoints(address _account)
        private
    {
        creditedPoints[_account] += _getUncreditedPoints(_account);
        lastPointsPerToken[_account] = totalPointsPerToken;
    }

     
    function _getUncreditedPoints(address _account)
        private
        view
        returns (uint _amount)
    {
        uint _pointsPerToken = totalPointsPerToken - lastPointsPerToken[_account];
         
         
         
         
        return _pointsPerToken * balanceOf[_account];
    }


     
     
     
     
    function getOwedDividends(address _account)
        public
        constant
        returns (uint _amount)
    {
        return (_getUncreditedPoints(_account) + creditedPoints[_account])/POINTS_PER_WEI;
    }
}




 
contract IDividendToken {
    function collectOwedDividends() external returns (uint);
    function transfer(address _to, uint _value) external;
    function balanceOf(address _addr) external view returns (uint);
}
contract DividendTokenLocker {
     
    address public comptroller;
    address public owner;
    IDividendToken public token;
     
    uint public vestingAmt;
    uint public vestingStartDay;
    uint public vestingDays;

     
    event Created(uint time, address comptroller, address token, address owner);
    event VestingStarted(uint time, uint numTokens, uint vestingDays);
    event Transferred(uint time, address recipient, uint numTokens);
    event Collected(uint time, address recipient, uint amount);
    
     
    constructor(address _token, address _owner)
        public
    {
        comptroller = msg.sender;
        token = IDividendToken(_token);
        owner = _owner;
        emit Created(now, comptroller, token, owner);
    }

     
    function () payable public {}


     
     
     

     
     
     
    function startVesting(uint _numTokens, uint _vestingDays)
        public
    {
        require(msg.sender == comptroller);
        vestingAmt = _numTokens;
        vestingStartDay = _today();
        vestingDays = _vestingDays;
        emit VestingStarted(now, _numTokens, _vestingDays);
    }


     
     
     

     
     
    function collect() public {
        require(msg.sender == owner);
         
        token.collectOwedDividends();
        uint _amount = address(this).balance;

         
        if (_amount > 0) require(owner.call.value(_amount)());
        emit Collected(now, owner, _amount);
    }

     
     
    function transfer(address _to, uint _numTokens)
        public
    {
        require(msg.sender == owner);
        uint _available = tokensAvailable();
        if (_numTokens > _available) _numTokens = _available;

         
        if (_numTokens > 0) {
            token.transfer(_to, _numTokens);
        }
        emit Transferred(now, _to, _numTokens);
    }


     
     
     

    function tokens()
        public
        view
        returns (uint)
    {
        return token.balanceOf(this);
    }

     
     
    function tokensUnvested()
        public
        view
        returns (uint)
    {
        return vestingAmt - tokensVested();
    }

     
     
    function tokensVested()
        public
        view
        returns (uint)
    {
        uint _daysElapsed = _today() - vestingStartDay;
        return _daysElapsed >= vestingDays
            ? vestingAmt
            : (vestingAmt * _daysElapsed) / vestingDays;
    }

     
     
    function tokensAvailable()
        public
        view
        returns (uint)
    {
         
         
        int _available = int(tokens()) - int(tokensUnvested());
        return _available > 0 ? uint(_available) : 0;
    }

     
    function _today()
        private 
        view 
        returns (uint)
    {
        return now / 1 days;
    }
}