pragma solidity ^0.4.18;

 
 
 
contract GameConfig {
  using SafeMath for SafeMath;
  address public owner;

   
  event newCard(uint256 cardId,uint256 baseCoinCost,uint256 coinCostIncreaseHalf,uint256 ethCost,uint256 baseCoinProduction);
  event newBattleCard(uint256 cardId,uint256 baseCoinCost,uint256 coinCostIncreaseHalf,uint256 ethCost,uint256 attackValue,uint256 defenseValue,uint256 coinStealingCapacity);
  event newUpgradeCard(uint256 upgradecardId, uint256 coinCost, uint256 ethCost, uint256 upgradeClass, uint256 cardId, uint256 upgradeValue, uint256 increase);
  
  struct Card {
    uint256 cardId;
    uint256 baseCoinCost;
    uint256 coinCostIncreaseHalf;  
    uint256 ethCost;
    uint256 baseCoinProduction;
    bool unitSellable;  
  }

  struct BattleCard {
    uint256 cardId;
    uint256 baseCoinCost;
    uint256 coinCostIncreaseHalf;  
    uint256 ethCost;
    uint256 attackValue;
    uint256 defenseValue;
    uint256 coinStealingCapacity;
    bool unitSellable;  
  }
  
  struct UpgradeCard {
    uint256 upgradecardId;
    uint256 coinCost;
    uint256 ethCost;
    uint256 upgradeClass;
    uint256 cardId;
    uint256 upgradeValue;
    uint256 increase;
  }
  
   
  mapping(uint256 => Card) private cardInfo;   
  mapping(uint256 => BattleCard) private battlecardInfo;   
  mapping(uint256 => UpgradeCard) private upgradeInfo;   
     
  uint256 public currNumOfCards;  
  uint256 public currNumOfBattleCards;  
  uint256 public currNumOfUpgrades; 

  uint256 public Max_CAP = 99;
  uint256 PLATPrice = 65000;
    
   
  function GameConfig() public {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  address allowed; 
  function setAllowedAddress(address _address) external onlyOwner {
    require(_address != address(0));
    allowed = _address;
  }
  modifier onlyAccess() {
    require(msg.sender == allowed || msg.sender == owner);
    _;
  }

  function setMaxCAP(uint256 iMax) external onlyOwner {
    Max_CAP = iMax;
  }
  function getMaxCAP() external view returns (uint256) {
    return Max_CAP;
  }
  function setPLATPrice(uint256 price) external onlyOwner {
    PLATPrice = price;
  }
  function getPLATPrice() external view returns (uint256) {
    return PLATPrice;
  }

  function CreateBattleCards(uint256 _cardId, uint256 _baseCoinCost, uint256 _coinCostIncreaseHalf, uint256 _ethCost, uint _attackValue, uint256 _defenseValue, uint256 _coinStealingCapacity, bool _unitSellable) external onlyAccess {
    BattleCard memory _battlecard = BattleCard({
      cardId: _cardId,
      baseCoinCost: _baseCoinCost,
      coinCostIncreaseHalf: _coinCostIncreaseHalf,
      ethCost: _ethCost,
      attackValue: _attackValue,
      defenseValue: _defenseValue,
      coinStealingCapacity: _coinStealingCapacity,
      unitSellable: _unitSellable
    });
    battlecardInfo[_cardId] = _battlecard;
    currNumOfBattleCards = SafeMath.add(currNumOfBattleCards,1);
    newBattleCard(_cardId,_baseCoinCost,_coinCostIncreaseHalf,_ethCost,_attackValue,_defenseValue,_coinStealingCapacity);
    
  }

  function CreateCards(uint256 _cardId, uint256 _baseCoinCost, uint256 _coinCostIncreaseHalf, uint256 _ethCost, uint256 _baseCoinProduction, bool _unitSellable) external onlyAccess {
    Card memory _card = Card({
      cardId: _cardId,
      baseCoinCost: _baseCoinCost,
      coinCostIncreaseHalf: _coinCostIncreaseHalf,
      ethCost: _ethCost,
      baseCoinProduction: _baseCoinProduction,
      unitSellable: _unitSellable
    });
    cardInfo[_cardId] = _card;
    currNumOfCards = SafeMath.add(currNumOfCards,1);
    newCard(_cardId,_baseCoinCost,_coinCostIncreaseHalf,_ethCost,_baseCoinProduction);
  }

  function CreateUpgradeCards(uint256 _upgradecardId, uint256 _coinCost, uint256 _ethCost, uint256 _upgradeClass, uint256 _cardId, uint256 _upgradeValue, uint256 _increase) external onlyAccess {
    UpgradeCard memory _upgradecard = UpgradeCard({
      upgradecardId: _upgradecardId,
      coinCost: _coinCost,
      ethCost: _ethCost,
      upgradeClass: _upgradeClass,
      cardId: _cardId,
      upgradeValue: _upgradeValue,
      increase: _increase
    });
    upgradeInfo[_upgradecardId] = _upgradecard;
    currNumOfUpgrades = SafeMath.add(currNumOfUpgrades,1);
    newUpgradeCard(_upgradecardId,_coinCost,_ethCost,_upgradeClass,_cardId,_upgradeValue,_increase); 
  }

  function getCostForCards(uint256 cardId, uint256 existing, uint256 amount) public constant returns (uint256) {
    uint256 icount = existing;
    if (amount == 1) { 
      if (existing == 0) {  
        return cardInfo[cardId].baseCoinCost; 
      } else {
        return cardInfo[cardId].baseCoinCost + (existing * cardInfo[cardId].coinCostIncreaseHalf * 2);
            }
    } else if (amount > 1) { 
      uint256 existingCost;
      if (existing > 0) {
        existingCost = (cardInfo[cardId].baseCoinCost * existing) + (existing * (existing - 1) * cardInfo[cardId].coinCostIncreaseHalf);
      }
      icount = SafeMath.add(existing,amount);  
      uint256 newCost = SafeMath.add(SafeMath.mul(cardInfo[cardId].baseCoinCost, icount), SafeMath.mul(SafeMath.mul(icount, (icount - 1)), cardInfo[cardId].coinCostIncreaseHalf));
      return newCost - existingCost;
      }
  }

  function getCostForBattleCards(uint256 cardId, uint256 existing, uint256 amount) public constant returns (uint256) {
    uint256 icount = existing;
    if (amount == 1) { 
      if (existing == 0) {  
        return battlecardInfo[cardId].baseCoinCost; 
      } else {
        return battlecardInfo[cardId].baseCoinCost + (existing * battlecardInfo[cardId].coinCostIncreaseHalf * 2);
            }
    } else if (amount > 1) {
      uint256 existingCost;
      if (existing > 0) {
        existingCost = (battlecardInfo[cardId].baseCoinCost * existing) + (existing * (existing - 1) * battlecardInfo[cardId].coinCostIncreaseHalf);
      }
      icount = SafeMath.add(existing,amount);  
      uint256 newCost = SafeMath.add(SafeMath.mul(battlecardInfo[cardId].baseCoinCost, icount), SafeMath.mul(SafeMath.mul(icount, (icount - 1)), battlecardInfo[cardId].coinCostIncreaseHalf));
      return newCost - existingCost;
    }
  }

  function getCostForUprade(uint256 cardId, uint256 existing, uint256 amount) public constant returns (uint256) {
    if (amount == 1) { 
      if (existing == 0) {  
        return upgradeInfo[cardId].coinCost; 
      } else {
        return upgradeInfo[cardId].coinCost + (existing * upgradeInfo[cardId].increase * 2);
      }
    } 
  }

  function getWeakenedDefensePower(uint256 defendingPower) external pure returns (uint256) {
    return SafeMath.div(defendingPower,2);
  }
 
     
  function unitEthCost(uint256 cardId) external constant returns (uint256) {
    return cardInfo[cardId].ethCost;
  }

     
  function unitBattleEthCost(uint256 cardId) external constant returns (uint256) {
    return battlecardInfo[cardId].ethCost;
  }
   
  function unitBattlePLATCost(uint256 cardId) external constant returns (uint256) {
    return SafeMath.mul(battlecardInfo[cardId].ethCost,PLATPrice);
  }

     
  function unitPLATCost(uint256 cardId) external constant returns (uint256) {
    return SafeMath.mul(cardInfo[cardId].ethCost,PLATPrice);
  }

  function unitCoinProduction(uint256 cardId) external constant returns (uint256) {
    return cardInfo[cardId].baseCoinProduction;
  }

  function unitAttack(uint256 cardId) external constant returns (uint256) {
    return battlecardInfo[cardId].attackValue;
  }
    
  function unitDefense(uint256 cardId) external constant returns (uint256) {
    return battlecardInfo[cardId].defenseValue;
  }

  function unitStealingCapacity(uint256 cardId) external constant returns (uint256) {
    return battlecardInfo[cardId].coinStealingCapacity;
  }
  
  function productionCardIdRange() external constant returns (uint256, uint256) {
    return (1, currNumOfCards);
  }

  function battleCardIdRange() external constant returns (uint256, uint256) {
    uint256 battleMax = SafeMath.add(39,currNumOfBattleCards);
    return (40, battleMax);
  }

  function upgradeIdRange() external constant returns (uint256, uint256) {
    return (1, currNumOfUpgrades);
  }
 
   
  function getCardsInfo(uint256 cardId) external constant returns (
    uint256 baseCoinCost,
    uint256 coinCostIncreaseHalf,
    uint256 ethCost, 
    uint256 baseCoinProduction,
    uint256 platCost, 
    bool  unitSellable
  ) {
    baseCoinCost = cardInfo[cardId].baseCoinCost;
    coinCostIncreaseHalf = cardInfo[cardId].coinCostIncreaseHalf;
    ethCost = cardInfo[cardId].ethCost;
    baseCoinProduction = cardInfo[cardId].baseCoinProduction;
    platCost = SafeMath.mul(ethCost,PLATPrice);
    unitSellable = cardInfo[cardId].unitSellable;
  }
   
  function getCardInfo(uint256 cardId, uint256 existing, uint256 amount) external constant returns (uint256, uint256, uint256, uint256, bool) {
    return (cardInfo[cardId].cardId, cardInfo[cardId].baseCoinProduction, getCostForCards(cardId, existing, amount), SafeMath.mul(cardInfo[cardId].ethCost, amount),cardInfo[cardId].unitSellable);
  }

    
  function getBattleCardInfo(uint256 cardId, uint256 existing, uint256 amount) external constant returns (uint256, uint256, uint256, bool) {
    return (battlecardInfo[cardId].cardId, getCostForBattleCards(cardId, existing, amount), SafeMath.mul(battlecardInfo[cardId].ethCost, amount),battlecardInfo[cardId].unitSellable);
  }

   
  function getBattleCardsInfo(uint256 cardId) external constant returns (
    uint256 baseCoinCost,
    uint256 coinCostIncreaseHalf,
    uint256 ethCost, 
    uint256 attackValue,
    uint256 defenseValue,
    uint256 coinStealingCapacity,
    uint256 platCost,
    bool  unitSellable
  ) {
    baseCoinCost = battlecardInfo[cardId].baseCoinCost;
    coinCostIncreaseHalf = battlecardInfo[cardId].coinCostIncreaseHalf;
    ethCost = battlecardInfo[cardId].ethCost;
    attackValue = battlecardInfo[cardId].attackValue;
    defenseValue = battlecardInfo[cardId].defenseValue;
    coinStealingCapacity = battlecardInfo[cardId].coinStealingCapacity;
    platCost = SafeMath.mul(ethCost,PLATPrice);
    unitSellable = battlecardInfo[cardId].unitSellable;
  }

   
  function getUpgradeCardsInfo(uint256 upgradecardId, uint256 existing) external constant returns (
    uint256 coinCost, 
    uint256 ethCost, 
    uint256 upgradeClass, 
    uint256 cardId, 
    uint256 upgradeValue,
    uint256 platCost
    ) {  
    coinCost = getCostForUprade(upgradecardId, existing, 1);
    ethCost = upgradeInfo[upgradecardId].ethCost * (100 + 10 * existing)/100;
    upgradeClass = upgradeInfo[upgradecardId].upgradeClass;
    cardId = upgradeInfo[upgradecardId].cardId;
    upgradeValue = upgradeInfo[upgradecardId].upgradeValue + existing;
    platCost = SafeMath.mul(ethCost,PLATPrice);
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