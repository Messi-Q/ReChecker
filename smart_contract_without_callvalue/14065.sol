pragma solidity 0.4.20;

 

 
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


contract ProductionUnitToken {

     

     
    modifier onlyBagholders {
        require(myTokens() > 0);
        _;
    }

     
    modifier onlyStronghands {
        require(myDividends(true) > 0);
        _;
    }


     

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy,
        uint timestamp,
        uint256 price
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned,
        uint timestamp,
        uint256 price
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );

     
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );


     

     
    MoonInc public moonIncContract;


     

    string public name = "Production Unit | Moon, Inc.";
    string public symbol = "ProductionUnit";
    uint8 constant public decimals = 18;

     
    uint8 public entryFee_;

     
    uint8 public transferFee_;

     
    uint8 public exitFee_;

     
    uint8 constant internal refferalFee_ = 20;

    uint256 public tokenPriceInitial_;  
    uint256 public tokenPriceIncremental_;  
    uint256 constant internal magnitude = 2 ** 64;

     
    uint256 public stakingRequirement = 10e18;

     
    uint256 public cookieProductionMultiplier;

     
    uint256 public startTime;

     
    mapping(address => uint) public ambassadorsMaxPremine;
    mapping(address => bool) public ambassadorsPremined;
    mapping(address => address) public ambassadorsPrerequisite;


    

     
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    uint256 internal tokenSupply_;


     

     
    function ProductionUnitToken(
        address _moonIncContractAddress, uint8 _entryFee, uint8 _transferFee, uint8 _exitFee,
        uint _tokenPriceInitial, uint _tokenPriceIncremental, uint _cookieProductionMultiplier, uint _startTime
    ) public {
        moonIncContract = MoonInc(_moonIncContractAddress);
        entryFee_ = _entryFee;
        transferFee_ = _transferFee;
        exitFee_ = _exitFee;
        tokenPriceInitial_ = _tokenPriceInitial;
        tokenPriceIncremental_ = _tokenPriceIncremental;
        cookieProductionMultiplier = _cookieProductionMultiplier;
        startTime = _startTime;

         
        uint BETA_DIVISOR = 1000;  

         
        ambassadorsMaxPremine[0xFEA0904ACc8Df0F3288b6583f60B86c36Ea52AcD] = 0.28 ether / BETA_DIVISOR;
        ambassadorsPremined[address(0)] = true;  

         
        ambassadorsMaxPremine[0xc951D3463EbBa4e9Ec8dDfe1f42bc5895C46eC8f] = 0.28 ether / BETA_DIVISOR;
        ambassadorsPrerequisite[0xc951D3463EbBa4e9Ec8dDfe1f42bc5895C46eC8f] = 0xFEA0904ACc8Df0F3288b6583f60B86c36Ea52AcD;

         
        ambassadorsMaxPremine[0x183feBd8828a9ac6c70C0e27FbF441b93004fC05] = 0.28 ether / BETA_DIVISOR;
        ambassadorsPrerequisite[0x183feBd8828a9ac6c70C0e27FbF441b93004fC05] = 0xc951D3463EbBa4e9Ec8dDfe1f42bc5895C46eC8f;

         
        ambassadorsMaxPremine[0x1fbc2Ca750E003A56d706C595b49a0A430EBA92d] = 0.09 ether / BETA_DIVISOR;
        ambassadorsPrerequisite[0x1fbc2Ca750E003A56d706C595b49a0A430EBA92d] = 0x183feBd8828a9ac6c70C0e27FbF441b93004fC05;

         
        ambassadorsMaxPremine[0x41F29054E7c0BC59a8AF10f3a6e7C0E53B334e05] = 0.09 ether / BETA_DIVISOR;
        ambassadorsPrerequisite[0x41F29054E7c0BC59a8AF10f3a6e7C0E53B334e05] = 0x1fbc2Ca750E003A56d706C595b49a0A430EBA92d;

         
        ambassadorsMaxPremine[0x15Fda64fCdbcA27a60Aa8c6ca882Aa3e1DE4Ea41] = 0.09 ether / BETA_DIVISOR;
        ambassadorsPrerequisite[0x15Fda64fCdbcA27a60Aa8c6ca882Aa3e1DE4Ea41] = 0x41F29054E7c0BC59a8AF10f3a6e7C0E53B334e05;

         
        ambassadorsMaxPremine[0x0a3239799518E7F7F339867A4739282014b97Dcf] = 0.09 ether / BETA_DIVISOR;
        ambassadorsPrerequisite[0x0a3239799518E7F7F339867A4739282014b97Dcf] = 0x15Fda64fCdbcA27a60Aa8c6ca882Aa3e1DE4Ea41;

         
        ambassadorsMaxPremine[0x31529d5Ab0D299D9b0594B7f2ef3515Be668AA87] = 0.09 ether / BETA_DIVISOR;
        ambassadorsPrerequisite[0x31529d5Ab0D299D9b0594B7f2ef3515Be668AA87] = 0x0a3239799518E7F7F339867A4739282014b97Dcf;
    }

     
    function buy(address _referredBy) public payable returns (uint256) {
        purchaseTokens(msg.value, _referredBy);
    }

     
    function() payable public {
        purchaseTokens(msg.value, 0x0);
    }

     
    function reinvest() onlyStronghands public {
         
        uint256 _dividends = myDividends(false);  

         
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

         
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

         
        uint256 _tokens = purchaseTokens(_dividends, 0x0);

         
        onReinvestment(_customerAddress, _dividends, _tokens);
    }

     
    function exit() public {
         
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if (_tokens > 0) sell(_tokens);

         
        withdraw();
    }

     
    function withdraw() onlyStronghands public {
         
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false);  

         
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);

         
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

         
        _customerAddress.transfer(_dividends);

         
        onWithdraw(_customerAddress, _dividends);
    }

     
    function sell(uint256 _amountOfTokens) onlyBagholders public {
        require(now >= startTime);

         
        address _customerAddress = msg.sender;
         
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

         
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);

         
        int256 _updatedPayouts = (int256) (_taxedEthereum * magnitude);
        payoutsTo_[_customerAddress] -= _updatedPayouts;

         
        moonIncContract.handleProductionDecrease.value(_dividends)(_customerAddress, _tokens * cookieProductionMultiplier);

         
        onTokenSell(_customerAddress, _tokens, _taxedEthereum, now, buyPrice());
    }

     
    function transfer(address _toAddress, uint256 _amountOfTokens) onlyBagholders public returns (bool) {
         
        address _customerAddress = msg.sender;

         
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

         
        if (myDividends(true) > 0) {
            withdraw();
        }

         
         
        uint256 _tokenFee = SafeMath.div(SafeMath.mul(_amountOfTokens, transferFee_), 100);
        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
        uint256 _dividends = tokensToEthereum_(_tokenFee);

         
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

         
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);

         
        moonIncContract.handleProductionDecrease.value(_dividends)(_customerAddress, _amountOfTokens * cookieProductionMultiplier);
        moonIncContract.handleProductionIncrease(_toAddress, _taxedTokens * cookieProductionMultiplier);

         
        Transfer(_customerAddress, _toAddress, _taxedTokens);

         
        return true;
    }


     

    function getSettings() public view returns (uint8, uint8, uint8, uint256, uint256, uint256, uint256) {
        return (entryFee_, transferFee_, exitFee_, tokenPriceInitial_,
            tokenPriceIncremental_, cookieProductionMultiplier, startTime);
    }

     
    function totalEthereumBalance() public view returns (uint256) {
        return this.balance;
    }

     
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

     
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

     
    function myDividends(bool _includeReferralBonus) public view returns (uint256) {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }

     
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

     
    function dividendsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (-payoutsTo_[_customerAddress])) / magnitude;
    }

     
    function sellPrice() public view returns (uint256) {
         
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee_), 100);
            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

            return _taxedEthereum;
        }
    }

     
    function buyPrice() public view returns (uint256) {
         
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, entryFee_), 100);
            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);

            return _taxedEthereum;
        }
    }

     
    function calculateTokensReceived(uint256 _ethereumToSpend) public view returns (uint256) {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, entryFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);

        return _amountOfTokens;
    }

     
    function calculateEthereumReceived(uint256 _tokensToSell) public view returns (uint256) {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }


     

     
    function purchaseTokens(uint256 _incomingEthereum, address _referredBy) internal returns (uint256) {
         
        require(_incomingEthereum <= 1 finney);

        require(
             
            now >= startTime ||
             
            (now >= startTime - 1 hours && !ambassadorsPremined[msg.sender] && ambassadorsPremined[ambassadorsPrerequisite[msg.sender]] && _incomingEthereum <= ambassadorsMaxPremine[msg.sender]) ||
             
            (now >= startTime - 10 minutes && !ambassadorsPremined[msg.sender] && _incomingEthereum <= ambassadorsMaxPremine[msg.sender])
        );

        if (now < startTime) {
            ambassadorsPremined[msg.sender] = true;
        }

         
        address _customerAddress = msg.sender;
        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, entryFee_), 100);
        uint256 _referralBonus = SafeMath.div(SafeMath.mul(_undividedDividends, refferalFee_), 100);
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);

         
         
         
         
        require(_amountOfTokens > 0 && SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_);

         
        if (
             
            _referredBy != 0x0000000000000000000000000000000000000000 &&

             
            _referredBy != _customerAddress &&

             
             
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ) {
             
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
        } else {
             
             
            _dividends = SafeMath.add(_dividends, _referralBonus);
        }

         
        tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

         
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

         
        moonIncContract.handleProductionIncrease.value(_dividends)(_customerAddress, _amountOfTokens * cookieProductionMultiplier);

         
        onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy, now, buyPrice());

        return _amountOfTokens;
    }

     
    function ethereumToTokens_(uint256 _ethereum) internal view returns (uint256) {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived =
         (
            (
                 
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial ** 2)
                            +
                            (2 * (tokenPriceIncremental_ * 1e18) * (_ethereum * 1e18))
                            +
                            ((tokenPriceIncremental_ ** 2) * (tokenSupply_ ** 2))
                            +
                            (2 * tokenPriceIncremental_ * _tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            ) / (tokenPriceIncremental_)
        ) - (tokenSupply_);

        return _tokensReceived;
    }

     
    function tokensToEthereum_(uint256 _tokens) internal view returns (uint256) {
        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);
        uint256 _etherReceived =
        (
             
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ + (tokenPriceIncremental_ * (_tokenSupply / 1e18))
                        ) - tokenPriceIncremental_
                    ) * (tokens_ - 1e18)
                ), (tokenPriceIncremental_ * ((tokens_ ** 2 - tokens_) / 1e18)) / 2
            )
        / 1e18);

        return _etherReceived;
    }

     
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;

        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }


}


contract MoonInc {

    string public constant name  = "Cookie | Moon, Inc.";
    string public constant symbol = "Cookie";
    uint8 public constant decimals = 18;

     
    uint256 public totalEtherCookieResearchPool;  
    uint256 public totalCookieProduction;
    uint256 private roughSupply;
    uint256 private lastTotalCookieSaveTime;  

     
    mapping(address => uint256) public cookieProduction;
    mapping(address => uint256) public cookieBalance;
    mapping(address => uint256) private lastCookieSaveTime;  

     
    mapping(address => mapping(address => uint256)) internal allowed;

     
    ProductionUnitToken[] public productionUnitTokenContracts;
    mapping(address => bool) productionUnitTokenContractAddresses;

     
    uint256[] public tokenContractStartTime;

    uint256 public constant firstUnitStartTime = 1526763600;  
    
     
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

     
    function MoonInc() public payable {
         
        createProductionUnit1Beta();

         
         

         
         
    }

    function() public payable {
         
        totalEtherCookieResearchPool += msg.value;
    }

     

    function createProductionUnit1Beta() public {
        require(productionUnitTokenContracts.length == 0);

        createProductionUnitTokenContract(10, 10, 10, 0.0000001 ether / 1000, 0.00000001 ether / 1000, 1, firstUnitStartTime);
    }

    function createProductionUnit2Beta() public {
        require(productionUnitTokenContracts.length == 1);

        createProductionUnitTokenContract(15, 15, 15, 0.0000001 ether / 1000, 0.00000001 ether / 1000, 3, firstUnitStartTime + 1 days);
    }

    function createProductionUnit3Beta() public {
        require(productionUnitTokenContracts.length == 2);

        createProductionUnitTokenContract(20, 20, 20, 0.0000001 ether / 1000, 0.00000001 ether / 1000, 9, firstUnitStartTime + 2 days);
    }

    function createProductionUnitTokenContract(
        uint8 _entryFee, uint8 _transferFee, uint8 _exitFee, uint256 _tokenPriceInitial, 
        uint256 _tokenPriceIncremental, uint256 _cookieProductionMultiplier, uint256 _startTime
    ) internal {
        ProductionUnitToken newContract = new ProductionUnitToken(address(this),
            _entryFee, _transferFee, _exitFee, _tokenPriceInitial, _tokenPriceIncremental, _cookieProductionMultiplier, _startTime);
        productionUnitTokenContracts.push(newContract);
        productionUnitTokenContractAddresses[address(newContract)] = true;

        tokenContractStartTime.push(_startTime);
    }

    function productionUnitTokenContractCount() public view returns (uint) {
        return productionUnitTokenContracts.length;
    }

    function handleProductionIncrease(address player, uint256 amount) public payable {
        require(productionUnitTokenContractAddresses[msg.sender]);

        updatePlayersCookie(player);

        totalCookieProduction = SafeMath.add(totalCookieProduction, amount);
        cookieProduction[player] = SafeMath.add(cookieProduction[player], amount);

        if (msg.value > 0) {
            totalEtherCookieResearchPool += msg.value;
        }
    }

    function handleProductionDecrease(address player, uint256 amount) public payable {
        require(productionUnitTokenContractAddresses[msg.sender]);

        updatePlayersCookie(player);

        totalCookieProduction = SafeMath.sub(totalCookieProduction, amount);
        cookieProduction[player] = SafeMath.sub(cookieProduction[player], amount);

        if (msg.value > 0) {
            totalEtherCookieResearchPool += msg.value;
        }
    }

    function getState() public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        return (totalCookieProduction, cookieProduction[msg.sender], totalSupply(), balanceOf(msg.sender), 
            totalEtherCookieResearchPool, lastTotalCookieSaveTime, computeSellPrice());
    }

    function totalSupply() public constant returns(uint256) {
        return roughSupply + balanceOfTotalUnclaimedCookie();
    }

    function balanceOf(address player) public constant returns(uint256) {
        return cookieBalance[player] + balanceOfUnclaimedCookie(player);
    }

    function balanceOfTotalUnclaimedCookie() public constant returns(uint256) {
        if (lastTotalCookieSaveTime > 0 && lastTotalCookieSaveTime < block.timestamp) {
            return (totalCookieProduction * (block.timestamp - lastTotalCookieSaveTime));
        }

        return 0;
    }

    function balanceOfUnclaimedCookie(address player) internal constant returns (uint256) {
        uint256 lastSave = lastCookieSaveTime[player];

        if (lastSave > 0 && lastSave < block.timestamp) {
            return (cookieProduction[player] * (block.timestamp - lastSave));
        }

        return 0;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        updatePlayersCookie(msg.sender);
        require(amount <= cookieBalance[msg.sender]);

        cookieBalance[msg.sender] -= amount;
        cookieBalance[recipient] += amount;

        Transfer(msg.sender, recipient, amount);

        return true;
    }

    function transferFrom(address player, address recipient, uint256 amount) public returns (bool) {
        updatePlayersCookie(player);
        require(amount <= allowed[player][msg.sender] && amount <= cookieBalance[player]);

        cookieBalance[player] -= amount;
        cookieBalance[recipient] += amount;
        allowed[player][msg.sender] -= amount;

        Transfer(player, recipient, amount);

        return true;
    }

    function approve(address approvee, uint256 amount) public returns (bool){
        allowed[msg.sender][approvee] = amount;
        Approval(msg.sender, approvee, amount);

        return true;
    }

    function allowance(address player, address approvee) public constant returns(uint256){
        return allowed[player][approvee];
    }

    function updatePlayersCookie(address player) internal {
        roughSupply += balanceOfTotalUnclaimedCookie();
        cookieBalance[player] += balanceOfUnclaimedCookie(player);
        lastTotalCookieSaveTime = block.timestamp;
        lastCookieSaveTime[player] = block.timestamp;
    }

     
     
    function sellAllCookies() public {
        updatePlayersCookie(msg.sender);

        uint256 sellPrice = computeSellPrice();

        require(sellPrice > 0);

        uint256 myCookies = cookieBalance[msg.sender];
        uint256 value = myCookies * sellPrice / (1 ether);

        cookieBalance[msg.sender] = 0;

        msg.sender.transfer(value);
    }

     
     
    function computeSellPrice() public view returns (uint) {
        uint256 supply = totalSupply();

        if (supply == 0) {
            return 0;
        }

        uint index;
        uint lastTokenContractStartTime = now;

        while (index < tokenContractStartTime.length && tokenContractStartTime[index] < now) {
            lastTokenContractStartTime = tokenContractStartTime[index];
            index++;
        }

        if (now < lastTokenContractStartTime + 1 hours) {
            return 0;
        }

        uint timeToMaxValue = 2 days;  

        uint256 secondsPassed = now - lastTokenContractStartTime;
        secondsPassed = secondsPassed <= timeToMaxValue ? secondsPassed : timeToMaxValue;
        uint256 multiplier = 5000 + 5000 * secondsPassed / timeToMaxValue;

        return 1 ether * totalEtherCookieResearchPool / supply * multiplier / 10000;
    }

}