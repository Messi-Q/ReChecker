pragma solidity ^0.4.18;
 
 

 
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
  function Ownable() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
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

interface CardsInterface {
    function getJadeProduction(address player) external constant returns (uint256);
    function getUpgradeValue(address player, uint256 upgradeClass, uint256 unitId, uint256 upgradeValue) external view returns (uint256);
    function getGameStarted() external constant returns (bool);
    function balanceOf(address player) external constant returns(uint256);
    function balanceOfUnclaimed(address player) external constant returns (uint256);
    function coinBalanceOf(address player,uint8 itype) external constant returns(uint256);

    function setCoinBalance(address player, uint256 eth, uint8 itype, bool iflag) external;
    function setJadeCoin(address player, uint256 coin, bool iflag) external;
    function setJadeCoinZero(address player) external;

    function setLastJadeSaveTime(address player) external;
    function setRoughSupply(uint256 iroughSupply) external;

    function updatePlayersCoinByPurchase(address player, uint256 purchaseCost) external;
    function updatePlayersCoinByOut(address player) external;

    function increasePlayersJadeProduction(address player, uint256 increase) external;
    function reducePlayersJadeProduction(address player, uint256 decrease) external;

    function getUintsOwnerCount(address _address) external view returns (uint256);
    function setUintsOwnerCount(address _address, uint256 amount, bool iflag) external;

    function getOwnedCount(address player, uint256 cardId) external view returns (uint256);
    function setOwnedCount(address player, uint256 cardId, uint256 amount, bool iflag) external;

    function getUpgradesOwned(address player, uint256 upgradeId) external view returns (uint256);
    function setUpgradesOwned(address player, uint256 upgradeId) external;
    
    function getTotalEtherPool(uint8 itype) external view returns (uint256);
    function setTotalEtherPool(uint256 inEth, uint8 itype, bool iflag) external;

    function setNextSnapshotTime(uint256 iTime) external;
    function getNextSnapshotTime() external view;

    function AddPlayers(address _address) external;
    function getTotalUsers()  external view returns (uint256);
    function getRanking() external view returns (address[] addr, uint256[] _arr);
    function getAttackRanking() external view returns (address[] addr, uint256[] _arr);

    function getUnitsProduction(address player, uint256 cardId, uint256 amount) external constant returns (uint256);

    function getUnitCoinProductionIncreases(address _address, uint256 cardId) external view returns (uint256);
    function setUnitCoinProductionIncreases(address _address, uint256 cardId, uint256 iValue,bool iflag) external;
     function getUnitCoinProductionMultiplier(address _address, uint256 cardId) external view returns (uint256);
    function setUnitCoinProductionMultiplier(address _address, uint256 cardId, uint256 iValue,bool iflag) external;
     function setUnitAttackIncreases(address _address, uint256 cardId, uint256 iValue,bool iflag) external;
    function setUnitAttackMultiplier(address _address, uint256 cardId, uint256 iValue,bool iflag) external;
    function setUnitDefenseIncreases(address _address, uint256 cardId, uint256 iValue,bool iflag) external;
    function setunitDefenseMultiplier(address _address, uint256 cardId, uint256 iValue,bool iflag) external;
    
    function setUnitJadeStealingIncreases(address _address, uint256 cardId, uint256 iValue,bool iflag) external;
    function setUnitJadeStealingMultiplier(address _address, uint256 cardId, uint256 iValue,bool iflag) external;

    function setUintCoinProduction(address _address, uint256 cardId, uint256 iValue,bool iflag) external;
    function getUintCoinProduction(address _address, uint256 cardId) external returns (uint256);

    function getUnitsInProduction(address player, uint256 unitId, uint256 amount) external constant returns (uint256);
    function getPlayersBattleStats(address player) public constant returns (
    uint256 attackingPower, 
    uint256 defendingPower, 
    uint256 stealingPower,
    uint256 battlePower); 
}

interface GameConfigInterface {
  function getMaxCAP() external returns (uint256);
  function unitCoinProduction(uint256 cardId) external constant returns (uint256);
  function unitPLATCost(uint256 cardId) external constant returns (uint256);
  function getCostForCards(uint256 cardId, uint256 existing, uint256 amount) external constant returns (uint256);
  function getCostForBattleCards(uint256 cardId, uint256 existing, uint256 amount) external constant returns (uint256);
  function unitBattlePLATCost(uint256 cardId) external constant returns (uint256);
  function getUpgradeCardsInfo(uint256 upgradecardId,uint256 existing) external constant returns (
    uint256 coinCost, 
    uint256 ethCost, 
    uint256 upgradeClass, 
    uint256 cardId, 
    uint256 upgradeValue,
    uint256 platCost
  );
 function getCardInfo(uint256 cardId, uint256 existing, uint256 amount) external constant returns (uint256, uint256, uint256, uint256, bool);
 function getBattleCardInfo(uint256 cardId, uint256 existing, uint256 amount) external constant returns (uint256, uint256, uint256, bool);
}
interface RareInterface {
  function getRareItemsOwner(uint256 rareId) external view returns (address);
  function getRareItemsPrice(uint256 rareId) external view returns (uint256);
  function getRareItemsPLATPrice(uint256 rareId) external view returns (uint256);
   function getRarePLATInfo(uint256 _tokenId) external view returns (
    uint256 sellingPrice,
    address owner,
    uint256 nextPrice,
    uint256 rareClass,
    uint256 cardId,
    uint256 rareValue
  );
  function transferToken(address _from, address _to, uint256 _tokenId) external;
  function setRarePrice(uint256 _rareId, uint256 _price) external;
}

contract BitGuildHelper is Ownable {
   
  CardsInterface public cards ;
  GameConfigInterface public schema;
  RareInterface public rare;

  function setCardsAddress(address _address) external onlyOwner {
    cards = CardsInterface(_address);
  }

    
  function setConfigAddress(address _address) external onlyOwner {
    schema = GameConfigInterface(_address);
  }

   
  function setRareAddress(address _address) external onlyOwner {
    rare = RareInterface(_address);
  }
  
 
  function upgradeUnitMultipliers(address player, uint256 upgradeClass, uint256 unitId, uint256 upgradeValue) internal {
    uint256 productionGain;
    if (upgradeClass == 0) {
      cards.setUnitCoinProductionIncreases(player, unitId, upgradeValue,true);
      productionGain = (cards.getOwnedCount(player,unitId) * upgradeValue * (10 + cards.getUnitCoinProductionMultiplier(player,unitId)));
      cards.setUintCoinProduction(player,unitId,productionGain,true); 
      cards.increasePlayersJadeProduction(player,productionGain);
    } else if (upgradeClass == 1) {
      cards.setUnitCoinProductionMultiplier(player,unitId,upgradeValue,true);
      productionGain = (cards.getOwnedCount(player,unitId) * upgradeValue * (schema.unitCoinProduction(unitId) + cards.getUnitCoinProductionIncreases(player,unitId)));
      cards.setUintCoinProduction(player,unitId,productionGain,true);
      cards.increasePlayersJadeProduction(player,productionGain);
    } else if (upgradeClass == 2) {
      cards.setUnitAttackIncreases(player,unitId,upgradeValue,true);
    } else if (upgradeClass == 3) {
      cards.setUnitAttackMultiplier(player,unitId,upgradeValue,true);
    } else if (upgradeClass == 4) {
      cards.setUnitDefenseIncreases(player,unitId,upgradeValue,true);
    } else if (upgradeClass == 5) {
      cards.setunitDefenseMultiplier(player,unitId,upgradeValue,true);
    } else if (upgradeClass == 6) {
      cards.setUnitJadeStealingIncreases(player,unitId,upgradeValue,true);
    } else if (upgradeClass == 7) {
      cards.setUnitJadeStealingMultiplier(player,unitId,upgradeValue,true);
    }
  }
   
  function removeUnitMultipliers(address player, uint256 upgradeClass, uint256 unitId, uint256 upgradeValue) internal {
    uint256 productionLoss;
    if (upgradeClass == 0) {
      cards.setUnitCoinProductionIncreases(player, unitId, upgradeValue,false);
      productionLoss = (cards.getOwnedCount(player,unitId) * upgradeValue * (10 + cards.getUnitCoinProductionMultiplier(player,unitId)));
      cards.setUintCoinProduction(player,unitId,productionLoss,false); 
      cards.reducePlayersJadeProduction(player, productionLoss);
    } else if (upgradeClass == 1) {
      cards.setUnitCoinProductionMultiplier(player,unitId,upgradeValue,false);
      productionLoss = (cards.getOwnedCount(player,unitId) * upgradeValue * (schema.unitCoinProduction(unitId) + cards.getUnitCoinProductionIncreases(player,unitId)));
      cards.setUintCoinProduction(player,unitId,productionLoss,false); 
      cards.reducePlayersJadeProduction(player, productionLoss);
    } else if (upgradeClass == 2) {
      cards.setUnitAttackIncreases(player,unitId,upgradeValue,false);
    } else if (upgradeClass == 3) {
      cards.setUnitAttackMultiplier(player,unitId,upgradeValue,false);
    } else if (upgradeClass == 4) {
      cards.setUnitDefenseIncreases(player,unitId,upgradeValue,false);
    } else if (upgradeClass == 5) {
      cards.setunitDefenseMultiplier(player,unitId,upgradeValue,false);
    } else if (upgradeClass == 6) { 
      cards.setUnitJadeStealingIncreases(player,unitId,upgradeValue,false);
    } else if (upgradeClass == 7) {
      cards.setUnitJadeStealingMultiplier(player,unitId,upgradeValue,false);
    }
  }
}

interface BitGuildTokenInterface {  
  function totalSupply() public constant returns (uint);
  function balanceOf(address tokenOwner) public constant returns (uint balance);
  function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);

  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
 
contract BitGuildTrade is BitGuildHelper {
  BitGuildTokenInterface public tokenContract;

  event UnitBought(address player, uint256 unitId, uint256 amount);
  event UpgradeCardBought(address player, uint256 upgradeId);
  event BuyRareCard(address player, address previous, uint256 rareId,uint256 iPrice);
  event UnitSold(address player, uint256 unitId, uint256 amount);

  mapping(address => mapping(uint256 => uint256)) unitsOwnedOfPLAT;  
  function() external payable {
    revert();
  }
  function setBitGuildToken(address _tokenContract) external {
    tokenContract = BitGuildTokenInterface(_tokenContract);
  } 

  function kill() public onlyOwner {
    tokenContract.transferFrom(this, msg.sender, tokenContract.balanceOf(this));
    selfdestruct(msg.sender);  
  }  
   
   
  function _getExtraParam(bytes _extraData) private pure returns(uint256 val1,uint256 val2,uint256 val3) {
    if (_extraData.length == 2) {
      val1 = uint256(_extraData[0]);
      val2 = uint256(_extraData[1]);
      val3 = 1; 
    } else if (_extraData.length == 3) {
      val1 = uint256(_extraData[0]);
      val2 = uint256(_extraData[1]);
      val3 = uint256(_extraData[2]);
    }
    
  }
  
  function receiveApproval(address _player, uint256 _value, address _tokenContractAddr, bytes _extraData) external {
    require(msg.sender == _tokenContractAddr);
    require(_extraData.length >=1);
    require(tokenContract.transferFrom(_player, address(this), _value));
    uint256 flag;
    uint256 unitId;
    uint256 amount;
    (flag,unitId,amount) = _getExtraParam(_extraData);

    if (flag==1) {
      buyPLATCards(_player, _value, unitId, amount);   
    } else if (flag==3) {
      buyUpgradeCard(_player, _value, unitId);   
    } else if (flag==4) {
      buyRareItem(_player, _value, unitId);  
    } 
  } 

  function buyPLATCards(address _player, uint256 _platValue, uint256 _cardId, uint256 _amount) internal {
    require(cards.getGameStarted());
    require(_amount>=1);
    uint256 existing = cards.getOwnedCount(_player,_cardId);
    require(existing < schema.getMaxCAP());    
    
    uint256 iAmount;
    if (SafeMath.add(existing, _amount) > schema.getMaxCAP()) {
      iAmount = SafeMath.sub(schema.getMaxCAP(),existing);
    } else {
      iAmount = _amount;
    }
    uint256 coinProduction;
    uint256 coinCost;
    uint256 ethCost;

    if (_cardId>=1 && _cardId<=39) {
      coinProduction = schema.unitCoinProduction(_cardId);
      coinCost = schema.getCostForCards(_cardId, existing, iAmount);
      ethCost = SafeMath.mul(schema.unitPLATCost(_cardId),iAmount);   
    } else if (_cardId>=40) {
      coinCost = schema.getCostForBattleCards(_cardId, existing, iAmount);
      ethCost = SafeMath.mul(schema.unitBattlePLATCost(_cardId),iAmount);   
    }
    require(ethCost>0);
    require(SafeMath.add(cards.coinBalanceOf(_player,1),_platValue) >= ethCost);
    require(cards.balanceOf(_player) >= coinCost);   

     
    cards.updatePlayersCoinByPurchase(_player, coinCost);

    if (ethCost > _platValue) {
      cards.setCoinBalance(_player,SafeMath.sub(ethCost,_platValue),1,false);
    } else if (_platValue > ethCost) {
       
      cards.setCoinBalance(_player,SafeMath.sub(_platValue,ethCost),1,true);
    } 

    uint256 devFund = uint256(SafeMath.div(ethCost,20));  
    cards.setTotalEtherPool(uint256(SafeMath.div(ethCost,4)),1,true);   
    cards.setCoinBalance(owner,devFund,1,true);  
    
    if (coinProduction > 0) {
      cards.increasePlayersJadeProduction(_player, cards.getUnitsProduction(_player, _cardId, iAmount)); 
      cards.setUintCoinProduction(_player,_cardId,cards.getUnitsProduction(_player, _cardId, iAmount),true); 
    }
    
    if (cards.getUintsOwnerCount(_player)<=0) {
      cards.AddPlayers(_player);
    }
    cards.setUintsOwnerCount(_player,iAmount, true);
    cards.setOwnedCount(_player,_cardId,iAmount,true);
    unitsOwnedOfPLAT[_player][_cardId] = SafeMath.add(unitsOwnedOfPLAT[_player][_cardId],iAmount);
     
    UnitBought(_player, _cardId, iAmount);
  }

   
  function buyUpgradeCard(address _player, uint256 _platValue,uint256 _upgradeId) internal {
    require(cards.getGameStarted());
    require(_upgradeId>=1);
    uint256 existing = cards.getUpgradesOwned(_player,_upgradeId);
    require(existing<=5);   
    uint256 coinCost;
    uint256 ethCost;
    uint256 upgradeClass;
    uint256 unitId;
    uint256 upgradeValue;
    uint256 platCost;
    (coinCost, ethCost, upgradeClass, unitId, upgradeValue,platCost) = schema.getUpgradeCardsInfo(_upgradeId,existing);

    require(platCost>0);
    if (platCost > 0) {
      require(SafeMath.add(cards.coinBalanceOf(_player,1),_platValue) >= platCost); 

      if (platCost > _platValue) {  
        cards.setCoinBalance(_player, SafeMath.sub(platCost,_platValue),1,false);
      } else if (platCost < _platValue) {  
        cards.setCoinBalance(_player,SafeMath.sub(_platValue,platCost),1,true);
    } 
      

       
      uint256 devFund = uint256(SafeMath.div(platCost, 20));  
      cards.setTotalEtherPool(SafeMath.sub(platCost,devFund),1,true);  
      cards.setCoinBalance(owner,devFund,1,true);  
    }
        
      
    require(cards.balanceOf(_player) >= coinCost);  
    cards.updatePlayersCoinByPurchase(_player, coinCost);
    
     
    upgradeUnitMultipliers(_player, upgradeClass, unitId, upgradeValue);  
    cards.setUpgradesOwned(_player,_upgradeId);  

      
    if (cards.getUintsOwnerCount(_player)<=0) {
      cards.AddPlayers(_player);
    }
 
    UpgradeCardBought(_player, _upgradeId);
  }

   
  function buyRareItem(address _player, uint256 _platValue,uint256 _rareId) internal {
    require(cards.getGameStarted());        
    address previousOwner = rare.getRareItemsOwner(_rareId);   
    require(previousOwner != 0);
    require(_player!=previousOwner);   
    
    uint256 ethCost = rare.getRareItemsPLATPrice(_rareId);  
    uint256 totalCost = SafeMath.add(cards.coinBalanceOf(_player,1),_platValue);
    require(totalCost >= ethCost); 
     
    cards.updatePlayersCoinByOut(_player);
    cards.updatePlayersCoinByOut(previousOwner);

    uint256 upgradeClass;
    uint256 unitId;
    uint256 upgradeValue;
    (,,,,upgradeClass, unitId, upgradeValue) = rare.getRarePLATInfo(_rareId);
    
     
    upgradeUnitMultipliers(_player, upgradeClass, unitId, upgradeValue); 
    removeUnitMultipliers(previousOwner, upgradeClass, unitId, upgradeValue); 

     
    if (ethCost > _platValue) {
      cards.setCoinBalance(_player,SafeMath.sub(ethCost,_platValue),1,false);
    } else if (_platValue > ethCost) {
       
      cards.setCoinBalance(_player,SafeMath.sub(_platValue,ethCost),1,true);
    }  
     
    uint256 devFund = uint256(SafeMath.div(ethCost, 20));  
    uint256 dividends = uint256(SafeMath.div(ethCost,20));  

    cards.setTotalEtherPool(dividends,1,true);   
    cards.setCoinBalance(owner,devFund,1,true);   
        
     
    rare.transferToken(previousOwner,_player,_rareId); 
    rare.setRarePrice(_rareId,SafeMath.div(SafeMath.mul(rare.getRareItemsPrice(_rareId),5),4));
    
    cards.setCoinBalance(previousOwner,SafeMath.sub(ethCost,SafeMath.add(dividends,devFund)),1,true);
    
    if (cards.getUintsOwnerCount(_player)<=0) {
      cards.AddPlayers(_player);
    }
   
    cards.setUintsOwnerCount(_player,1,true);
    cards.setUintsOwnerCount(previousOwner,1,true);

     
    BuyRareCard(_player, previousOwner, _rareId, ethCost);
  }

   
  function sellCards( uint256 _unitId, uint256 _amount) external {
    require(cards.getGameStarted());
    uint256 existing = cards.getOwnedCount(msg.sender,_unitId);
    require(existing >= _amount && _amount>0); 
    existing = SafeMath.sub(existing,_amount);
    uint256 coinChange;
    uint256 decreaseCoin;
    uint256 schemaUnitId;
    uint256 coinProduction;
    uint256 coinCost;
    uint256 ethCost;
    bool sellable;
    if (_unitId>=40) {  
      (schemaUnitId,coinCost,, sellable) = schema.getBattleCardInfo(_unitId, existing, _amount);
      ethCost = SafeMath.mul(schema.unitBattlePLATCost(_unitId),_amount);
    } else {
      (schemaUnitId, coinProduction, coinCost, , sellable) = schema.getCardInfo(_unitId, existing, _amount);
      ethCost = SafeMath.mul(schema.unitPLATCost(_unitId),_amount);  
    }
    require(sellable);   
    if (ethCost>0) {
      require(unitsOwnedOfPLAT[msg.sender][_unitId]>=_amount);
    }
    if (coinCost>0) {
      coinChange = SafeMath.add(cards.balanceOfUnclaimed(msg.sender), SafeMath.div(SafeMath.mul(coinCost,70),100));  
    } else {
      coinChange = cards.balanceOfUnclaimed(msg.sender); 
    }

    cards.setLastJadeSaveTime(msg.sender); 
    cards.setRoughSupply(coinChange);  
    cards.setJadeCoin(msg.sender, coinChange, true);  

    decreaseCoin = cards.getUnitsInProduction(msg.sender, _unitId, _amount);
  
    if (coinProduction > 0) { 
      cards.reducePlayersJadeProduction(msg.sender, decreaseCoin);
       
      cards.setUintCoinProduction(msg.sender,_unitId,decreaseCoin,false); 
    }

    if (ethCost > 0) {  
      cards.setCoinBalance(msg.sender,SafeMath.div(SafeMath.mul(ethCost,70),100),1,true);
    }

    cards.setOwnedCount(msg.sender,_unitId,_amount,false); 
    cards.setUintsOwnerCount(msg.sender,_amount,false);
    if (ethCost>0) {
      unitsOwnedOfPLAT[msg.sender][_unitId] = SafeMath.sub(unitsOwnedOfPLAT[msg.sender][_unitId],_amount);
    }
     
    UnitSold(msg.sender, _unitId, _amount);
  }

   
  function withdrawEtherFromTrade(uint256 amount) external {
    require(amount <= cards.coinBalanceOf(msg.sender,1));
    cards.setCoinBalance(msg.sender,amount,1,false);
    tokenContract.transfer(msg.sender,amount);
  } 

   
  function withdrawToken(uint256 amount) external onlyOwner {
    uint256 balance = tokenContract.balanceOf(this);
    require(balance > 0 && balance >= amount);
    cards.setCoinBalance(msg.sender,amount,1,false);
    tokenContract.transfer(msg.sender, amount);
  }

  function getCanSellUnit(address _address, uint256 unitId) external view returns (uint256) {
    return unitsOwnedOfPLAT[_address][unitId];
  }
}