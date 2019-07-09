pragma solidity ^0.4.11;

 
contract Utils {
     
    function Utils() {
    }

     
    modifier greaterThanZero(uint256 _amount) {
        require(_amount > 0);
        _;
    }

     
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

     
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

     

     
    function safeAdd(uint256 _x, uint256 _y) internal returns (uint256) {
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

     
    function safeSub(uint256 _x, uint256 _y) internal returns (uint256) {
        assert(_x >= _y);
        return _x - _y;
    }

     
    function safeMul(uint256 _x, uint256 _y) internal returns (uint256) {
        uint256 z = _x * _y;
        assert(_x == 0 || z / _x == _y);
        return z;
    }
}

 
contract IERC20Token {
     
    function name() public constant returns (string) {}
    function symbol() public constant returns (string) {}
    function decimals() public constant returns (uint8) {}
    function totalSupply() public constant returns (uint256) {}
    function balanceOf(address _owner) public constant returns (uint256) { _owner; }
    function allowance(address _owner, address _spender) public constant returns (uint256) { _owner; _spender; }

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

 
contract IOwned {
     
    function owner() public constant returns (address) {}

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}

 
contract ITokenHolder is IOwned {
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}

 
contract ITokenConverter {
    function convertibleTokenCount() public constant returns (uint16);
    function convertibleToken(uint16 _tokenIndex) public constant returns (address);
    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public constant returns (uint256);
    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
     
    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
}

 
contract IStandardToken is IOwned, IERC20Token {
    function disableTransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}

 
contract IStandardConverterExtensions {
    function formula() public constant returns (IStandardFormula) {}
    function gasPriceLimit() public constant returns (IStandardGasPriceLimit) {}
    function quickConverter() public constant returns (IStandardQuickConverter) {}
}

 
contract IStandardFormula {
    function calculatePurchaseReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _depositAmount) public constant returns (uint256);
    function calculateSaleReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _sellAmount) public constant returns (uint256);
}

 
contract IStandardGasPriceLimit {
    function gasPrice() public constant returns (uint256) {}
}

 
contract IStandardQuickConverter {
    function convert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);
    function convertFor(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for) public payable returns (uint256);
}

 
contract IEtherToken is ITokenHolder, IERC20Token {
    function deposit() public payable;
    function withdraw(uint256 _amount) public;
    function withdrawTo(address _to, uint256 _amount);
}

 
contract Owned is IOwned {
    address public owner;
    address public newOwner;

    event OwnerUpdate(address _prevOwner, address _newOwner);

     
    function Owned() {
        owner = msg.sender;
    }

     
    modifier ownerOnly {
        assert(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

     
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}

 
contract Managed {
    address public manager;
    address public newManager;

    event ManagerUpdate(address _prevManager, address _newManager);

     
    function Managed() {
        manager = msg.sender;
    }

     
    modifier managerOnly {
        assert(msg.sender == manager);
        _;
    }

     
    function transferManagement(address _newManager) public managerOnly {
        require(_newManager != manager);
        newManager = _newManager;
    }

     
    function acceptManagement() public {
        require(msg.sender == newManager);
        ManagerUpdate(manager, newManager);
        manager = newManager;
        newManager = 0x0;
    }
}

 
contract TokenHolder is ITokenHolder, Owned, Utils {
     
    function TokenHolder() {
    }

     
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {
        assert(_token.transfer(_to, _amount));
    }
}

 
contract StandardTokenController is TokenHolder {
    IStandardToken public token;    

     
    function StandardTokenController(IStandardToken _token)
        validAddress(_token)
    {
        token = _token;
    }

     
    modifier active() {
        assert(token.owner() == address(this));
        _;
    }

     
    modifier inactive() {
        assert(token.owner() != address(this));
        _;
    }

     
    function transferTokenOwnership(address _newOwner) public ownerOnly {
        token.transferOwnership(_newOwner);
    }

     
    function acceptTokenOwnership() public ownerOnly {
        token.acceptOwnership();
    }

     
    function disableTokenTransfers(bool _disable) public ownerOnly {
        token.disableTransfers(_disable);
    }

     
    function withdrawFromToken(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {
        ITokenHolder(token).withdrawTokens(_token, _to, _amount);
    }
}

 
contract StandardConverter is ITokenConverter, StandardTokenController, Managed {
    uint32 private constant MAX_CRR = 1000000;
    uint32 private constant MAX_CONVERSION_FEE = 1000000;

    struct Reserve {
        uint256 virtualBalance;          
        uint32 ratio;                    
        bool isVirtualBalanceEnabled;    
        bool isPurchaseEnabled;          
        bool isSet;                      
    }

    string public version = '0.4';
    string public converterType = 'standard';

    IStandardConverterExtensions public extensions;    
    IERC20Token[] public reserveTokens;              
    IERC20Token[] public quickBuyPath;               
    mapping (address => Reserve) public reserves;    
    uint32 private totalReserveRatio = 0;            
    uint32 public maxConversionFee = 0;              
    uint32 public conversionFee = 0;                 
    bool public conversionsEnabled = true;           

     
    event Conversion(address indexed _fromToken, address indexed _toToken, address indexed _trader, uint256 _amount, uint256 _return,
                     uint256 _currentPriceN, uint256 _currentPriceD);

     
    function StandardConverter(IStandardToken _token, IStandardConverterExtensions _extensions, uint32 _maxConversionFee, IERC20Token _reserveToken, uint32 _reserveRatio)
        StandardTokenController(_token)
        validAddress(_extensions)
        validMaxConversionFee(_maxConversionFee)
    {
        extensions = _extensions;
        maxConversionFee = _maxConversionFee;

        if (address(_reserveToken) != 0x0)
            addReserve(_reserveToken, _reserveRatio, false);
    }

     
    modifier validReserve(IERC20Token _address) {
        require(reserves[_address].isSet);
        _;
    }

     
    modifier validToken(IERC20Token _address) {
        require(_address == token || reserves[_address].isSet);
        _;
    }

     
    modifier validGasPrice() {
        assert(tx.gasprice <= extensions.gasPriceLimit().gasPrice());
        _;
    }

     
    modifier validMaxConversionFee(uint32 _conversionFee) {
        require(_conversionFee >= 0 && _conversionFee <= MAX_CONVERSION_FEE);
        _;
    }

     
    modifier validConversionFee(uint32 _conversionFee) {
        require(_conversionFee >= 0 && _conversionFee <= maxConversionFee);
        _;
    }

     
    modifier validReserveRatio(uint32 _ratio) {
        require(_ratio > 0 && _ratio <= MAX_CRR);
        _;
    }

     
    modifier validConversionPath(IERC20Token[] _path) {
        require(_path.length > 2 && _path.length <= (1 + 2 * 10) && _path.length % 2 == 1);
        _;
    }

     
    modifier conversionsAllowed {
        assert(conversionsEnabled);
        _;
    }

     
    function reserveTokenCount() public constant returns (uint16) {
        return uint16(reserveTokens.length);
    }

     
    function convertibleTokenCount() public constant returns (uint16) {
        return reserveTokenCount() + 1;
    }

     
    function convertibleToken(uint16 _tokenIndex) public constant returns (address) {
        if (_tokenIndex == 0)
            return token;
        return reserveTokens[_tokenIndex - 1];
    }

     
    function setExtensions(IStandardConverterExtensions _extensions)
        public
        ownerOnly
        validAddress(_extensions)
        notThis(_extensions)
    {
        extensions = _extensions;
    }

     
    function setQuickBuyPath(IERC20Token[] _path)
        public
        ownerOnly
        validConversionPath(_path)
    {
        quickBuyPath = _path;
    }

     
    function clearQuickBuyPath() public ownerOnly {
        quickBuyPath.length = 0;
    }

     
    function getQuickBuyPathLength() public constant returns (uint256) {
        return quickBuyPath.length;
    }

     
    function disableConversions(bool _disable) public managerOnly {
        conversionsEnabled = !_disable;
    }

     
    function setConversionFee(uint32 _conversionFee)
        public
        managerOnly
        validConversionFee(_conversionFee)
    {
        conversionFee = _conversionFee;
    }

     
    function getConversionFeeAmount(uint256 _amount) public constant returns (uint256) {
        return safeMul(_amount, conversionFee) / MAX_CONVERSION_FEE;
    }

     
    function addReserve(IERC20Token _token, uint32 _ratio, bool _enableVirtualBalance)
        public
        ownerOnly
        inactive
        validAddress(_token)
        notThis(_token)
        validReserveRatio(_ratio)
    {
        require(_token != token && !reserves[_token].isSet && totalReserveRatio + _ratio <= MAX_CRR);  

        reserves[_token].virtualBalance = 0;
        reserves[_token].ratio = _ratio;
        reserves[_token].isVirtualBalanceEnabled = _enableVirtualBalance;
        reserves[_token].isPurchaseEnabled = true;
        reserves[_token].isSet = true;
        reserveTokens.push(_token);
        totalReserveRatio += _ratio;
    }

     
    function updateReserve(IERC20Token _reserveToken, uint32 _ratio, bool _enableVirtualBalance, uint256 _virtualBalance)
        public
        ownerOnly
        validReserve(_reserveToken)
        validReserveRatio(_ratio)
    {
        Reserve storage reserve = reserves[_reserveToken];
        require(totalReserveRatio - reserve.ratio + _ratio <= MAX_CRR);  

        totalReserveRatio = totalReserveRatio - reserve.ratio + _ratio;
        reserve.ratio = _ratio;
        reserve.isVirtualBalanceEnabled = _enableVirtualBalance;
        reserve.virtualBalance = _virtualBalance;
    }

     
    function disableReservePurchases(IERC20Token _reserveToken, bool _disable)
        public
        ownerOnly
        validReserve(_reserveToken)
    {
        reserves[_reserveToken].isPurchaseEnabled = !_disable;
    }

     
    function getReserveBalance(IERC20Token _reserveToken)
        public
        constant
        validReserve(_reserveToken)
        returns (uint256)
    {
        Reserve storage reserve = reserves[_reserveToken];
        return reserve.isVirtualBalanceEnabled ? reserve.virtualBalance : _reserveToken.balanceOf(this);
    }

     
    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public constant returns (uint256) {
        require(_fromToken != _toToken);  

         
        if (_toToken == token)
            return getPurchaseReturn(_fromToken, _amount);
        else if (_fromToken == token)
            return getSaleReturn(_toToken, _amount);

         
        uint256 purchaseReturnAmount = getPurchaseReturn(_fromToken, _amount);
        return getSaleReturn(_toToken, purchaseReturnAmount, safeAdd(token.totalSupply(), purchaseReturnAmount));
    }

     
    function getPurchaseReturn(IERC20Token _reserveToken, uint256 _depositAmount)
        public
        constant
        active
        validReserve(_reserveToken)
        returns (uint256)
    {
        Reserve storage reserve = reserves[_reserveToken];
        require(reserve.isPurchaseEnabled);  

        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance = getReserveBalance(_reserveToken);
        uint256 amount = extensions.formula().calculatePurchaseReturn(tokenSupply, reserveBalance, reserve.ratio, _depositAmount);

         
        uint256 feeAmount = getConversionFeeAmount(amount);
        return safeSub(amount, feeAmount);
    }

     
    function getSaleReturn(IERC20Token _reserveToken, uint256 _sellAmount) public constant returns (uint256) {
        return getSaleReturn(_reserveToken, _sellAmount, token.totalSupply());
    }

     
    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256) {
        require(_fromToken != _toToken);  

         
        if (_toToken == token)
            return buy(_fromToken, _amount, _minReturn);
        else if (_fromToken == token)
            return sell(_toToken, _amount, _minReturn);

         
        uint256 purchaseAmount = buy(_fromToken, _amount, 1);
        return sell(_toToken, purchaseAmount, _minReturn);
    }

     
    function buy(IERC20Token _reserveToken, uint256 _depositAmount, uint256 _minReturn)
        public
        conversionsAllowed
        validGasPrice
        greaterThanZero(_minReturn)
        returns (uint256)
    {
        uint256 amount = getPurchaseReturn(_reserveToken, _depositAmount);
        assert(amount != 0 && amount >= _minReturn);  

         
        Reserve storage reserve = reserves[_reserveToken];
        if (reserve.isVirtualBalanceEnabled)
            reserve.virtualBalance = safeAdd(reserve.virtualBalance, _depositAmount);

         
        assert(_reserveToken.transferFrom(msg.sender, this, _depositAmount));
         
        token.issue(msg.sender, amount);

         
         
         
        uint256 reserveAmount = safeMul(getReserveBalance(_reserveToken), MAX_CRR);
        uint256 tokenAmount = safeMul(token.totalSupply(), reserve.ratio);
        Conversion(_reserveToken, token, msg.sender, _depositAmount, amount, reserveAmount, tokenAmount);
        return amount;
    }

     
    function sell(IERC20Token _reserveToken, uint256 _sellAmount, uint256 _minReturn)
        public
        conversionsAllowed
        validGasPrice
        greaterThanZero(_minReturn)
        returns (uint256)
    {
        require(_sellAmount <= token.balanceOf(msg.sender));  

        uint256 amount = getSaleReturn(_reserveToken, _sellAmount);
        assert(amount != 0 && amount >= _minReturn);  

        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance = getReserveBalance(_reserveToken);
         
        assert(amount < reserveBalance || (amount == reserveBalance && _sellAmount == tokenSupply));

         
        Reserve storage reserve = reserves[_reserveToken];
        if (reserve.isVirtualBalanceEnabled)
            reserve.virtualBalance = safeSub(reserve.virtualBalance, amount);

         
        token.destroy(msg.sender, _sellAmount);
         
         
        assert(_reserveToken.transfer(msg.sender, amount));

         
         
         
        uint256 reserveAmount = safeMul(getReserveBalance(_reserveToken), MAX_CRR);
        uint256 tokenAmount = safeMul(token.totalSupply(), reserve.ratio);
        Conversion(token, _reserveToken, msg.sender, _sellAmount, amount, tokenAmount, reserveAmount);
        return amount;
    }

     
    function quickConvert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn)
        public
        payable
        validConversionPath(_path)
        returns (uint256)
    {
        IERC20Token fromToken = _path[0];
        IStandardQuickConverter quickConverter = extensions.quickConverter();

         
         
        if (msg.value == 0) {
             
             
            if (fromToken == token) {
                token.destroy(msg.sender, _amount);  
                token.issue(quickConverter, _amount);  
            }
            else {
                 
                assert(fromToken.transferFrom(msg.sender, quickConverter, _amount));
            }
        }

         
        return quickConverter.convertFor.value(msg.value)(_path, _amount, _minReturn, msg.sender);
    }

     
    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256) {
        return convert(_fromToken, _toToken, _amount, _minReturn);
    }

     
    function quickChange(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public returns (uint256) {
        return quickConvert(_path, _amount, _minReturn);
    }

     
    function quickBuy(uint256 _minReturn) public payable returns (uint256) {
        return quickConvert(quickBuyPath, msg.value, _minReturn);
    }

     
    function hasQuickBuyEtherToken() public constant returns (bool) {
        return quickBuyPath.length > 0;
    }

     
    function getQuickBuyEtherToken() public constant returns (IEtherToken) {
        assert(quickBuyPath.length > 0);
        return IEtherToken(quickBuyPath[0]);
    }

     
    function getSaleReturn(IERC20Token _reserveToken, uint256 _sellAmount, uint256 _totalSupply)
        private
        constant
        active
        validReserve(_reserveToken)
        greaterThanZero(_totalSupply)
        returns (uint256)
    {
        Reserve storage reserve = reserves[_reserveToken];
        uint256 reserveBalance = getReserveBalance(_reserveToken);
        uint256 amount = extensions.formula().calculateSaleReturn(_totalSupply, reserveBalance, reserve.ratio, _sellAmount);

         
        uint256 feeAmount = getConversionFeeAmount(amount);
        return safeSub(amount, feeAmount);
    }

     
    function() payable {
        quickConvert(quickBuyPath, msg.value, 1);
    }
}