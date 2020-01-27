pragma solidity ^0.4.18;

// BOMBS!

contract Bombs {
  struct Bomb {
    address owner;
    uint8 bumps;
    
    uint8 chance;
    uint8 increase;
    
    uint256 price;
    uint256 last_price;
    uint256 base_price;
    uint256 pot;
    
    uint256 last_pot;
    address last_winner;
    uint8 last_bumps;
    address made_explode;
  }
  mapping (uint8 => Bomb) public bombs;
  uint256 start_price = 1000000000000000;

  address public ceoAddress;
  modifier onlyCEO() { require(msg.sender == ceoAddress); _; }

  function Bombs() public {
    ceoAddress = msg.sender;
    bombs[0] = Bomb(msg.sender, 0, 3, 110, start_price, 0, start_price, 0, 0, address(0), 0, address(0));
    bombs[1] = Bomb(msg.sender, 0, 80, 111, start_price, 0, start_price, 0, 0, address(0), 0, address(0));
    bombs[2] = Bomb(msg.sender, 0, 50, 122, start_price, 0, start_price, 0, 0, address(0), 0, address(0));
    bombs[3] = Bomb(msg.sender, 0, 25, 133, start_price, 0, start_price, 0, 0, address(0), 0, address(0));
  }
  
  function getBomb(uint8 _id) public view returns (
    uint8 id,
    address owner,
    uint8 bumps,
    uint8 chance,
    uint8 increase,
    uint256 price,
    uint256 last_price,
    uint256 base_price,
    uint256 pot,
    uint256 last_pot,
    address last_winner,
    uint8 last_bumps,
    address made_explode
  ) {
    id = _id;
    owner = bombs[_id].owner;
    bumps = bombs[_id].bumps;
    chance = bombs[_id].chance;
    increase = bombs[_id].increase;
    price = bombs[_id].price;
    last_price = bombs[_id].last_price;
    base_price = bombs[_id].base_price;
    pot = bombs[_id].pot;
    last_pot = bombs[_id].last_pot;
    last_winner = bombs[_id].last_winner;
    last_bumps = bombs[_id].last_bumps;
    made_explode = bombs[_id].made_explode;
  }

  function getRandom(uint _max) public view returns (uint random){
    random = uint(keccak256(block.blockhash(block.number-1),msg.gas,tx.gasprice,block.timestamp))%_max + 1;
  }

  function buy(uint8 _bomb) public payable {
    require(msg.sender != address(0));
    Bomb storage bomb = bombs[_bomb];
    require(msg.value >= bomb.price);

    uint256 excess = SafeMath.sub(msg.value, bomb.price);
    uint256 diff = SafeMath.sub(bomb.price, bomb.last_price);
    
    uint _random = uint(keccak256(block.blockhash(block.number-1),msg.gas,tx.gasprice,block.timestamp))%bomb.chance + 1;
    
    if(_random == 1){
      bomb.owner.transfer(SafeMath.add(bomb.last_price, SafeMath.add(bomb.pot, SafeMath.mul(SafeMath.div(diff, 100), 50))));
      ceoAddress.transfer(SafeMath.mul(SafeMath.div(diff, 100), 50));

      bomb.last_winner = bomb.owner;
      bomb.last_pot = bomb.pot;
      bomb.last_bumps = bomb.bumps;
      bomb.made_explode = msg.sender;
      
      bomb.price = bomb.base_price;
      bomb.owner = ceoAddress;
      bomb.pot = 0;
      bomb.bumps = 0;
      
    } else {
      bomb.owner.transfer(SafeMath.mul(SafeMath.div(diff, 100), 20));
      bomb.owner.transfer(bomb.last_price);
      if(bomb.made_explode == address(0)){
        ceoAddress.transfer(SafeMath.mul(SafeMath.div(diff, 100), 30)); 
      } else {
        ceoAddress.transfer(SafeMath.mul(SafeMath.div(diff, 100), 25));
        bomb.made_explode.transfer(SafeMath.mul(SafeMath.div(diff, 100), 5));
      }
      bomb.pot += SafeMath.mul(SafeMath.div(diff, 100), 50);
      bomb.owner = msg.sender;
    
      bomb.last_price = bomb.price;
      bomb.price = SafeMath.mul(SafeMath.div(bomb.price, 100), bomb.increase);
      bomb.bumps += 1;

      msg.sender.transfer(excess);
    }
  }
  
  function addBomb(uint8 __id, uint256 __price, uint8 __chance, uint8 __increase) public onlyCEO {
    bombs[__id] = Bomb(msg.sender, 0, __chance, __increase, __price, 0, __price, 0, 0, address(0), 0, address(0));
  }

  function payout() public onlyCEO {
    ceoAddress.transfer(this.balance);
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