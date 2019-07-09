pragma solidity ^0.4.23;

 

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
     
     
     
    return a / b;
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


 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 public totalSupply_;
  
   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}


 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) public allowed;


   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

 
contract CoinnupToken is StandardToken, Ownable {
  using SafeMath for uint256;

  string public constant name = "Coinnup Coin";  
  string public constant symbol = "PMZ";  
  uint8 public constant decimals = 18;  

   
  mapping ( address => uint256 ) public investments;
   
  mapping ( address => uint256 ) public tokensBought;

   
  event investmentReceived(
    address sender,
    uint weis,
    uint total
  );

  uint256 public maxSupply = 298500000000000000000000000;
  uint256 public allowedToBeSold = 118056750000000000000000000;
  address public founder = address( 0x3abb86C7C1a533Eb0464E9BD870FD1b501C7A8A8 );
  uint256 public rate = 2800;
  uint256 public bonus = 30;
  uint256 public softCap = 1850000000000000000000;

  uint256 public _sold;  
   
   
  uint256 public _soldOutside;  
  uint256 public _soldOutsidePMZ;  

  bool public isPaused;

  struct Round {
    uint256 openingTime;
    uint256 closingTime;
    uint256 allocatedCoins;
    uint256 minPurchase;
    uint256 maxPurchase;
    uint256 soldCoins;
  }

  Round[] public rounds;

   
  constructor () public {
    require(maxSupply > 0);
    require(founder != address(0));
    require(rate > 0);
    require(bonus >= 0 && bonus <= 100);  
    require(allowedToBeSold > 0 && allowedToBeSold < maxSupply);

    require(softCap > 0);

    for (uint8 i = 0; i < 6; i++) {
      rounds.push( Round(0, 0, 0, 0, 0, 0) );
    }

     
    uint256 _forFounder = maxSupply.sub(allowedToBeSold);
    mint(founder, _forFounder);

     
     
    triggerICOState(true);
  }

   
  function () public onlyWhileOpen isNotPaused payable {
    require(_buyTokens(msg.sender, msg.value));
  }

   
  function _buyTokens(address _sender, uint256 _value) internal isNotPaused returns (bool) {
    uint256 amount = _getTokenAmount(_value, bonus);
    uint256 amount_without_bonus = _getTokenAmount(_value, 0);
    uint8 _currentRound = _getCurrentRound(now);

    require(rounds[_currentRound].allocatedCoins >= amount.add(rounds[_currentRound].soldCoins));
    require(totalSupply_.add(amount) <= maxSupply);  

    require(
      rounds[_currentRound].minPurchase <= amount_without_bonus &&
      rounds[_currentRound].maxPurchase >= amount_without_bonus
    );

    _sold = _sold.add(_value);  
    investments[_sender] = investments[_sender].add(_value);  

     
     
    mint(_sender, amount);
    rounds[_currentRound].soldCoins = rounds[_currentRound].soldCoins.add(amount);
    tokensBought[_sender] = tokensBought[_sender].add(amount);

    emit investmentReceived(
      _sender,
      _value,
      amount_without_bonus
    );

    return true;
  }

   
  function mintForInvestor(address _to, uint256 _tokens, uint256 _tokens_bonus) public onlyOwner onlyWhileOpen {
    uint8 _round = _getCurrentRound(now);
    uint256 _tokens_with_bonuses = _tokens.add(_tokens_bonus);

    require(_round >= 0 && _round <= 5);
    require(_to != address(0));  
    require(_tokens >= 0);  
    require(rounds[_round].allocatedCoins >= _tokens_with_bonuses.add(rounds[_round].soldCoins));
    require(maxSupply >= _tokens_with_bonuses.add(totalSupply_));
    require(_tokens > _tokens_bonus);
    
    require(
      rounds[_round].minPurchase <= _tokens &&  
      rounds[_round].maxPurchase >= _tokens
    );

     
    mint(_to, _tokens_with_bonuses);  
    rounds[_round].soldCoins = rounds[_round].soldCoins.add(_tokens_with_bonuses); 
    tokensBought[_to] = tokensBought[_to].add(_tokens_with_bonuses);  

    uint256 _soldInETH = _tokens.div( rate );  
    
    _sold = _sold.add(_soldInETH);  
    _soldOutside = _soldOutside.add(_soldInETH);  
    _soldOutsidePMZ = _soldOutsidePMZ.add(_tokens_with_bonuses);  
  }

   
  function mint(address _to, uint256 _amount) internal {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Transfer(address(this), _to, _amount);
  }

     
  function _getTokenAmount(uint256 _weiAmount, uint _bonus) internal view returns (uint256) {
    uint256 _coins_in_wei = rate.mul(_weiAmount);
    uint256 _bonus_value_in_wei = 0;
    uint256 bonusValue = 0;

    _bonus_value_in_wei = (_coins_in_wei.mul(_bonus)).div(100);
    bonusValue = _bonus_value_in_wei;

    uint256 coins = _coins_in_wei;
    uint256 total = coins.add(bonusValue);

    return total;
  }

   
  function setRate(uint256 _rate) public {
    require(msg.sender == owner);
    require(_rate > 0);

    rate = _rate;
  }

   
  function soldPerCurrentRound() public view returns (uint256) {
    return rounds[_getCurrentRound(now)].soldCoins;
  }

   
  function triggerICOState(bool state) public onlyOwner {
    isPaused = state;
  }

   
  function setBonus(uint256 _bonus) onlyOwner public {
    require(_bonus >= 0 && _bonus <= 100);  
    bonus = _bonus;
  }

   
  function _getCurrentRound(uint256 _time) public view returns (uint8) {
    for (uint8 i = 0; i < 6; i++) {
      if (rounds[i].openingTime < _time && rounds[i].closingTime > _time) {
        return i;
      }
    }

    return 100;  
  }

  function setRoundParams(
    uint8 _round,
    uint256 _openingTime,
    uint256 _closingTime,
    uint256 _maxPurchase,
    uint256 _minPurchase,
    uint256 _allocatedCoins
  ) public onlyOwner {
    rounds[_round].openingTime = _openingTime;
    rounds[_round].closingTime = _closingTime;
    rounds[_round].maxPurchase = _maxPurchase;
    rounds[_round].minPurchase = _minPurchase;
    rounds[_round].allocatedCoins = _allocatedCoins;
  }

   
  function withdraw() public {
     
    require(msg.sender == founder);
    founder.transfer(address(this).balance);
  }

   
  function refund() public whenICOFinished capNotReached {
    require(investments[msg.sender] > 0);
    msg.sender.transfer(investments[msg.sender]);
    investments[msg.sender] = 0;
  }

  modifier onlyWhileOpen {
    uint8 _round = _getCurrentRound(now);
    require(_round >= 0 && _round <= 5);  
    _;
  }

   
  modifier whenICOFinished {
    uint8 _round = _getCurrentRound(now);
    require(_round < 0 || _round > 5);  
    _;
  }

   
  modifier capNotReached {
    require(softCap > _sold);
    _;
  }

   
  modifier isNotPaused {
    require(!isPaused);
    _;
  }

}