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

 
contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

   
  function RefundVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

   
  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(address(this).balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

   
  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}

 
contract LandSale is Ownable {
    using SafeMath for uint256;

    uint256 public openingTime;
    uint256 public closingTime;

    uint256 constant public VILLAGE_START_PRICE = 1200000000000000;  
    uint256 constant public TOWN_START_PRICE = 5000000000000000;  
    uint256 constant public CITY_START_PRICE = 20000000000000000;  

    uint256 constant public VILLAGE_INCREASE_RATE = 500000000000000;  
    uint256 constant public TOWN_INCREASE_RATE = 2500000000000000;  
    uint256 constant public CITY_INCREASE_RATE = 12500000000000000;  

     
    address public wallet;

     
    uint256 public weiRaised;

     
    uint256 public goal;

     
    RefundVault public vault;

     
    address[] public walletUsers;
    uint256 public walletUserCount;

     
    bytes32[] public ccUsers;
    uint256 public ccUserCount;

     
    uint256 public villagesSold;
    uint256 public townsSold;
    uint256 public citiesSold;


     
     
     
     

     
    mapping (address => uint256) public addressToNumVillages;
    mapping (address => uint256) public addressToNumTowns;
    mapping (address => uint256) public addressToNumCities;

     
    mapping (bytes32 => uint256) public userToNumVillages;
    mapping (bytes32 => uint256) public userToNumTowns;
    mapping (bytes32 => uint256) public userToNumCities;

    bool private paused = false;
    bool public isFinalized = false;

     
    event LandPurchased(address indexed purchaser, uint256 value, uint8 landType, uint256 quantity);
    event LandPurchasedCC(bytes32 indexed userId, address indexed purchaser, uint8 landType, uint256 quantity);
    event Finalized();

     
    modifier onlyWhileOpen {
        require(block.timestamp >= openingTime && block.timestamp <= closingTime && !paused);
        _;
    }

     
    function LandSale(address _wallet, uint256 _goal,
                        uint256 _openingTime, uint256 _closingTime) public {
        require(_wallet != address(0));
        require(_goal > 0);
        require(_openingTime >= block.timestamp);
        require(_closingTime >= _openingTime);

        wallet = _wallet;
        vault = new RefundVault(wallet);
        goal = _goal;
        openingTime = _openingTime;
        closingTime = _closingTime;
    }

     
    function addWalletAddress(address walletAddress) private {
        if ((addressToNumVillages[walletAddress] == 0) &&
            (addressToNumTowns[walletAddress] == 0) &&
            (addressToNumCities[walletAddress] == 0)) {
             
            walletUsers.push(msg.sender);
            walletUserCount++;
        }
    }

     
    function addCCUser(bytes32 user) private {
        if ((userToNumVillages[user] == 0) &&
            (userToNumTowns[user] == 0) &&
            (userToNumCities[user] == 0)) {
             
            ccUsers.push(user);
            ccUserCount++;
        }
    }

     
    function purchaseVillage(uint256 numVillages) payable public onlyWhileOpen {
        require(msg.value >= (villagePrice()*numVillages));
        require(numVillages > 0);

        weiRaised = weiRaised.add(msg.value);

        villagesSold = villagesSold.add(numVillages);
        addWalletAddress(msg.sender);
        addressToNumVillages[msg.sender] = addressToNumVillages[msg.sender].add(numVillages);

        _forwardFunds();
        LandPurchased(msg.sender, msg.value, 1, numVillages);
    }

     
    function purchaseTown(uint256 numTowns) payable public onlyWhileOpen {
        require(msg.value >= (townPrice()*numTowns));
        require(numTowns > 0);

        weiRaised = weiRaised.add(msg.value);

        townsSold = townsSold.add(numTowns);
        addWalletAddress(msg.sender);
        addressToNumTowns[msg.sender] = addressToNumTowns[msg.sender].add(numTowns);

        _forwardFunds();
        LandPurchased(msg.sender, msg.value, 2, numTowns);
    }

     
    function purchaseCity(uint256 numCities) payable public onlyWhileOpen {
        require(msg.value >= (cityPrice()*numCities));
        require(numCities > 0);

        weiRaised = weiRaised.add(msg.value);

        citiesSold = citiesSold.add(numCities);
        addWalletAddress(msg.sender);
        addressToNumCities[msg.sender] = addressToNumCities[msg.sender].add(numCities);

        _forwardFunds();
        LandPurchased(msg.sender, msg.value, 3, numCities);
    }

     
    function purchaseLandWithCC(uint8 landType, bytes32 userId, uint256 num) public onlyOwner onlyWhileOpen {
        require(landType <= 3);
        require(num > 0);

        addCCUser(userId);

        if (landType == 3) {
            weiRaised = weiRaised.add(cityPrice()*num);
            citiesSold = citiesSold.add(num);
            userToNumCities[userId] = userToNumCities[userId].add(num);
        } else if (landType == 2) {
            weiRaised = weiRaised.add(townPrice()*num);
            townsSold = townsSold.add(num);
            userToNumTowns[userId] = userToNumTowns[userId].add(num);
        } else if (landType == 1) {
            weiRaised = weiRaised.add(villagePrice()*num);
            villagesSold = villagesSold.add(num);
            userToNumVillages[userId] = userToNumVillages[userId].add(num);
        }

        LandPurchasedCC(userId, msg.sender, landType, num);
    }

     
    function villagePrice() view public returns(uint256) {
        return VILLAGE_START_PRICE.add((villagesSold.div(10).mul(VILLAGE_INCREASE_RATE)));
    }

     
    function townPrice() view public returns(uint256) {
        return TOWN_START_PRICE.add((townsSold.div(10).mul(TOWN_INCREASE_RATE)));
    }

     
    function cityPrice() view public returns(uint256) {
        return CITY_START_PRICE.add((citiesSold.div(10).mul(CITY_INCREASE_RATE)));
    }

     
    function pause() onlyOwner public {
        paused = true;
    }

     
    function resume() onlyOwner public {
        paused = false;
    }

     
    function isPaused () onlyOwner public view returns(bool) {
        return paused;
    }

     
    function hasClosed() public view returns (bool) {
        return block.timestamp > closingTime;
    }

     
    function claimRefund() public {
        require(isFinalized);
        require(!goalReached());

        vault.refund(msg.sender);
    }

     
    function goalReached() public view returns (bool) {
        return weiRaised >= goal;
    }

     
    function finalize() onlyOwner public {
        require(!isFinalized);
        require(hasClosed());

        if (goalReached()) {
          vault.close();
        } else {
          vault.enableRefunds();
        }

        Finalized();

        isFinalized = true;
    }

     
    function _forwardFunds() internal {
        vault.deposit.value(msg.value)(msg.sender);
    }
}