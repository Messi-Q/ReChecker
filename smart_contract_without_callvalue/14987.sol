pragma solidity ^0.4.23;

 

contract Zethr {
    using SafeMath for uint;

     

    modifier onlyHolders() {
        require(myFrontEndTokens() > 0);
        _;
    }

    modifier dividendHolder() {
        require(myDividends(true) > 0);
        _;
    }

    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress]);
        _;
    }

     

    event onTokenPurchase(
        address indexed customerAddress,
        uint incomingEthereum,
        uint tokensMinted,
        address indexed referredBy
    );

    event onTokenSell(
        address indexed customerAddress,
        uint tokensBurned,
        uint ethereumEarned
    );

    event onReinvestment(
        address indexed customerAddress,
        uint ethereumReinvested,
        uint tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint ethereumWithdrawn
    );

    event Transfer(
        address indexed from,
        address indexed to,
        uint tokens
    );

    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint tokens
    );

    event Allocation(
        uint toBankRoll,
        uint toReferrer,
        uint toTokenHolders,
        uint toDivCardHolders,
        uint forTokens
    );

     

    uint8 constant public                decimals              = 18;

    uint constant internal               tokenPriceInitial_    = 0.000653 ether;
    uint constant internal               magnitude             = 2**64;

    uint constant internal               icoHardCap            = 250 ether;
    uint constant internal               addressICOLimit       = 2   ether;
    uint constant internal               icoMinBuyIn           = 0.1 finney;
    uint constant internal               icoMaxGasPrice        = 50000000000 wei;

    uint constant internal               MULTIPLIER            = 9615;

    uint constant internal               MIN_ETH_BUYIN         = 0.0001 ether;
    uint constant internal               MIN_TOKEN_SELL_AMOUNT = 0.0001 ether;
    uint constant internal               MIN_TOKEN_TRANSFER    = 1e18;
    uint constant internal               referrer_percentage   = 25;

    uint public                          stakingRequirement    = 100e18;

    

    string public                        name               = "Zethr";
    string public                        symbol             = "ZTH";
    bytes32 constant public              icoHashedPass      = bytes32(0x5d26626a83a2e04be8eab07b75694b6534206d3a4672e8233deea56d00190471);

    address internal                     bankrollAddress;

    ZethrDividendCards                   divCardContract;

    

     
    mapping(address => uint) internal    frontTokenBalanceLedger_;
    mapping(address => uint) internal    dividendTokenBalanceLedger_;
    mapping(address =>
        mapping (address => uint))
                             internal    allowed;

     
    mapping(uint8   => bool)    internal validDividendRates_;
    mapping(address => bool)    internal userSelectedRate;
    mapping(address => uint8)   internal userDividendRate;

     
    mapping(address => uint)    internal referralBalance_;
    mapping(address => int256)  internal payoutsTo_;

     
    mapping(address => uint)    internal ICOBuyIn;

    uint public                          tokensMintedDuringICO;
    uint public                          ethInvestedDuringICO;

    uint public                          currentEthInvested;

    uint internal                        tokenSupply    = 0;
    uint internal                        divTokenSupply = 0;

    uint internal                        profitPerDivToken;

    mapping(address => bool) public      administrators;

    bool public                          icoPhase     = false;
    bool public                          regularPhase = false;

    uint                                 icoOpenTime;

     
     
    constructor (address _bankrollAddress, address _divCardAddress)
        public
    {
        bankrollAddress = _bankrollAddress;
        divCardContract = ZethrDividendCards(_divCardAddress);

        administrators[0x4F4eBF556CFDc21c3424F85ff6572C77c514Fcae] = true;  
        administrators[0x11e52c75998fe2E7928B191bfc5B25937Ca16741] = true;  
        administrators[0x20C945800de43394F70D789874a4daC9cFA57451] = true;  
        administrators[0xef764BAC8a438E7E498c2E5fcCf0f174c3E3F8dB] = true;  

        validDividendRates_[2] = true;
        validDividendRates_[5] = true;
        validDividendRates_[10] = true;
        validDividendRates_[15] = true;
        validDividendRates_[20] = true;
        validDividendRates_[25] = true;
        validDividendRates_[33] = true;

        userSelectedRate[bankrollAddress] = true;
        userDividendRate[bankrollAddress] = 33;

    }

     
    function buyAndSetDivPercentage(address _referredBy, uint8 _divChoice, string providedUnhashedPass)
        public
        payable
        returns (uint)
    {
        require(icoPhase || regularPhase);

        if (icoPhase) {

             
             
             
            bytes32 hashedProvidedPass = keccak256(providedUnhashedPass);
            require(hashedProvidedPass == icoHashedPass);


            uint gasPrice = tx.gasprice;

             
             
            require(gasPrice <= icoMaxGasPrice && ethInvestedDuringICO <= icoHardCap);

        }

         
        require (validDividendRates_[_divChoice]);

         
        userSelectedRate[msg.sender] = true;
        userDividendRate[msg.sender] = _divChoice;

         
        purchaseTokens(msg.value, _referredBy);
    }

    function buy(address _referredBy)
        public
        payable
        returns(uint)
    {
        require(icoPhase || regularPhase);
        address _customerAddress = msg.sender;
        require (userSelectedRate[_customerAddress]);
        purchaseTokens(msg.value, _referredBy);
    }

    function()
        payable
        public
    {
         
        require(icoPhase || regularPhase);
        address _customerAddress = msg.sender;
        if (userSelectedRate[_customerAddress]) {
            purchaseTokens(msg.value, 0x0);
        } else {
            buyAndSetDivPercentage(0x0, 20, "0x0");
        }
    }

    function reinvest()
        dividendHolder()
        public
    {
        require(regularPhase);
        uint _dividends = myDividends(false);

         
        address _customerAddress            = msg.sender;
        payoutsTo_[_customerAddress]       += (int256) (_dividends * magnitude);

        _dividends                         += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress]  = 0;

        uint _tokens                        = purchaseTokens(_dividends, 0x0);

         
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

    function exit()
        public
    {
        require(regularPhase);
         
        address _customerAddress = msg.sender;
        uint _tokens             = frontTokenBalanceLedger_[_customerAddress];

        if(_tokens > 0) sell(_tokens);

        withdraw(_customerAddress);
    }

    function withdraw(address _recipient)
        dividendHolder()
        public
    {
        require(regularPhase);
         
        address _customerAddress           = msg.sender;
        uint _dividends                    = myDividends(false);

         
        payoutsTo_[_customerAddress]       +=  (int256) (_dividends * magnitude);

         
        _dividends                         += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress]  = 0;

        if (_recipient == address(0x0)){
            _recipient = msg.sender;
        }
        _recipient.transfer(_dividends);

         
        emit onWithdraw(_recipient, _dividends);
    }

     
     
    function sell(uint _amountOfTokens)
        onlyHolders()
        public
    {
         
        require(!icoPhase);
        require(regularPhase);

        require(_amountOfTokens <= frontTokenBalanceLedger_[msg.sender]);

        uint _frontEndTokensToBurn = _amountOfTokens;

         
         
        uint _divTokensToBurn = (_frontEndTokensToBurn.mul(getUserAverageDividendRate(msg.sender))).div(magnitude);

         
        uint _ethereum = tokensToEthereum_(_frontEndTokensToBurn);

        if (_ethereum > currentEthInvested){
             
            currentEthInvested = 0;
        } else { currentEthInvested = currentEthInvested - _ethereum; }

         
        uint _dividends = (_ethereum.mul(getUserAverageDividendRate(msg.sender)).div(100)).div(magnitude);

         
        uint _taxedEthereum = _ethereum.sub(_dividends);

         
        tokenSupply         = tokenSupply.sub(_frontEndTokensToBurn);
        divTokenSupply      = divTokenSupply.sub(_divTokensToBurn);

         
        frontTokenBalanceLedger_[msg.sender]    = frontTokenBalanceLedger_[msg.sender].sub(_frontEndTokensToBurn);
        dividendTokenBalanceLedger_[msg.sender] = dividendTokenBalanceLedger_[msg.sender].sub(_divTokensToBurn);

         
        int256 _updatedPayouts  = (int256) (profitPerDivToken * _divTokensToBurn + (_taxedEthereum * magnitude));
        payoutsTo_[msg.sender] -= _updatedPayouts;

         
        if (divTokenSupply > 0) {
             
            profitPerDivToken = profitPerDivToken.add((_dividends * magnitude) / divTokenSupply);
        }

         
        emit onTokenSell(msg.sender, _frontEndTokensToBurn, _taxedEthereum);
    }

     
    function transfer(address _toAddress, uint _amountOfTokens)
        onlyHolders()
        public
        returns(bool)
    {
        require(regularPhase);
         
        address _customerAddress     = msg.sender;
        uint _amountOfFrontEndTokens = _amountOfTokens;

         
        require(_amountOfTokens >= MIN_TOKEN_TRANSFER
             && _amountOfTokens <= frontTokenBalanceLedger_[_customerAddress]);

         
        if(myDividends(true) > 0) withdraw(_customerAddress);

         
         
        uint _amountOfDivTokens = _amountOfFrontEndTokens.mul(getUserAverageDividendRate(_customerAddress)).div(magnitude);

         
        frontTokenBalanceLedger_[_customerAddress]    = frontTokenBalanceLedger_[_customerAddress].sub(_amountOfFrontEndTokens);
        frontTokenBalanceLedger_[_toAddress]          = frontTokenBalanceLedger_[_toAddress].add(_amountOfFrontEndTokens);
        dividendTokenBalanceLedger_[_customerAddress] = dividendTokenBalanceLedger_[_customerAddress].sub(_amountOfDivTokens);
        dividendTokenBalanceLedger_[_toAddress]       = dividendTokenBalanceLedger_[_toAddress].add(_amountOfDivTokens);

         
        if(!userSelectedRate[_toAddress])
        {
            userSelectedRate[_toAddress] = true;
            userDividendRate[_toAddress] = userDividendRate[_customerAddress];
        }

         
        payoutsTo_[_customerAddress] -= (int256) (profitPerDivToken * _amountOfDivTokens);
        payoutsTo_[_toAddress]       += (int256) (profitPerDivToken * _amountOfDivTokens);

         
        emit Transfer(_customerAddress, _toAddress, _amountOfFrontEndTokens);

         
        return true;

    }

    function approve(address spender, uint tokens)
        public
        returns (bool)
    {
        address _customerAddress           = msg.sender;
        allowed[_customerAddress][spender] = tokens;

         
        emit Approval(_customerAddress, spender, tokens);

         
        return true;
    }

     
    function transferFrom(address _from, address _toAddress, uint _amountOfTokens)
        public
        returns(bool)
    {
        require(regularPhase);
         
        address _customerAddress     = _from;
        uint _amountOfFrontEndTokens = _amountOfTokens;

         
         
        require(_amountOfTokens >= MIN_TOKEN_TRANSFER
             && _amountOfTokens <= frontTokenBalanceLedger_[_customerAddress]
             && _amountOfTokens <= allowed[_customerAddress][msg.sender]);

         
        if(theDividendsOf(true, _customerAddress) > 0) withdrawFrom(_customerAddress);

         
         
        uint _amountOfDivTokens = _amountOfFrontEndTokens.mul(getUserAverageDividendRate(_customerAddress)).div(magnitude);

         
        allowed[_customerAddress][msg.sender] -= _amountOfTokens;

         
        frontTokenBalanceLedger_[_customerAddress]    = frontTokenBalanceLedger_[_customerAddress].sub(_amountOfFrontEndTokens);
        frontTokenBalanceLedger_[_toAddress]          = frontTokenBalanceLedger_[_toAddress].add(_amountOfFrontEndTokens);
        dividendTokenBalanceLedger_[_customerAddress] = dividendTokenBalanceLedger_[_customerAddress].sub(_amountOfDivTokens);
        dividendTokenBalanceLedger_[_toAddress]       = dividendTokenBalanceLedger_[_toAddress].add(_amountOfDivTokens);

         
        if(!userSelectedRate[_toAddress])
        {
            userSelectedRate[_toAddress] = true;
            userDividendRate[_toAddress] = userDividendRate[_customerAddress];
        }

         
        payoutsTo_[_customerAddress] -= (int256) (profitPerDivToken * _amountOfDivTokens);
        payoutsTo_[_toAddress]       += (int256) (profitPerDivToken * _amountOfDivTokens);

         
        emit Transfer(_customerAddress, _toAddress, _amountOfFrontEndTokens);

         
        return true;

    }

     
    function totalSupply()
        public
        view
        returns (uint256)
    {
        return tokenSupply;
    }

     
     
    function publicStartRegularPhase()
        public
    {
        require(now > (icoOpenTime + 2 weeks) && icoOpenTime != 0);

        icoPhase     = false;
        regularPhase = true;
    }

     


     
    function startICOPhase()
        onlyAdministrator()
        public
    {
         
        require(icoOpenTime == 0);
        icoPhase = true;
        icoOpenTime = now;
    }

     
    function endICOPhase()
        onlyAdministrator()
        public
    {
        icoPhase = false;
    }

    function startRegularPhase()
        onlyAdministrator
                public
    {
         
        icoPhase = false;
        regularPhase = true;
    }

     
    function setAdministrator(address _newAdmin, bool _status)
        onlyAdministrator()
        public
    {
        administrators[_newAdmin] = _status;
    }

    function setStakingRequirement(uint _amountOfTokens)
        onlyAdministrator()
        public
    {
         
        require (_amountOfTokens >= 100e18);
        stakingRequirement = _amountOfTokens;
    }

    function setName(string _name)
        onlyAdministrator()
        public
    {
        name = _name;
    }

    function setSymbol(string _symbol)
        onlyAdministrator()
        public
    {
        symbol = _symbol;
    }

    function changeBankroll(address _newBankrollAddress)
        onlyAdministrator
        public
    {
        bankrollAddress = _newBankrollAddress;
    }

     

    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance;
    }

    function totalEthereumICOReceived()
        public
        view
        returns(uint)
    {
        return ethInvestedDuringICO;
    }

     
    function getMyDividendRate()
        public
        view
        returns(uint8)
    {
        address _customerAddress = msg.sender;
        require(userSelectedRate[_customerAddress]);
        return userDividendRate[_customerAddress];
    }

     
    function getFrontEndTokenSupply()
        public
        view
        returns(uint)
    {
        return tokenSupply;
    }

     
    function getDividendTokenSupply()
        public
        view
        returns(uint)
    {
        return divTokenSupply;
    }

     
    function myFrontEndTokens()
        public
        view
        returns(uint)
    {
        address _customerAddress = msg.sender;
        return getFrontEndTokenBalanceOf(_customerAddress);
    }

     
    function myDividendTokens()
        public
        view
        returns(uint)
    {
        address _customerAddress = msg.sender;
        return getDividendTokenBalanceOf(_customerAddress);
    }

    function myDividends(bool _includeReferralBonus)
        public
        view
        returns(uint)
    {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }

    function theDividendsOf(bool _includeReferralBonus, address _customerAddress)
        public
        view
        returns(uint)
    {
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }

    function getFrontEndTokenBalanceOf(address _customerAddress)
        view
        public
        returns(uint)
    {
        return frontTokenBalanceLedger_[_customerAddress];
    }

    function getDividendTokenBalanceOf(address _customerAddress)
        view
        public
        returns(uint)
    {
        return dividendTokenBalanceLedger_[_customerAddress];
    }

    function dividendsOf(address _customerAddress)
        view
        public
        returns(uint)
    {
        return (uint) ((int256)(profitPerDivToken * dividendTokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

     
    function sellPrice()
        public
        view
        returns(uint)
    {
        uint price;

        if (icoPhase || currentEthInvested < ethInvestedDuringICO) {
          price = tokenPriceInitial_;
        } else {

           
           
          uint tokensReceivedForEth = ethereumToTokens_(0.001 ether);

          price = (1e18 * 0.001 ether) / tokensReceivedForEth;
        }

         
        uint theSellPrice = price.sub((price.mul(getUserAverageDividendRate(msg.sender)).div(100)).div(magnitude));

        return theSellPrice;
    }

     
    function buyPrice(uint dividendRate)
        public
        view
        returns(uint)
    {
        uint price;

        if (icoPhase || currentEthInvested < ethInvestedDuringICO) {
          price = tokenPriceInitial_;
        } else {

           
           
          uint tokensReceivedForEth = ethereumToTokens_(0.001 ether);

          price = (1e18 * 0.001 ether) / tokensReceivedForEth;
        }

         
        uint theBuyPrice = (price.mul(dividendRate).div(100)).add(price);

        return theBuyPrice;
    }

    function calculateTokensReceived(uint _ethereumToSpend)
        public
        view
        returns(uint)
    {
        uint _dividends      = (_ethereumToSpend.mul(userDividendRate[msg.sender])).div(100);
        uint _taxedEthereum  = _ethereumToSpend.sub(_dividends);
        uint _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        return  _amountOfTokens;
    }

     
     
    function calculateEthereumReceived(uint _tokensToSell)
        public
        view
        returns(uint)
    {
        require(_tokensToSell <= tokenSupply);
        uint _ethereum               = tokensToEthereum_(_tokensToSell);
        uint userAverageDividendRate = getUserAverageDividendRate(msg.sender);
        uint _dividends              = (_ethereum.mul(userAverageDividendRate).div(100)).div(magnitude);
        uint _taxedEthereum          = _ethereum.sub(_dividends);
        return  _taxedEthereum;
    }

     

    function getUserAverageDividendRate(address user) public view returns (uint) {
        return (magnitude * dividendTokenBalanceLedger_[user]).div(frontTokenBalanceLedger_[msg.sender]);
    }

    function getMyAverageDividendRate() public view returns (uint) {
        return getUserAverageDividendRate(msg.sender);
    }

     

     
    function purchaseTokens(uint _incomingEthereum, address _referredBy)
        internal
        returns(uint)
    {
        require(_incomingEthereum >= MIN_ETH_BUYIN || msg.sender == bankrollAddress, "Tried to buy below the min eth buyin threshold.");

        uint toBankRoll;
        uint toReferrer;
        uint toTokenHolders;
        uint toDivCardHolders;

        uint dividendAmount;

        uint tokensBought;
        uint dividendTokensBought;

        uint remainingEth = _incomingEthereum;

        uint fee;

         
        if (regularPhase) {
            toDivCardHolders = _incomingEthereum.div(100);
            remainingEth = remainingEth.sub(toDivCardHolders);
        }

         

         
        uint dividendRate = userDividendRate[msg.sender];

         
        dividendAmount = (remainingEth.mul(dividendRate)).div(100);

        remainingEth   = remainingEth.sub(dividendAmount);

        if (msg.sender == bankrollAddress){
                remainingEth += dividendAmount;
        }

         
        tokensBought         = ethereumToTokens_(remainingEth);
        dividendTokensBought = tokensBought.mul(dividendRate);

         
        tokenSupply    = tokenSupply.add(tokensBought);
        divTokenSupply = divTokenSupply.add(dividendTokensBought);

         

        currentEthInvested = currentEthInvested + remainingEth;

         
        if (icoPhase) {
            toBankRoll     = dividendAmount;
            if (msg.sender == bankrollAddress){
                 
                toBankRoll = 0;
            }
            toReferrer     = 0;
            toTokenHolders = 0;

             
            ethInvestedDuringICO = ethInvestedDuringICO + remainingEth;
            tokensMintedDuringICO = tokensMintedDuringICO + tokensBought;

             
            require(ethInvestedDuringICO <= icoHardCap);
             
            require(tx.origin == msg.sender || msg.sender == bankrollAddress);

             
            ICOBuyIn[msg.sender] += remainingEth;
            require(ICOBuyIn[msg.sender] <= addressICOLimit || msg.sender == bankrollAddress);

             
            if (ethInvestedDuringICO == icoHardCap){
                icoPhase = false;
            }

        } else {
         

             
             
            if (_referredBy != 0x0000000000000000000000000000000000000000 &&
                _referredBy != msg.sender &&
                frontTokenBalanceLedger_[_referredBy] >= stakingRequirement)
            {
                toReferrer = (dividendAmount.mul(referrer_percentage)).div(100);
                referralBalance_[_referredBy] += toReferrer;
            }

             
            toTokenHolders = dividendAmount.sub(toReferrer);

            fee = toTokenHolders * magnitude;
            fee = fee - (fee - (dividendTokensBought * (toTokenHolders * magnitude / (divTokenSupply))));

             
            profitPerDivToken       = profitPerDivToken.add((toTokenHolders.mul(magnitude)).div(divTokenSupply));
            payoutsTo_[msg.sender] += (int256) ((profitPerDivToken * dividendTokensBought) - fee);
        }

         
        frontTokenBalanceLedger_[msg.sender] = frontTokenBalanceLedger_[msg.sender].add(tokensBought);
        dividendTokenBalanceLedger_[msg.sender] = dividendTokenBalanceLedger_[msg.sender].add(dividendTokensBought);

         
        if (toBankRoll != 0) { ZethrBankroll(bankrollAddress).receiveDividends.value(toBankRoll)(); }
        if (regularPhase) { divCardContract.receiveDividends.value(toDivCardHolders)(dividendRate); }

         
        emit Allocation(toBankRoll, toReferrer, toTokenHolders, toDivCardHolders, remainingEth);

         
        uint sum = toBankRoll + toReferrer + toTokenHolders + toDivCardHolders + remainingEth;
        assert(sum == _incomingEthereum);
    }

     
    function ethereumToTokens_(uint _ethereumAmount)
        public
        view
        returns(uint)
    {
        require(_ethereumAmount > MIN_ETH_BUYIN, "Tried to buy tokens with too little eth.");

        if (icoPhase) {
            return _ethereumAmount.div(tokenPriceInitial_) * 1e18;
        }

         

         
         
         
        uint ethTowardsICOPriceTokens = 0;
        uint ethTowardsVariablePriceTokens = 0;

        if (currentEthInvested >= ethInvestedDuringICO) {
         
          ethTowardsVariablePriceTokens = _ethereumAmount;

        } else if (currentEthInvested < ethInvestedDuringICO && currentEthInvested + _ethereumAmount <= ethInvestedDuringICO) {
         
          ethTowardsICOPriceTokens = _ethereumAmount;

        } else if (currentEthInvested < ethInvestedDuringICO && currentEthInvested + _ethereumAmount > ethInvestedDuringICO) {
         
          ethTowardsICOPriceTokens = ethInvestedDuringICO.sub(currentEthInvested);
          ethTowardsVariablePriceTokens = _ethereumAmount.sub(ethTowardsICOPriceTokens);
        } else {
                 
                    revert();
                }

         
        assert(ethTowardsICOPriceTokens + ethTowardsVariablePriceTokens == _ethereumAmount);

         
        uint icoPriceTokens = 0;
        uint varPriceTokens = 0;

         
         
        if (ethTowardsICOPriceTokens != 0) {
          icoPriceTokens = ethTowardsICOPriceTokens.div(tokenPriceInitial_) * 1e18;
        }

        if (ethTowardsVariablePriceTokens != 0) {
           
           
           
           

          uint simulatedEthBeforeInvested = toPowerOfThreeHalves(tokenSupply.div(MULTIPLIER * 1e6)).mul(2).div(3) + ethTowardsICOPriceTokens;
          uint simulatedEthAfterInvested  = simulatedEthBeforeInvested + ethTowardsVariablePriceTokens;

           

          uint tokensBefore = toPowerOfTwoThirds(simulatedEthBeforeInvested.mul(3).div(2)).mul(MULTIPLIER);
          uint tokensAfter  = toPowerOfTwoThirds(simulatedEthAfterInvested.mul(3).div(2)).mul(MULTIPLIER);

           

          varPriceTokens = (1e6) * tokensAfter.sub(tokensBefore);
        }

        uint totalTokensReceived = icoPriceTokens + varPriceTokens;

        assert(totalTokensReceived > 0);
        return totalTokensReceived;
    }

     
    function tokensToEthereum_(uint _tokens)
        public
        view
        returns(uint)
    {
        require (_tokens >= MIN_TOKEN_SELL_AMOUNT, "Tried to sell too few tokens.");

         

         
         
         
                uint tokensToSellAtICOPrice = 0;
                uint tokensToSellAtVariablePrice = 0;

                if (tokenSupply <= tokensMintedDuringICO) {
                 
                    tokensToSellAtICOPrice = _tokens;

                } else if (tokenSupply > tokensMintedDuringICO && tokenSupply - _tokens >= tokensMintedDuringICO) {
                 
                    tokensToSellAtVariablePrice = _tokens;

                } else if (tokenSupply > tokensMintedDuringICO && tokenSupply - _tokens < tokensMintedDuringICO) {
                 
                    tokensToSellAtVariablePrice = tokenSupply.sub(tokensMintedDuringICO);
                    tokensToSellAtICOPrice      = _tokens.sub(tokensToSellAtVariablePrice);

                } else {
                 
                    revert();
                }

         
        assert(tokensToSellAtVariablePrice + tokensToSellAtICOPrice == _tokens);

         
        uint ethFromICOPriceTokens;
        uint ethFromVarPriceTokens;

         

        if (tokensToSellAtICOPrice != 0) {

           

          ethFromICOPriceTokens = tokensToSellAtICOPrice.mul(tokenPriceInitial_).div(1e18);
        }

        if (tokensToSellAtVariablePrice != 0) {

           

          uint investmentBefore = toPowerOfThreeHalves(tokenSupply.div(MULTIPLIER * 1e6)).mul(2).div(3);
          uint investmentAfter  = toPowerOfThreeHalves((tokenSupply - tokensToSellAtVariablePrice).div(MULTIPLIER * 1e6)).mul(2).div(3);

          ethFromVarPriceTokens = investmentBefore.sub(investmentAfter);
        }

        uint totalEthReceived = ethFromVarPriceTokens + ethFromICOPriceTokens;

        assert(totalEthReceived > 0);
        return totalEthReceived;
    }

     
    function withdrawFrom(address _customerAddress)
        internal
    {
         
        uint _dividends                    = theDividendsOf(false, _customerAddress);

         
        payoutsTo_[_customerAddress]       +=  (int256) (_dividends * magnitude);

         
        _dividends                         += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress]  = 0;

        _customerAddress.transfer(_dividends);

         
        emit onWithdraw(_customerAddress, _dividends);
    }

     

    function toPowerOfThreeHalves(uint x) public pure returns (uint) {
         
         
        return sqrt(x**3);
    }

    function toPowerOfTwoThirds(uint x) public pure returns (uint) {
         
         
        return cbrt(x**2);
    }

    function sqrt(uint x) public pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function cbrt(uint x) public pure returns (uint y) {
        uint z = (x + 1) / 3;
        y = x;
        while (z < y) {
            y = z;
            z = (x / (z*z) + 2 * z) / 3;
        }
    }
}

     


contract ZethrDividendCards {
    function ownerOf(uint  ) public pure returns (address) {}
    function receiveDividends(uint  ) public payable {}
}

contract ZethrBankroll{
    function receiveDividends() public payable {}
}

 

library SafeMath {

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
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
}