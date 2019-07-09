pragma solidity ^0.4.18;

contract Manager {
    address public ceo;
    address public cfo;
    address public coo;
    address public cao;

    event OwnershipTransferred(address previousCeo, address newCeo);
    event Pause();
    event Unpause();


     
    function Manager() public {
        coo = msg.sender; 
        cfo = 0x7810704C6197aFA95e940eF6F719dF32657AD5af;
        ceo = 0x96C0815aF056c5294Ad368e3FBDb39a1c9Ae4e2B;
        cao = 0xC4888491B404FfD15cA7F599D624b12a9D845725;
    }

     
    modifier onlyCEO() {
        require(msg.sender == ceo);
        _;
    }

    modifier onlyCOO() {
        require(msg.sender == coo);
        _;
    }

    modifier onlyCAO() {
        require(msg.sender == cao);
        _;
    }
    
    bool allowTransfer = false;
    
    function changeAllowTransferState() public onlyCOO {
        if (allowTransfer) {
            allowTransfer = false;
        } else {
            allowTransfer = true;
        }
    }
    
    modifier whenTransferAllowed() {
        require(allowTransfer);
        _;
    }

     
    function demiseCEO(address newCeo) public onlyCEO {
        require(newCeo != address(0));
        emit OwnershipTransferred(ceo, newCeo);
        ceo = newCeo;
    }

    function setCFO(address newCfo) public onlyCEO {
        require(newCfo != address(0));
        cfo = newCfo;
    }

    function setCOO(address newCoo) public onlyCEO {
        require(newCoo != address(0));
        coo = newCoo;
    }

    function setCAO(address newCao) public onlyCEO {
        require(newCao != address(0));
        cao = newCao;
    }

    bool public paused = false;


     
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

     
    modifier whenPaused() {
        require(paused);
        _;
    }

     
    function pause() onlyCAO whenNotPaused public {
        paused = true;
        emit Pause();
    }

     
    function unpause() onlyCAO whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract AlchemyBase is Manager {

     
    mapping (address => bytes32[8]) assets;

     
    event Transfer(address from, address to);

     
    function assetOf(address account) public view returns(bytes32[8]) {
        return assets[account];
    }

    function _checkAndAdd(bytes32 x, bytes32 y) internal pure returns(bytes32) {
        bytes32 mask = bytes32(255);  

        bytes32 result;

        uint maskedX;
        uint maskedY;
        uint maskedResult;

        for (uint i = 0; i < 31; i++) {
             
            if (i > 0) {
                mask = mask << 8;
            }

             
            maskedX = uint(x & mask);
            maskedY = uint(y & mask);
            maskedResult = maskedX + maskedY;

             
            require(maskedResult < (2 ** (8 * (i + 1))));

             
            result = (result ^ mask) & result;

             
            result = result | bytes32(maskedResult);
        }

        return result;
    }

    function _checkAndSub(bytes32 x, bytes32 y) internal pure returns(bytes32) {
        bytes32 mask = bytes32(255);  

        bytes32 result;

        uint maskedX;
        uint maskedY;
        uint maskedResult;

        for (uint i = 0; i < 31; i++) {
             
            if (i > 0) {
                mask = mask << 8;
            }

             
            maskedX = uint(x & mask);
            maskedY = uint(y & mask);

             
            require(maskedX >= maskedY);

             
            maskedResult = maskedX - maskedY;

             
            result = (result ^ mask) & result;

             
            result = result | bytes32(maskedResult);
        }

        return result;
    }

     
    function transfer(address to, bytes32[8] value) public whenNotPaused whenTransferAllowed {
         
        require(msg.sender != to);
        bytes32[8] memory assetFrom = assets[msg.sender];
        bytes32[8] memory assetTo = assets[to];

        for (uint256 i = 0; i < 8; i++) {
            assetFrom[i] = _checkAndSub(assetFrom[i], value[i]);
            assetTo[i] = _checkAndAdd(assetTo[i], value[i]);
        }

        assets[msg.sender] = assetFrom;
        assets[to] = assetTo;

         
        emit Transfer(msg.sender, to);
    }

     
    function withdrawETH() external onlyCAO {
        cfo.transfer(address(this).balance);
    }
}


contract AlchemyPatent is AlchemyBase {

     
    struct Patent {
         
        address patentOwner;
         
        uint256 beginTime;
         
        bool onSale; 
         
        uint256 price;
         
        uint256 lastPrice;
         
        uint256 sellTime;
    }

     
    mapping (uint16 => Patent) public patents;

     
     
    uint256 public feeRatio = 9705;

    uint256 public patentValidTime = 2 days;
    uint256 public patentSaleTimeDelay = 2 hours;

     
    event RegisterCreator(address account, uint16 kind);
    event SellPatent(uint16 assetId, uint256 sellPrice);
    event ChangePatentSale(uint16 assetId, uint256 newPrice);
    event BuyPatent(uint16 assetId, address buyer);

     
    function setPatentFee(uint256 newFeeRatio) external onlyCOO {
        require(newFeeRatio <= 10000);
        feeRatio = newFeeRatio;
    }

     
    function sellPatent(uint16 assetId, uint256 sellPrice) public whenNotPaused {
        Patent memory patent = patents[assetId];
        require(patent.patentOwner == msg.sender);
        if (patent.lastPrice > 0) {
            require(sellPrice <= 2 * patent.lastPrice);
        } else {
            require(sellPrice <= 1 ether);
        }
        
        require(!patent.onSale);

        patent.onSale = true;
        patent.price = sellPrice;
        patent.sellTime = now;

        patents[assetId] = patent;

         
        emit SellPatent(assetId, sellPrice);
    }

    function publicSell(uint16 assetId) public whenNotPaused {
        Patent memory patent = patents[assetId];
        require(patent.patentOwner != address(0));   
        require(!patent.onSale);
        require(patent.beginTime + patentValidTime < now);

        patent.onSale = true;
        patent.price = patent.lastPrice;
        patent.sellTime = now;

        patents[assetId] = patent;

         
        emit SellPatent(assetId, patent.lastPrice);
    }

     
    function changePatentSale(uint16 assetId, uint256 newPrice) external whenNotPaused {
        Patent memory patent = patents[assetId];
        require(patent.patentOwner == msg.sender);
        if (patent.lastPrice > 0) {
            require(newPrice <= 2 * patent.lastPrice);
        } else {
            require(newPrice <= 1 ether);
        }
        require(patent.onSale == true);

        patent.price = newPrice;

        patents[assetId] = patent;

         
        emit ChangePatentSale(assetId, newPrice);
    }

     
    function buyPatent(uint16 assetId) external payable whenNotPaused {
        Patent memory patent = patents[assetId];
        require(patent.patentOwner != address(0));   
        require(patent.patentOwner != msg.sender);
        require(patent.onSale);
        require(msg.value >= patent.price);
        require(now >= patent.sellTime + patentSaleTimeDelay);

        patent.patentOwner.transfer(patent.price / 10000 * feeRatio);
        patent.patentOwner = msg.sender;
        patent.beginTime = now;
        patent.onSale = false;
        patent.lastPrice = patent.price;

        patents[assetId] = patent;

         
        emit BuyPatent(assetId, msg.sender);
    }
}


contract ChemistryInterface {
    function isChemistry() public pure returns (bool);

     
    function turnOnFurnace(uint16[5] inputAssets, uint128 addition) public returns (uint16[5]);

    function computeCooldownTime(uint128 typeAdd, uint256 baseTime) public returns (uint256);
}



contract SkinInterface {
    function getActiveSkin(address account) public view returns (uint128);
}




contract AlchemySynthesize is AlchemyPatent {

     
    ChemistryInterface public chemistry;
    SkinInterface public skinContract;

     
    uint256[9] public cooldownLevels = [
        5 minutes,
        10 minutes,
        15 minutes,
        20 minutes,
        25 minutes,
        30 minutes,
        35 minutes,
        40 minutes,
        45 minutes
    ];

     
    uint256[9] public pFees = [
        0,
        2 finney,
        4 finney,
        8 finney,
        12 finney,
        18 finney,
        26 finney,
        36 finney,
        48 finney
    ];

     
    struct Furnace {
         
        uint16[5] pendingAssets;
         
        uint256 cooldownEndTime;
         
        bool inSynthesization;
         
        uint256 count;
    }

    uint256 public maxSCount = 10;

     
    mapping (address => Furnace) public accountsToFurnace;

     
    mapping (uint16 => uint256) public assetLevel;

     
    uint256 public prePaidFee = 1000000 * 3000000000;  

    bool public isSynthesizeAllowed = false;

     
     
    event AutoSynthesize(address account, uint256 cooldownEndTime);
    event SynthesizeSuccess(address account);

     
    function initializeLevel() public onlyCOO {
         
        uint8[9] memory levelSplits = [4,      
                                          19,     
                                          46,     
                                          82,     
                                          125,    
                                          156,
                                          180,
                                          195,
                                          198];   
        uint256 currentLevel = 0;
        for (uint8 i = 0; i < 198; i ++) {
            if (i == levelSplits[currentLevel]) {
                currentLevel ++;
            }
            assetLevel[uint16(i)] = currentLevel;
        }
    }

    function setAssetLevel(uint16 assetId, uint256 level) public onlyCOO {
        assetLevel[assetId] = level;
    }

    function setMaxCount(uint256 max) external onlyCOO {
        maxSCount = max;
    }

    function setPatentFees(uint256[9] newFees) external onlyCOO {
        for (uint256 i = 0; i < 9; i++) {
            pFees[i] = newFees[i];
        }
    }

    function changeSynthesizeAllowed(bool newState) external onlyCOO {
        isSynthesizeAllowed = newState;
    }

     
    function getFurnace(address account) public view returns (uint16[5], uint256, bool, uint256) {
        return (accountsToFurnace[account].pendingAssets, accountsToFurnace[account].cooldownEndTime, accountsToFurnace[account].inSynthesization, accountsToFurnace[account].count);
    }

     
    function setChemistryAddress(address chemistryAddress) external onlyCOO {
        ChemistryInterface candidateContract = ChemistryInterface(chemistryAddress);

        require(candidateContract.isChemistry());

        chemistry = candidateContract;
    }

     
    function setSkinContract(address skinAddress) external onlyCOO {
        skinContract = SkinInterface(skinAddress);
    }

     
    function setPrePaidFee(uint256 newPrePaidFee) external onlyCOO {
        prePaidFee = newPrePaidFee;
    }

     
    function _isCooldownReady(address account) internal view returns (bool) {
        return (accountsToFurnace[account].cooldownEndTime <= now);
    }

     
    function synthesize(uint16[5] inputAssets, uint256 sCount) public payable whenNotPaused {
        require(isSynthesizeAllowed == true);
         
        require(accountsToFurnace[msg.sender].inSynthesization == false);
         
        require(sCount <= maxSCount && sCount > 0);

         
        bytes32[8] memory asset = assets[msg.sender];

        bytes32 mask;  
        uint256 maskedValue;
        uint256 count;
        bytes32 _asset;
        uint256 pos;
        uint256 maxLevel = 0;
        uint256 totalFee = 0;
        uint256 _assetLevel;
        Patent memory _patent;
        uint16 currentAsset;

        for (uint256 i = 0; i < 5; i++) {
            currentAsset = inputAssets[i];
            if (currentAsset < 248) {
                _asset = asset[currentAsset / 31];
                pos = currentAsset % 31;
                mask = bytes32(255) << (8 * pos);
                maskedValue = uint256(_asset & mask);

                require(maskedValue >= (sCount << (8*pos)));
                maskedValue -= (sCount << (8*pos));
                _asset = ((_asset ^ mask) & _asset) | bytes32(maskedValue);
                asset[currentAsset / 31] = _asset;
                count += 1;

                 
                _assetLevel = assetLevel[currentAsset];
                if (_assetLevel > maxLevel) {
                    maxLevel = _assetLevel;
                }

                if (_assetLevel > 0) {
                    _patent = patents[currentAsset];
                    if (_patent.patentOwner != address(0) && _patent.patentOwner != msg.sender && !_patent.onSale && (_patent.beginTime + patentValidTime > now)) {
                        maskedValue = pFees[_assetLevel] * sCount;
                        _patent.patentOwner.transfer(maskedValue / 10000 * feeRatio);
                        totalFee += maskedValue;
                    }
                }
            }
        }

        require(msg.value >= prePaidFee + totalFee);

        require(count >= 2 && count <= 5);

         
        require(_isCooldownReady(msg.sender));

        uint128 skinType = skinContract.getActiveSkin(msg.sender);
        uint256 _cooldownTime = chemistry.computeCooldownTime(skinType, cooldownLevels[maxLevel]);

        accountsToFurnace[msg.sender].pendingAssets = inputAssets;
        accountsToFurnace[msg.sender].cooldownEndTime = now + _cooldownTime;
        accountsToFurnace[msg.sender].inSynthesization = true;
        accountsToFurnace[msg.sender].count = sCount;
        assets[msg.sender] = asset;

         
         
        emit AutoSynthesize(msg.sender, accountsToFurnace[msg.sender].cooldownEndTime);
    }

    function getPatentFee(address account, uint16[5] inputAssets, uint256 sCount) external view returns (uint256) {

        uint256 totalFee = 0;
        uint256 _assetLevel;
        Patent memory _patent;
        uint16 currentAsset;

        for (uint256 i = 0; i < 5; i++) {
            currentAsset = inputAssets[i];
            if (currentAsset < 248) {

                 
                _assetLevel = assetLevel[currentAsset];
                if (_assetLevel > 0) {
                    _patent = patents[currentAsset];
                    if (_patent.patentOwner != address(0) && _patent.patentOwner != account && !_patent.onSale && (_patent.beginTime + patentValidTime > now)) {
                        totalFee += pFees[_assetLevel] * sCount;
                    }
                }
            }
        }
        return totalFee;
    }

     
     
    function getSynthesizationResult(address account) external whenNotPaused {

         
        require(accountsToFurnace[account].inSynthesization);

         
        require(_isCooldownReady(account));

         
        uint16[5] memory _pendingAssets = accountsToFurnace[account].pendingAssets;
        uint128 skinType = skinContract.getActiveSkin(account);
        uint16[5] memory resultAssets;  

         
        bytes32[8] memory asset = assets[account];

        bytes32 mask;  
        uint256 maskedValue;
        uint256 j;
        uint256 pos;

        for (uint256 k = 0; k < accountsToFurnace[account].count; k++) {
            resultAssets = chemistry.turnOnFurnace(_pendingAssets, skinType);
            for (uint256 i = 0; i < 5; i++) {
                if (resultAssets[i] < 248) {
                    j = resultAssets[i] / 31;
                    pos = resultAssets[i] % 31;
                    mask = bytes32(255) << (8 * pos);
                    maskedValue = uint256(asset[j] & mask);

                    require(maskedValue < (uint256(255) << (8*pos)));
                    maskedValue += (uint256(1) << (8*pos));
                    asset[j] = ((asset[j] ^ mask) & asset[j]) | bytes32(maskedValue);

                     
                    if (resultAssets[i] > 3 && patents[resultAssets[i]].patentOwner == address(0)) {
                        patents[resultAssets[i]] = Patent({patentOwner: account,
                                                        beginTime: now,
                                                        onSale: false,
                                                        price: 0,
                                                        lastPrice: 100 finney,
                                                        sellTime: 0});
                         
                        emit RegisterCreator(account, resultAssets[i]);
                    }
                }
            }
        }


         
        accountsToFurnace[account].inSynthesization = false;
        accountsToFurnace[account].count = 0;
        assets[account] = asset;

        msg.sender.transfer(prePaidFee);

        emit SynthesizeSuccess(account);
    }
}


contract AlchemyMinting is AlchemySynthesize {

     
    uint256 public zoDailyLimit = 2500;  
    uint256[4] public zoCreated;
    
     
    mapping(address => bytes32) public accountsBoughtZoAsset;
    mapping(address => uint256) public accountsZoLastRefreshTime;

     
    uint256 public zoPrice = 1 finney;

     
    uint256 public zoLastRefreshTime = now;

     
    event BuyZeroOrderAsset(address account, bytes32 values);

     
     
    function setZoPrice(uint256 newPrice) external onlyCOO {
        zoPrice = newPrice;
    }

     
    function buyZoAssets(bytes32 values) external payable whenNotPaused {
         
        bytes32 history = accountsBoughtZoAsset[msg.sender];
        if (accountsZoLastRefreshTime[msg.sender] == uint256(0)) {
             
            accountsZoLastRefreshTime[msg.sender] = zoLastRefreshTime;
        } else {
            if (accountsZoLastRefreshTime[msg.sender] < zoLastRefreshTime) {
                history = bytes32(0);
                accountsZoLastRefreshTime[msg.sender] = zoLastRefreshTime;
            }
        }
 
        uint256 currentCount = 0;
        uint256 count = 0;

        bytes32 mask = bytes32(255);  
        uint256 maskedValue;
        uint256 maskedResult;

        bytes32 asset = assets[msg.sender][0];

        for (uint256 i = 0; i < 4; i++) {
            if (i > 0) {
                mask = mask << 8;
            }
            maskedValue = uint256(values & mask);
            currentCount = maskedValue / 2 ** (8 * i);
            count += currentCount;

             
            maskedResult = uint256(history & mask); 
            maskedResult += maskedValue;
            require(maskedResult < (2 ** (8 * (i + 1))));

             
            history = ((history ^ mask) & history) | bytes32(maskedResult);

             
            maskedResult = uint256(asset & mask);
            maskedResult += maskedValue;
            require(maskedResult < (2 ** (8 * (i + 1))));

             
            asset = ((asset ^ mask) & asset) | bytes32(maskedResult);

             
            require(zoCreated[i] + currentCount <= zoDailyLimit);

             
            zoCreated[i] += currentCount;
        }

         
        require(count > 0);

         
        require(msg.value >= count * zoPrice);

         
        assets[msg.sender][0] = asset;

         
        accountsBoughtZoAsset[msg.sender] = history;
        
         
        emit BuyZeroOrderAsset(msg.sender, values);

    }

     
    function clearZoDailyLimit() external onlyCOO {
        uint256 nextDay = zoLastRefreshTime + 1 days;
        if (now > nextDay) {
            zoLastRefreshTime = nextDay;
            for (uint256 i = 0; i < 4; i++) {
                zoCreated[i] =0;
            }
        }
    }
}


contract AlchemyMarket is AlchemyMinting {

     
    struct SaleOrder {
         
        uint64 assetId;
         
        uint64 amount;
         
        uint128 desiredPrice;
         
        address seller; 
    }

     
    uint128 public maxSaleNum = 20;

     
     
    uint256 public trCut = 275;

     
    uint256 public nextSaleId = 1;

     
    mapping (uint256 => SaleOrder) public saleOrderList;

     
    mapping (address => uint256) public accountToSaleNum;

     
    event PutOnSale(address account, uint256 saleId);
    event WithdrawSale(address account, uint256 saleId);
    event ChangeSale(address account, uint256 saleId);
    event BuyInMarket(address buyer, uint256 saleId, uint256 amount);
    event SaleClear(uint256 saleId);

     
    function setTrCut(uint256 newCut) public onlyCOO {
        trCut = newCut;
    }

     
    function putOnSale(uint256 assetId, uint256 amount, uint256 price) external whenNotPaused {
         
        require(accountToSaleNum[msg.sender] < maxSaleNum);

         
         
        require(assetId > 3 && assetId < 248);
        require(amount > 0 && amount < 256);

        uint256 assetFloor = assetId / 31;
        uint256 assetPos = assetId - 31 * assetFloor;
        bytes32 allAsset = assets[msg.sender][assetFloor];

        bytes32 mask = bytes32(255) << (8 * assetPos);  
        uint256 maskedValue;
        uint256 maskedResult;
        uint256 addAmount = amount << (8 * assetPos);

         
        maskedValue = uint256(allAsset & mask);
        require(addAmount <= maskedValue);

         
        maskedResult = maskedValue - addAmount;
        allAsset = ((allAsset ^ mask) & allAsset) | bytes32(maskedResult);

        assets[msg.sender][assetFloor] = allAsset;

         
        SaleOrder memory saleorder = SaleOrder(
            uint64(assetId),
            uint64(amount),
            uint128(price),
            msg.sender
        );

        saleOrderList[nextSaleId] = saleorder;
        nextSaleId += 1;

        accountToSaleNum[msg.sender] += 1;

         
        emit PutOnSale(msg.sender, nextSaleId-1);
    }
  
     
    function withdrawSale(uint256 saleId) external whenNotPaused {
         
        require(saleOrderList[saleId].seller == msg.sender);

        uint256 assetId = uint256(saleOrderList[saleId].assetId);
        uint256 assetFloor = assetId / 31;
        uint256 assetPos = assetId - 31 * assetFloor;
        bytes32 allAsset = assets[msg.sender][assetFloor];

        bytes32 mask = bytes32(255) << (8 * assetPos);  
        uint256 maskedValue;
        uint256 maskedResult;
        uint256 addAmount = uint256(saleOrderList[saleId].amount) << (8 * assetPos);

         
        maskedValue = uint256(allAsset & mask);
        require(addAmount + maskedValue < 2**(8 * (assetPos + 1)));

         
        maskedResult = maskedValue + addAmount;
        allAsset = ((allAsset ^ mask) & allAsset) | bytes32(maskedResult);

        assets[msg.sender][assetFloor] = allAsset;

         
        delete saleOrderList[saleId];

        accountToSaleNum[msg.sender] -= 1;

         
        emit WithdrawSale(msg.sender, saleId);
    }
 
 
 
 
 
 
 
 
     
    function buyInMarket(uint256 saleId, uint256 amount) external payable whenNotPaused {
        address seller = saleOrderList[saleId].seller;
         
        require(seller != address(0));

         
        require(msg.sender != seller);

        require(saleOrderList[saleId].amount >= uint64(amount));

         
        require(msg.value / saleOrderList[saleId].desiredPrice >= amount);

        uint256 totalprice = amount * saleOrderList[saleId].desiredPrice;

        uint64 assetId = saleOrderList[saleId].assetId;

        uint256 assetFloor = assetId / 31;
        uint256 assetPos = assetId - 31 * assetFloor;
        bytes32 allAsset = assets[msg.sender][assetFloor];

        bytes32 mask = bytes32(255) << (8 * assetPos);  
        uint256 maskedValue;
        uint256 maskedResult;
        uint256 addAmount = amount << (8 * assetPos);

         
        maskedValue = uint256(allAsset & mask);
        require(addAmount + maskedValue < 2**(8 * (assetPos + 1)));

         
        maskedResult = maskedValue + addAmount;
        allAsset = ((allAsset ^ mask) & allAsset) | bytes32(maskedResult);

        assets[msg.sender][assetFloor] = allAsset;

        saleOrderList[saleId].amount -= uint64(amount);

         
        uint256 sellerProceeds = totalprice - _computeCut(totalprice);

        seller.transfer(sellerProceeds);

         
        emit BuyInMarket(msg.sender, saleId, amount);

         
        if (saleOrderList[saleId].amount == 0) {
            accountToSaleNum[seller] -= 1;
            delete saleOrderList[saleId];

             
            emit SaleClear(saleId);
        }
    }

     
    function _computeCut(uint256 _price) internal view returns (uint256) {
        return _price / 10000 * trCut;
    }
}


contract AlchemyMove is AlchemyMarket {

     
    bool public isMovingEnable = true;

     
    function disableMoving() external onlyCOO {
        isMovingEnable = false;
    }

     
    function moveAccountData(address[] accounts, bytes32[] _assets, uint256[] saleNums) external onlyCOO {
        require(isMovingEnable);

        uint256 j;
        address account;
        for (uint256 i = 0; i < accounts.length; i++) {
            account = accounts[i];
            for (j = 0; j < 8; j++) {
                assets[account][j] = _assets[j + 8*i];
            }

            accountToSaleNum[account] = saleNums[i];
        }
    }

    function moveFurnaceData(address[] accounts, uint16[] _pendingAssets, uint256[] cooldownTimes, bool[] furnaceState, uint256[] counts) external onlyCOO {
        require(isMovingEnable);

        Furnace memory _furnace;
        uint256 j;
        address account;
        for (uint256 i = 0; i < accounts.length; i++) {
            account = accounts[i];

            for (j = 0; j < 5; j++) {
                _furnace.pendingAssets[j] = _pendingAssets[j + 5*i];
            }
            _furnace.cooldownEndTime = cooldownTimes[i];
            _furnace.inSynthesization = furnaceState[i];
            _furnace.count = counts[i];

            accountsToFurnace[account] = _furnace;
        }
    }


    function movePatentData(uint16[] ids, address[] owners, uint256[] beginTimes, bool[] onsaleStates, uint256[] prices, uint256[] lastprices, uint256[] selltimes) external onlyCOO {
        require(isMovingEnable);
        
         
        uint16 id;
        for (uint256 i = 0; i < ids.length; i++) {
            id = ids[i];
             
            patents[id] = Patent({patentOwner: owners[i], beginTime: beginTimes[i], onSale: onsaleStates[i], price: prices[i], lastPrice: lastprices[i], sellTime: selltimes[i]});
        }
    }

    function moveMarketData(uint256[] saleIds, uint64[] assetIds, uint64[] amounts, uint128[] desiredPrices, address[] sellers) external onlyCOO {
        require(isMovingEnable);
        
        SaleOrder memory _saleOrder;
        uint256 _saleId;
        for (uint256 i = 0; i < saleIds.length; i++) {
            _saleId = saleIds[i];
            _saleOrder.assetId = assetIds[i];
            _saleOrder.amount = amounts[i];
            _saleOrder.desiredPrice = desiredPrices[i];
            _saleOrder.seller = sellers[i];
            saleOrderList[_saleId] = _saleOrder;
        }
    }

    function writeNextId(uint256 _id) external onlyCOO {
        require(isMovingEnable);
        nextSaleId = _id;
    }
}