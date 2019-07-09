 
pragma solidity ^0.4.21;

 

 
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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

 

 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
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

 

contract ICOStartSale is Pausable {
  using SafeMath for uint256;

  struct Period {
    uint256 startTimestamp;
    uint256 endTimestamp;
    uint256 rate;
  }

  Period[] private periods;
  mapping(address => bool) public whitelistedAddresses;
  mapping(address => uint256) public whitelistedRates;

  ERC20 public token;
  address public wallet;
  address public tokenWallet;
  uint256 public weiRaised;

   
  event TokensPurchased(address indexed _purchaser, uint256 _value, uint256 _amount);

  uint256 constant public MINIMUM_AMOUNT = 0.05 ether;
  uint256 constant public MAXIMUM_NON_WHITELIST_AMOUNT = 5 ether;

   
  function ICOStartSale(address _wallet, ERC20 _token, address _tokenWallet) public {
    require(_wallet != address(0));
    require(_token != address(0));
    require(_tokenWallet != address(0));

    wallet = _wallet;
    token = _token;
    tokenWallet = _tokenWallet;
  }

   
  function () external payable {
     
    require(msg.sender != address(0));
    require(msg.value >= MINIMUM_AMOUNT);
    require(isOpen());
    if (msg.value > MAXIMUM_NON_WHITELIST_AMOUNT) {
      require(isAddressInWhitelist(msg.sender));
    }

    uint256 tokenAmount = getTokenAmount(msg.sender, msg.value);
    weiRaised = weiRaised.add(msg.value);

    token.transferFrom(tokenWallet, msg.sender, tokenAmount);
    emit TokensPurchased(msg.sender, msg.value, tokenAmount);

    wallet.transfer(msg.value);
  }

   
  function addPeriod(uint256 _startTimestamp, uint256 _endTimestamp, uint256 _rate) onlyOwner public {
    require(_startTimestamp != 0);
    require(_endTimestamp > _startTimestamp);
    require(_rate != 0);
    Period memory period = Period(_startTimestamp, _endTimestamp, _rate);
    periods.push(period);
  }

   
  function clearPeriods() onlyOwner public {
    delete periods;
  }

   
  function addAddressToWhitelist(address _address, uint256 _rate) onlyOwner public returns (bool success) {
    require(_address != address(0));
    success = false;
    if (!whitelistedAddresses[_address]) {
      whitelistedAddresses[_address] = true;
      success = true;
    }
    if (_rate != 0) {
      whitelistedRates[_address] = _rate;
    }
  }

   
  function addAddressesToWhitelist(address[] _addresses, uint256 _rate) onlyOwner public returns (bool success) {
    success = false;
    for (uint256 i = 0; i <_addresses.length; i++) {
      if (addAddressToWhitelist(_addresses[i], _rate)) {
        success = true;
      }
    }
  }

   
  function removeAddressFromWhitelist(address _address) onlyOwner public returns (bool success) {
    require(_address != address(0));
    success = false;
    if (whitelistedAddresses[_address]) {
      whitelistedAddresses[_address] = false;
      success = true;
    }
    if (whitelistedRates[_address] != 0) {
      whitelistedRates[_address] = 0;
    }
  }

   
  function removeAddressesFromWhitelist(address[] _addresses) onlyOwner public returns (bool success) {
    success = false;
    for (uint256 i = 0; i < _addresses.length; i++) {
      if (removeAddressFromWhitelist(_addresses[i])) {
        success = true;
      }
    }
  }

   
  function isAddressInWhitelist(address _address) view public returns (bool) {
    return whitelistedAddresses[_address];
  }

   
  function isOpen() view public returns (bool) {
    return ((!paused) && (_getCurrentPeriod().rate != 0));
  }

   
  function getCurrentRate(address _purchaser) public view returns (uint256 rate) {
    Period memory currentPeriod = _getCurrentPeriod();
    require(currentPeriod.rate != 0);
    rate = whitelistedRates[_purchaser];
    if (rate == 0) {
      rate = currentPeriod.rate;
    }
  }

   
  function getTokenAmount(address _purchaser, uint256 _weiAmount) public view returns (uint256) {
    return _weiAmount.mul(getCurrentRate(_purchaser));
  }

   
  function remainingTokens() public view returns (uint256) {
    return token.allowance(tokenWallet, this);
  }

   

   
  function _getCurrentPeriod() view internal returns (Period memory _period) {
    _period = Period(0, 0, 0);
    uint256 len = periods.length;
    for (uint256 i = 0; i < len; i++) {
      if ((periods[i].startTimestamp <= block.timestamp) && (periods[i].endTimestamp >= block.timestamp)) {
        _period = periods[i];
        break;
      }
    }
  }

}