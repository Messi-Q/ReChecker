pragma solidity ^0.4.2;

 

 
contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

 
contract StandardToken is Token {
    function transfer(address _to, uint256 _value) public returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

 
contract PXLProperty is StandardToken {
     
    uint8 constant LEVEL_1_MODERATOR = 1;     
    uint8 constant LEVEL_2_MODERATOR = 2;     
    uint8 constant LEVEL_1_ADMIN = 3;         
    uint8 constant LEVEL_2_ADMIN = 4;         
    uint8 constant LEVEL_1_ROOT = 5;          
    uint8 constant LEVEL_2_ROOT = 6;          
    uint8 constant LEVEL_3_ROOT = 7;          
    uint8 constant LEVEL_PROPERTY_DAPPS = 8;  
    uint8 constant LEVEL_PIXEL_PROPERTY = 9;  
     
    uint8 constant FLAG_NSFW = 1;
    uint8 constant FLAG_BAN = 2;
    
     
    address pixelPropertyContract;  
    mapping (address => uint8) public regulators;  
    
     
    mapping (uint16 => Property) public properties;
     
    mapping (address => uint256[2]) public ownerWebsite;
     
    mapping (address => uint256[2]) public ownerHoverText;
    
     
    struct Property {
        uint8 flag;
        bool isInPrivateMode;  
        address owner;  
        address lastUpdater;  
        uint256[5] colors;  
        uint256 salePrice;  
        uint256 lastUpdate;  
        uint256 becomePublic;  
        uint256 earnUntil;  
    }
    
     
    modifier regulatorAccess(uint8 accessLevel) {
        require(accessLevel <= LEVEL_3_ROOT);  
        require(regulators[msg.sender] >= accessLevel);  
        if (accessLevel >= LEVEL_1_ADMIN) {  
            require(regulators[msg.sender] <= LEVEL_3_ROOT);  
        }
        _;
    }
    
    modifier propertyDAppAccess() {
        require(regulators[msg.sender] == LEVEL_PROPERTY_DAPPS || regulators[msg.sender] == LEVEL_PIXEL_PROPERTY );
        _;
    }
    
    modifier pixelPropertyAccess() {
        require(regulators[msg.sender] == LEVEL_PIXEL_PROPERTY);
        _;
    }
    
     
    function PXLProperty() public {
        regulators[msg.sender] = LEVEL_3_ROOT;  
    }
    
     
     
    function setPropertyFlag(uint16 propertyID, uint8 flag) public regulatorAccess(flag == FLAG_NSFW ? LEVEL_1_MODERATOR : LEVEL_2_MODERATOR) {
        properties[propertyID].flag = flag;
        if (flag == FLAG_BAN) {
            require(properties[propertyID].isInPrivateMode);  
            properties[propertyID].colors = [0, 0, 0, 0, 0];
        }
    }
    
     
    function setRegulatorAccessLevel(address user, uint8 accessLevel) public regulatorAccess(LEVEL_1_ADMIN) {
        if (msg.sender != user) {
            require(regulators[msg.sender] > regulators[user]);  
        }
        require(regulators[msg.sender] > accessLevel);  
        regulators[user] = accessLevel;
    }
    
    function setPixelPropertyContract(address newPixelPropertyContract) public regulatorAccess(LEVEL_2_ROOT) {
        require(newPixelPropertyContract != 0);
        if (pixelPropertyContract != 0) {
            regulators[pixelPropertyContract] = 0;  
        }
        
        pixelPropertyContract = newPixelPropertyContract;
        regulators[newPixelPropertyContract] = LEVEL_PIXEL_PROPERTY;
    }
    
    function setPropertyDAppContract(address propertyDAppContract, bool giveAccess) public regulatorAccess(LEVEL_1_ROOT) {
        require(propertyDAppContract != 0);
        regulators[propertyDAppContract] = giveAccess ? LEVEL_PROPERTY_DAPPS : 0;
    }
    
     
    function setPropertyColors(uint16 propertyID, uint256[5] colors) public propertyDAppAccess() {
        for(uint256 i = 0; i < 5; i++) {
            if (properties[propertyID].colors[i] != colors[i]) {
                properties[propertyID].colors[i] = colors[i];
            }
        }
    }
    
    function setPropertyRowColor(uint16 propertyID, uint8 row, uint256 rowColor) public propertyDAppAccess() {
        if (properties[propertyID].colors[row] != rowColor) {
            properties[propertyID].colors[row] = rowColor;
        }
    }
    
    function setOwnerHoverText(address textOwner, uint256[2] hoverText) public propertyDAppAccess() {
        require (textOwner != 0);
        ownerHoverText[textOwner] = hoverText;
    }
    
    function setOwnerLink(address websiteOwner, uint256[2] website) public propertyDAppAccess() {
        require (websiteOwner != 0);
        ownerWebsite[websiteOwner] = website;
    }
    
     
    function setPropertyPrivateMode(uint16 propertyID, bool isInPrivateMode) public pixelPropertyAccess() {
        if (properties[propertyID].isInPrivateMode != isInPrivateMode) {
            properties[propertyID].isInPrivateMode = isInPrivateMode;
        }
    }
    
    function setPropertyOwner(uint16 propertyID, address propertyOwner) public pixelPropertyAccess() {
        if (properties[propertyID].owner != propertyOwner) {
            properties[propertyID].owner = propertyOwner;
        }
    }
    
    function setPropertyLastUpdater(uint16 propertyID, address lastUpdater) public pixelPropertyAccess() {
        if (properties[propertyID].lastUpdater != lastUpdater) {
            properties[propertyID].lastUpdater = lastUpdater;
        }
    }
    
    function setPropertySalePrice(uint16 propertyID, uint256 salePrice) public pixelPropertyAccess() {
        if (properties[propertyID].salePrice != salePrice) {
            properties[propertyID].salePrice = salePrice;
        }
    }
    
    function setPropertyLastUpdate(uint16 propertyID, uint256 lastUpdate) public pixelPropertyAccess() {
        properties[propertyID].lastUpdate = lastUpdate;
    }
    
    function setPropertyBecomePublic(uint16 propertyID, uint256 becomePublic) public pixelPropertyAccess() {
        properties[propertyID].becomePublic = becomePublic;
    }
    
    function setPropertyEarnUntil(uint16 propertyID, uint256 earnUntil) public pixelPropertyAccess() {
        properties[propertyID].earnUntil = earnUntil;
    }
    
    function setPropertyPrivateModeEarnUntilLastUpdateBecomePublic(uint16 propertyID, bool privateMode, uint256 earnUntil, uint256 lastUpdate, uint256 becomePublic) public pixelPropertyAccess() {
        if (properties[propertyID].isInPrivateMode != privateMode) {
            properties[propertyID].isInPrivateMode = privateMode;
        }
        properties[propertyID].earnUntil = earnUntil;
        properties[propertyID].lastUpdate = lastUpdate;
        properties[propertyID].becomePublic = becomePublic;
    }
    
    function setPropertyLastUpdaterLastUpdate(uint16 propertyID, address lastUpdater, uint256 lastUpdate) public pixelPropertyAccess() {
        if (properties[propertyID].lastUpdater != lastUpdater) {
            properties[propertyID].lastUpdater = lastUpdater;
        }
        properties[propertyID].lastUpdate = lastUpdate;
    }
    
    function setPropertyBecomePublicEarnUntil(uint16 propertyID, uint256 becomePublic, uint256 earnUntil) public pixelPropertyAccess() {
        properties[propertyID].becomePublic = becomePublic;
        properties[propertyID].earnUntil = earnUntil;
    }
    
    function setPropertyOwnerSalePricePrivateModeFlag(uint16 propertyID, address owner, uint256 salePrice, bool privateMode, uint8 flag) public pixelPropertyAccess() {
        if (properties[propertyID].owner != owner) {
            properties[propertyID].owner = owner;
        }
        if (properties[propertyID].salePrice != salePrice) {
            properties[propertyID].salePrice = salePrice;
        }
        if (properties[propertyID].isInPrivateMode != privateMode) {
            properties[propertyID].isInPrivateMode = privateMode;
        }
        if (properties[propertyID].flag != flag) {
            properties[propertyID].flag = flag;
        }
    }
    
    function setPropertyOwnerSalePrice(uint16 propertyID, address owner, uint256 salePrice) public pixelPropertyAccess() {
        if (properties[propertyID].owner != owner) {
            properties[propertyID].owner = owner;
        }
        if (properties[propertyID].salePrice != salePrice) {
            properties[propertyID].salePrice = salePrice;
        }
    }
    
     
    function rewardPXL(address rewardedUser, uint256 amount) public pixelPropertyAccess() {
        require(rewardedUser != 0);
        balances[rewardedUser] += amount;
        totalSupply += amount;
    }
    
    function burnPXL(address burningUser, uint256 amount) public pixelPropertyAccess() {
        require(burningUser != 0);
        require(balances[burningUser] >= amount);
        balances[burningUser] -= amount;
        totalSupply -= amount;
    }
    
    function burnPXLRewardPXL(address burner, uint256 toBurn, address rewarder, uint256 toReward) public pixelPropertyAccess() {
        require(balances[burner] >= toBurn);
        if (toBurn > 0) {
            balances[burner] -= toBurn;
            totalSupply -= toBurn;
        }
        if (rewarder != 0) {
            balances[rewarder] += toReward;
            totalSupply += toReward;
        }
    } 
    
    function burnPXLRewardPXLx2(address burner, uint256 toBurn, address rewarder1, uint256 toReward1, address rewarder2, uint256 toReward2) public pixelPropertyAccess() {
        require(balances[burner] >= toBurn);
        if (toBurn > 0) {
            balances[burner] -= toBurn;
            totalSupply -= toBurn;
        }
        if (rewarder1 != 0) {
            balances[rewarder1] += toReward1;
            totalSupply += toReward1;
        }
        if (rewarder2 != 0) {
            balances[rewarder2] += toReward2;
            totalSupply += toReward2;
        }
    } 
    
     
    function getOwnerHoverText(address user) public view returns(uint256[2]) {
        return ownerHoverText[user];
    }
    
    function getOwnerLink(address user) public view returns(uint256[2]) {
        return ownerWebsite[user];
    }
    
    function getPropertyFlag(uint16 propertyID) public view returns(uint8) {
        return properties[propertyID].flag;
    }
    
    function getPropertyPrivateMode(uint16 propertyID) public view returns(bool) {
        return properties[propertyID].isInPrivateMode;
    }
    
    function getPropertyOwner(uint16 propertyID) public view returns(address) {
        return properties[propertyID].owner;
    }
    
    function getPropertyLastUpdater(uint16 propertyID) public view returns(address) {
        return properties[propertyID].lastUpdater;
    }
    
    function getPropertyColors(uint16 propertyID) public view returns(uint256[5]) {
        return properties[propertyID].colors;
    }

    function getPropertyColorsOfRow(uint16 propertyID, uint8 rowIndex) public view returns(uint256) {
        require(rowIndex <= 9);
        return properties[propertyID].colors[rowIndex];
    }
    
    function getPropertySalePrice(uint16 propertyID) public view returns(uint256) {
        return properties[propertyID].salePrice;
    }
    
    function getPropertyLastUpdate(uint16 propertyID) public view returns(uint256) {
        return properties[propertyID].lastUpdate;
    }
    
    function getPropertyBecomePublic(uint16 propertyID) public view returns(uint256) {
        return properties[propertyID].becomePublic;
    }
    
    function getPropertyEarnUntil(uint16 propertyID) public view returns(uint256) {
        return properties[propertyID].earnUntil;
    }
    
    function getRegulatorLevel(address user) public view returns(uint8) {
        return regulators[user];
    }
    
     
    function getPropertyData(uint16 propertyID, uint256 systemSalePriceETH, uint256 systemSalePricePXL) public view returns(address, uint256, uint256, uint256, bool, uint256, uint8) {
        Property memory property = properties[propertyID];
        bool isInPrivateMode = property.isInPrivateMode;
         
        if (isInPrivateMode && property.becomePublic <= now) { 
            isInPrivateMode = false;
        }
        if (properties[propertyID].owner == 0) {
            return (0, systemSalePriceETH, systemSalePricePXL, property.lastUpdate, isInPrivateMode, property.becomePublic, property.flag);
        } else {
            return (property.owner, 0, property.salePrice, property.lastUpdate, isInPrivateMode, property.becomePublic, property.flag);
        }
    }
    
    function getPropertyPrivateModeBecomePublic(uint16 propertyID) public view returns (bool, uint256) {
        return (properties[propertyID].isInPrivateMode, properties[propertyID].becomePublic);
    }
    
    function getPropertyLastUpdaterBecomePublic(uint16 propertyID) public view returns (address, uint256) {
        return (properties[propertyID].lastUpdater, properties[propertyID].becomePublic);
    }
    
    function getPropertyOwnerSalePrice(uint16 propertyID) public view returns (address, uint256) {
        return (properties[propertyID].owner, properties[propertyID].salePrice);
    }
    
    function getPropertyPrivateModeLastUpdateEarnUntil(uint16 propertyID) public view returns (bool, uint256, uint256) {
        return (properties[propertyID].isInPrivateMode, properties[propertyID].lastUpdate, properties[propertyID].earnUntil);
    }
}

 
contract VirtualRealEstate {
     
     
    address owner;
    PXLProperty pxlProperty;
    
    bool initialPropertiesReserved;
    
    mapping (uint16 => bool) hasBeenSet;
    
     
    uint8 constant USER_BUY_CUT_PERCENT = 98;
     
    uint8 constant PROPERTY_GENERATES_PER_MINUTE = 1;
     
    uint256 GRACE_PERIOD_END_TIMESTAMP;
     
    uint256 constant PROPERTY_GENERATION_PAYOUT_INTERVAL = (1 minutes);  
    
    uint256 ownerEth = 0;  
    
     
    uint256 systemSalePriceETH;
    uint256 systemSalePricePXL;
    uint8 systemPixelIncreasePercent;
    uint8 systemPriceIncreaseStep;
    uint16 systemETHStepTally;
    uint16 systemPXLStepTally;
    uint16 systemETHStepCount;
    uint16 systemPXLStepCount;

     
    event PropertyColorUpdate(uint16 indexed property, uint256[5] colors, uint256 lastUpdate, address indexed lastUpdaterPayee, uint256 becomePublic, uint256 indexed rewardedCoins);
    event PropertyBought(uint16 indexed property, address indexed newOwner, uint256 ethAmount, uint256 PXLAmount, uint256 timestamp, address indexed oldOwner);
    event SetUserHoverText(address indexed user, uint256[2] newHoverText);
    event SetUserSetLink(address indexed user, uint256[2] newLink);
    event PropertySetForSale(uint16 indexed property, uint256 forSalePrice);
    event DelistProperty(uint16 indexed property);
    event SetPropertyPublic(uint16 indexed property);
    event SetPropertyPrivate(uint16 indexed property, uint32 numMinutesPrivate, address indexed rewardedUser, uint256 indexed rewardedCoins);
    event Bid(uint16 indexed property, uint256 bid, uint256 timestamp);
    
     

     
    modifier ownerOnly() {
        require(owner == msg.sender);
        _;
    }
    
     
    modifier validPropertyID(uint16 propertyID) {
        if (propertyID < 10000) {
            _;
        }
    }
    
     
    
     
    function VirtualRealEstate() public {
        owner = msg.sender;  
        systemSalePricePXL = 1000;  
        systemSalePriceETH = 19500000000000000;  
        systemPriceIncreaseStep = 10;
        systemPixelIncreasePercent = 5;
        systemETHStepTally = 0;
        systemPXLStepTally = 0;
        systemETHStepCount = 1;
        systemPXLStepCount = 1;
        initialPropertiesReserved = false;
    }
    
    function setPXLPropertyContract(address pxlPropertyContract) public ownerOnly() {
        pxlProperty = PXLProperty(pxlPropertyContract);
        if (!initialPropertiesReserved) {
            uint16 xReserved = 45;
            uint16 yReserved = 0;
            for(uint16 x = 0; x < 10; ++x) {
                uint16 propertyID = (yReserved) * 100 + (xReserved + x);
                _transferProperty(propertyID, owner, 0, 0, 0, 0);
            }
            initialPropertiesReserved = true;
            GRACE_PERIOD_END_TIMESTAMP = now + 3 days;  
        }
    }

    function getSaleInformation() public view ownerOnly() returns(uint8, uint8, uint16, uint16, uint16, uint16) {
        return (systemPixelIncreasePercent, systemPriceIncreaseStep, systemETHStepTally, systemPXLStepTally, systemETHStepCount, systemPXLStepCount);
    }
    
     
    
     
    function setHoverText(uint256[2] text) public {
        pxlProperty.setOwnerHoverText(msg.sender, text);
        SetUserHoverText(msg.sender, text);
    }
    
     
    function setLink(uint256[2] website) public {
        pxlProperty.setOwnerLink(msg.sender, website);
        SetUserSetLink(msg.sender, website);
    }
    
     
    function tryForcePublic(uint16 propertyID) public validPropertyID(propertyID) { 
        var (isInPrivateMode, becomePublic) = pxlProperty.getPropertyPrivateModeBecomePublic(propertyID);
        if (isInPrivateMode && becomePublic < now) {
            pxlProperty.setPropertyPrivateMode(propertyID, false);
        }
    }
    
     
    function setColors(uint16 propertyID, uint256[5] newColors, uint256 PXLToSpend) public validPropertyID(propertyID) returns(bool) {
        uint256 projectedPayout = getProjectedPayout(propertyID);
        if (_tryTriggerPayout(propertyID, PXLToSpend)) {
            pxlProperty.setPropertyColors(propertyID, newColors);
            var (lastUpdater, becomePublic) = pxlProperty.getPropertyLastUpdaterBecomePublic(propertyID);
            PropertyColorUpdate(propertyID, newColors, now, lastUpdater, becomePublic, projectedPayout);
             
            if (!hasBeenSet[propertyID]) {
                pxlProperty.rewardPXL(msg.sender, 25);
                hasBeenSet[propertyID] = true;
            }
            return true;
        }
        return false;
    }

     
    function setColorsX4(uint16[4] propertyIDs, uint256[20] newColors, uint256 PXLToSpendEach) public returns(bool[4]) {
        bool[4] results;
        for(uint256 i = 0; i < 4; i++) {
            require(propertyIDs[i] < 10000);
            results[i] = setColors(propertyIDs[i], [newColors[i * 5], newColors[i * 5 + 1], newColors[i * 5 + 2], newColors[i * 5 + 3], newColors[i * 5 + 4]], PXLToSpendEach);
        }
        return results;
    }

     
    function setColorsX8(uint16[8] propertyIDs, uint256[40] newColors, uint256 PXLToSpendEach) public returns(bool[8]) {
        bool[8] results;
        for(uint256 i = 0; i < 8; i++) {
            require(propertyIDs[i] < 10000);
            results[i] = setColors(propertyIDs[i], [newColors[i * 5], newColors[i * 5 + 1], newColors[i * 5 + 2], newColors[i * 5 + 3], newColors[i * 5 + 4]], PXLToSpendEach);
        }
        return results;
    }
    
     
    function setRowColors(uint16 propertyID, uint8 row, uint256 newColorData, uint256 PXLToSpend) public validPropertyID(propertyID) returns(bool) {
        require(row < 10);
        uint256 projectedPayout = getProjectedPayout(propertyID);
        if (_tryTriggerPayout(propertyID, PXLToSpend)) {
            pxlProperty.setPropertyRowColor(propertyID, row, newColorData);
            var (lastUpdater, becomePublic) = pxlProperty.getPropertyLastUpdaterBecomePublic(propertyID);
            PropertyColorUpdate(propertyID, pxlProperty.getPropertyColors(propertyID), now, lastUpdater, becomePublic, projectedPayout);
            return true;
        }
        return false;
    }
     
    function setPropertyMode(uint16 propertyID, bool setPrivateMode, uint32 numMinutesPrivate) public validPropertyID(propertyID) {
        var (propertyFlag, propertyIsInPrivateMode, propertyOwner, propertyLastUpdater, propertySalePrice, propertyLastUpdate, propertyBecomePublic, propertyEarnUntil) = pxlProperty.properties(propertyID);
        
        require(msg.sender == propertyOwner);
        uint256 whenToBecomePublic = 0;
        uint256 rewardedAmount = 0;
        
        if (setPrivateMode) {
             
            require(propertyIsInPrivateMode || propertyBecomePublic <= now || propertyLastUpdater == msg.sender ); 
            require(numMinutesPrivate > 0);
            require(pxlProperty.balanceOf(msg.sender) >= numMinutesPrivate);
             
            whenToBecomePublic = (now < propertyBecomePublic ? propertyBecomePublic : now) + PROPERTY_GENERATION_PAYOUT_INTERVAL * numMinutesPrivate;

            rewardedAmount = getProjectedPayout(propertyIsInPrivateMode, propertyLastUpdate, propertyEarnUntil);
            if (rewardedAmount > 0 && propertyLastUpdater != 0) {
                pxlProperty.burnPXLRewardPXLx2(msg.sender, numMinutesPrivate, propertyLastUpdater, rewardedAmount, msg.sender, rewardedAmount);
            } else {
                pxlProperty.burnPXL(msg.sender, numMinutesPrivate);
            }

        } else {
             
            if (propertyIsInPrivateMode && propertyBecomePublic > now) {
                pxlProperty.rewardPXL(msg.sender, ((propertyBecomePublic - now) / PROPERTY_GENERATION_PAYOUT_INTERVAL) - 1);
            }
        }
        
        pxlProperty.setPropertyPrivateModeEarnUntilLastUpdateBecomePublic(propertyID, setPrivateMode, 0, 0, whenToBecomePublic);
        
        if (setPrivateMode) {
            SetPropertyPrivate(propertyID, numMinutesPrivate, propertyLastUpdater, rewardedAmount);
        } else {
            SetPropertyPublic(propertyID);
        }
    }
     
    function transferProperty(uint16 propertyID, address newOwner) public validPropertyID(propertyID) returns(bool) {
        require(pxlProperty.getPropertyOwner(propertyID) == msg.sender);
        _transferProperty(propertyID, newOwner, 0, 0, pxlProperty.getPropertyFlag(propertyID), msg.sender);
        return true;
    }
     
    function buyProperty(uint16 propertyID, uint256 pxlValue) public validPropertyID(propertyID) payable returns(bool) {
         
        require(pxlProperty.getPropertyOwner(propertyID) == 0);
         
        require(pxlProperty.balanceOf(msg.sender) >= pxlValue);
        require(pxlValue != 0);
        
         
        require(pxlValue <= systemSalePricePXL);
        uint256 pxlLeft = systemSalePricePXL - pxlValue;
        uint256 ethLeft = systemSalePriceETH / systemSalePricePXL * pxlLeft;
        
         
        require(msg.value >= ethLeft);
        
        pxlProperty.burnPXLRewardPXL(msg.sender, pxlValue, owner, pxlValue);
        
        systemPXLStepTally += uint16(100 * pxlValue / systemSalePricePXL);
        if (systemPXLStepTally >= 1000) {
             systemPXLStepCount++;
            systemSalePricePXL += systemSalePricePXL * 9 / systemPXLStepCount / 10;
            systemPXLStepTally -= 1000;
        }
        
        ownerEth += msg.value;

        systemETHStepTally += uint16(100 * pxlLeft / systemSalePricePXL);
        if (systemETHStepTally >= 1000) {
            systemETHStepCount++;
            systemSalePriceETH += systemSalePriceETH * 9 / systemETHStepCount / 10;
            systemETHStepTally -= 1000;
        }

        _transferProperty(propertyID, msg.sender, msg.value, pxlValue, 0, 0);
        
        return true;
    }
     
    function buyPropertyInPXL(uint16 propertyID, uint256 PXLValue) public validPropertyID(propertyID) {
         
        var (propertyOwner, propertySalePrice) = pxlProperty.getPropertyOwnerSalePrice(propertyID);
        address originalOwner = propertyOwner;
        if (propertyOwner == 0) {
             
            pxlProperty.setPropertyOwnerSalePrice(propertyID, owner, systemSalePricePXL);
            propertyOwner = owner;
            propertySalePrice = systemSalePricePXL;
             
            systemPXLStepTally += 100;
            if (systemPXLStepTally >= 1000) {
                systemPXLStepCount++;
                systemSalePricePXL += systemSalePricePXL * 9 / systemPXLStepCount / 10;
                systemPXLStepTally -= 1000;
            }
        }
        require(propertySalePrice <= PXLValue);
        uint256 amountTransfered = propertySalePrice * USER_BUY_CUT_PERCENT / 100;
        pxlProperty.burnPXLRewardPXLx2(msg.sender, propertySalePrice, propertyOwner, amountTransfered, owner, (propertySalePrice - amountTransfered));        
        _transferProperty(propertyID, msg.sender, 0, propertySalePrice, 0, originalOwner);
    }

     
    function buyPropertyInETH(uint16 propertyID) public validPropertyID(propertyID) payable returns(bool) {
        require(pxlProperty.getPropertyOwner(propertyID) == 0);
        require(msg.value >= systemSalePriceETH);
        
        ownerEth += msg.value;
        systemETHStepTally += 100;
        if (systemETHStepTally >= 1000) {
            systemETHStepCount++;
            systemSalePriceETH += systemSalePriceETH * 9 / systemETHStepCount / 10;
            systemETHStepTally -= 1000;
        }
        _transferProperty(propertyID, msg.sender, msg.value, 0, 0, 0);
        return true;
    }
    
     
    function listForSale(uint16 propertyID, uint256 price) public validPropertyID(propertyID) returns(bool) {
        require(price != 0);
        require(msg.sender == pxlProperty.getPropertyOwner(propertyID));
        pxlProperty.setPropertySalePrice(propertyID, price);
        PropertySetForSale(propertyID, price);
        return true;
    }
    
     
    function delist(uint16 propertyID) public validPropertyID(propertyID) returns(bool) {
        require(msg.sender == pxlProperty.getPropertyOwner(propertyID));
        pxlProperty.setPropertySalePrice(propertyID, 0);
        DelistProperty(propertyID);
        return true;
    }

     
    function makeBid(uint16 propertyID, uint256 bidAmount) public validPropertyID(propertyID) {
        require(bidAmount > 0);
        require(pxlProperty.balanceOf(msg.sender) >= 1 + bidAmount);
        Bid(propertyID, bidAmount, now);
        pxlProperty.burnPXL(msg.sender, 1);
    }
    
     
    
     
    function withdraw(uint256 amount) public ownerOnly() {
        if (amount <= ownerEth) {
            owner.transfer(amount);
            ownerEth -= amount;
        }
    }
    
     
    function withdrawAll() public ownerOnly() {
        owner.transfer(ownerEth);
        ownerEth = 0;
    }
    
     
    function changeOwners(address newOwner) public ownerOnly() {
        owner = newOwner;
    }
    
     
    
     
    function _tryTriggerPayout(uint16 propertyID, uint256 pxlToSpend) private returns(bool) {
        var (propertyFlag, propertyIsInPrivateMode, propertyOwner, propertyLastUpdater, propertySalePrice, propertyLastUpdate, propertyBecomePublic, propertyEarnUntil) = pxlProperty.properties(propertyID);
         
        if (propertyIsInPrivateMode && propertyBecomePublic <= now) {
            pxlProperty.setPropertyPrivateMode(propertyID, false);
            propertyIsInPrivateMode = false;
        }
         
        if (propertyIsInPrivateMode) {
            require(msg.sender == propertyOwner);
            require(propertyFlag != 2);
         
        } else if (propertyBecomePublic <= now || propertyLastUpdater == msg.sender) {
            uint256 pxlSpent = pxlToSpend + 1;  
            if (isInGracePeriod() && pxlToSpend < 2) {  
                pxlSpent = 3;  
            }
            
            uint256 projectedAmount = getProjectedPayout(propertyIsInPrivateMode, propertyLastUpdate, propertyEarnUntil);
            pxlProperty.burnPXLRewardPXLx2(msg.sender, pxlToSpend, propertyLastUpdater, projectedAmount, propertyOwner, projectedAmount);
            
             
             
            pxlProperty.setPropertyBecomePublicEarnUntil(propertyID, now + (pxlSpent * PROPERTY_GENERATION_PAYOUT_INTERVAL / 2), now + (pxlSpent * 5 * PROPERTY_GENERATION_PAYOUT_INTERVAL));
        } else {
            return false;
        }
        pxlProperty.setPropertyLastUpdaterLastUpdate(propertyID, msg.sender, now);
        return true;
    }
     
    function _transferProperty(uint16 propertyID, address newOwner, uint256 ethAmount, uint256 PXLAmount, uint8 flag, address oldOwner) private {
        require(newOwner != 0);
        pxlProperty.setPropertyOwnerSalePricePrivateModeFlag(propertyID, newOwner, 0, false, flag);
        PropertyBought(propertyID, newOwner, ethAmount, PXLAmount, now, oldOwner);
    }
    
     
    function getPropertyData(uint16 propertyID) public validPropertyID(propertyID) view returns(address, uint256, uint256, uint256, bool, uint256, uint32) {
        return pxlProperty.getPropertyData(propertyID, systemSalePriceETH, systemSalePricePXL);
    }
    
     
    function getSystemSalePrices() public view returns(uint256, uint256) {
        return (systemSalePriceETH, systemSalePricePXL);
    }
    
     
    function getForSalePrices(uint16 propertyID) public validPropertyID(propertyID) view returns(uint256, uint256) {
        if (pxlProperty.getPropertyOwner(propertyID) == 0) {
            return getSystemSalePrices();
        } else {
            return (0, pxlProperty.getPropertySalePrice(propertyID));
        }
    }
    
     
    function getProjectedPayout(uint16 propertyID) public view returns(uint256) {
        var (propertyIsInPrivateMode, propertyLastUpdate, propertyEarnUntil) = pxlProperty.getPropertyPrivateModeLastUpdateEarnUntil(propertyID);
        return getProjectedPayout(propertyIsInPrivateMode, propertyLastUpdate, propertyEarnUntil);
    }
    
    function getProjectedPayout(bool propertyIsInPrivateMode, uint256 propertyLastUpdate, uint256 propertyEarnUntil) public view returns(uint256) {
        if (!propertyIsInPrivateMode && propertyLastUpdate != 0) {
            uint256 earnedUntil = (now < propertyEarnUntil) ? now : propertyEarnUntil;
            uint256 minutesSinceLastColourChange = (earnedUntil - propertyLastUpdate) / PROPERTY_GENERATION_PAYOUT_INTERVAL;
            return minutesSinceLastColourChange * PROPERTY_GENERATES_PER_MINUTE;
             
        }
        return 0;
    }
    
     
    function isInGracePeriod() public view returns(bool) {
        return now <= GRACE_PERIOD_END_TIMESTAMP;
    }
}