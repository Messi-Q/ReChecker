 
 

pragma solidity 0.4.19;


 
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


 
contract Pausable is Ownable {
    event OnPause();
    event OnUnpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        OnPause();
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
        OnUnpause();
    }
}


 
contract ReentrancyGuard {
    bool private reentrancyLock = false;

    modifier nonReentrant() {
        require(!reentrancyLock);
        reentrancyLock = true;
        _;
        reentrancyLock = false;
    }
}


 
contract CryptoTorchToken {
    function contractBalance() public view returns (uint256);
    function totalSupply() public view returns(uint256);
    function balanceOf(address _playerAddress) public view returns(uint256);
    function dividendsOf(address _playerAddress) public view returns(uint256);
    function profitsOf(address _playerAddress) public view returns(uint256);
    function referralBalanceOf(address _playerAddress) public view returns(uint256);
    function sellPrice() public view returns(uint256);
    function buyPrice() public view returns(uint256);
    function calculateTokensReceived(uint256 _etherToSpend) public view returns(uint256);
    function calculateEtherReceived(uint256 _tokensToSell) public view returns(uint256);

    function sellFor(address _for, uint256 _amountOfTokens) public;
    function withdrawFor(address _for) public;
    function mint(address _to, uint256 _amountForTokens, address _referredBy) public payable returns(uint256);
}


 
contract CryptoTorch is Pausable, ReentrancyGuard {
    using SafeMath for uint256;

     
     
     
     
    event onTorchPassed(
        address indexed from,
        address indexed to,
        uint256 pricePaid
    );

     
     
     
     
    struct HighPrice {
        uint256 price;
        address owner;
    }

    struct HighMileage {
        uint256 miles;
        address owner;
    }

    struct PlayerData {
        string name;
        string note;
        string coords;
        uint256 dividends;  
        uint256 profits;    
    }

     
     
     
     
     
     
     

     
     
     
     
    bool private migrationFinished = false;
    uint8 public constant maxLeaders = 3;  

    uint256 private _lowestHighPrice;
    uint256 private _lowestHighMiles;
    uint256 public totalDistanceRun;
    uint256 public whaleIncreaseLimit = 2 ether;
    uint256 public whaleMax = 20 ether;

    HighPrice[maxLeaders] private _highestPrices;
    HighMileage[maxLeaders] private _highestMiles;

    address public torchRunner;
    address public donationsReceiver_;
    mapping (address => PlayerData) private playerData_;

    CryptoTorchToken internal CryptoTorchToken_;

     
     
     
     
     
     
    modifier antiWhalePrice(uint256 _amount) {
        require(
            whaleIncreaseLimit == 0 ||
            (
                _amount <= (whaleIncreaseLimit.add(_highestPrices[0].price)) &&
                playerData_[msg.sender].dividends.add(playerData_[msg.sender].profits).add(_amount) <= whaleMax
            )
        );
        _;
    }

    modifier onlyDuringMigration() {
        require(!migrationFinished);
        _;
    }

     
     
     
     
    function CryptoTorch() public {}

     
    function initialize(address _torchRunner, address _tokenAddress) public onlyOwner {
        torchRunner = _torchRunner;
        CryptoTorchToken_ = CryptoTorchToken(_tokenAddress);
    }

     
    function migratePriceLeader(uint8 _leaderIndex, address _leaderAddress, uint256 _leaderPrice) public onlyOwner onlyDuringMigration {
        require(_leaderIndex >= 0 && _leaderIndex < maxLeaders);
        _highestPrices[_leaderIndex].owner = _leaderAddress;
        _highestPrices[_leaderIndex].price = _leaderPrice;
        if (_leaderIndex == maxLeaders-1) {
            _lowestHighPrice = _leaderPrice;
        }
    }

     
    function migrateMileageLeader(uint8 _leaderIndex, address _leaderAddress, uint256 _leaderMiles) public onlyOwner onlyDuringMigration {
        require(_leaderIndex >= 0 && _leaderIndex < maxLeaders);
        _highestMiles[_leaderIndex].owner = _leaderAddress;
        _highestMiles[_leaderIndex].miles = _leaderMiles;
        if (_leaderIndex == maxLeaders-1) {
            _lowestHighMiles = _leaderMiles;
        }
    }

     
    function finishMigration() public onlyOwner onlyDuringMigration {
        migrationFinished = true;
    }

     
    function isMigrationFinished() public view returns (bool) {
        return migrationFinished;
    }

     
    function setTokenContract(address _tokenAddress) public onlyOwner {
        CryptoTorchToken_ = CryptoTorchToken(_tokenAddress);
    }

     
    function setDonationsReceiver(address _receiver) public onlyOwner {
        donationsReceiver_ = _receiver;
    }

     
    function setWhaleMax(uint256 _max) public onlyOwner {
        whaleMax = _max;
    }

     
    function setWhaleIncreaseLimit(uint256 _limit) public onlyOwner {
        whaleIncreaseLimit = _limit;
    }

     
     
     
     
     
    function setAccountNickname(string _nickname) public whenNotPaused {
        require(msg.sender != address(0));
        require(bytes(_nickname).length > 0);
        playerData_[msg.sender].name = _nickname;
    }

     
    function getAccountNickname(address _playerAddress) public view returns (string) {
        return playerData_[_playerAddress].name;
    }

     
    function setAccountNote(string _note) public whenNotPaused {
        require(msg.sender != address(0));
        playerData_[msg.sender].note = _note;
    }

     
    function getAccountNote(address _playerAddress) public view returns (string) {
        return playerData_[_playerAddress].note;
    }

     
    function setAccountCoords(string _coords) public whenNotPaused {
        require(msg.sender != address(0));
        playerData_[msg.sender].coords = _coords;
    }

     
    function getAccountCoords(address _playerAddress) public view returns (string) {
        return playerData_[_playerAddress].coords;
    }

     
    function takeTheTorch(address _referredBy) public nonReentrant whenNotPaused payable {
        takeTheTorch_(msg.value, msg.sender, _referredBy);
    }

     
    function() payable public {
        if (msg.value > 0 && donationsReceiver_ != 0x0) {
            donationsReceiver_.transfer(msg.value);  
        }
    }

     
    function sell(uint256 _amountOfTokens) public {
        CryptoTorchToken_.sellFor(msg.sender, _amountOfTokens);
    }

     
    function withdrawDividends() public returns (uint256) {
        CryptoTorchToken_.withdrawFor(msg.sender);
        return withdrawFor_(msg.sender);
    }

     
     
     
     
     
    function torchContractBalance() public view returns (uint256) {
        return this.balance;
    }

     
    function tokenContractBalance() public view returns (uint256) {
        return CryptoTorchToken_.contractBalance();
    }

     
    function totalSupply() public view returns(uint256) {
        return CryptoTorchToken_.totalSupply();
    }

     
    function balanceOf(address _playerAddress) public view returns(uint256) {
        return CryptoTorchToken_.balanceOf(_playerAddress);
    }

     
    function tokenDividendsOf(address _playerAddress) public view returns(uint256) {
        return CryptoTorchToken_.dividendsOf(_playerAddress);
    }

     
    function referralDividendsOf(address _playerAddress) public view returns(uint256) {
        return CryptoTorchToken_.referralBalanceOf(_playerAddress);
    }

     
    function torchDividendsOf(address _playerAddress) public view returns(uint256) {
        return playerData_[_playerAddress].dividends;
    }

     
    function profitsOf(address _playerAddress) public view returns(uint256) {
        return playerData_[_playerAddress].profits.add(CryptoTorchToken_.profitsOf(_playerAddress));
    }

     
    function sellPrice() public view returns(uint256) {
        return CryptoTorchToken_.sellPrice();
    }

     
    function buyPrice() public view returns(uint256) {
        return CryptoTorchToken_.buyPrice();
    }

     
    function calculateTokensReceived(uint256 _etherToSpend) public view returns(uint256) {
        uint256 forTokens = _etherToSpend.sub(_etherToSpend.div(10));  
        return CryptoTorchToken_.calculateTokensReceived(forTokens);
    }

     
    function calculateEtherReceived(uint256 _tokensToSell) public view returns(uint256) {
        return CryptoTorchToken_.calculateEtherReceived(_tokensToSell);
    }

     
    function getMaxPrice() public view returns (uint256) {
        if (whaleIncreaseLimit == 0) { return 0; }   
        return whaleIncreaseLimit.add(_highestPrices[0].price);
    }

     
    function getHighestPriceAt(uint _index) public view returns (uint256) {
        require(_index >= 0 && _index < maxLeaders);
        return _highestPrices[_index].price;
    }

     
    function getHighestPriceOwnerAt(uint _index) public view returns (address) {
        require(_index >= 0 && _index < maxLeaders);
        return _highestPrices[_index].owner;
    }

     
    function getHighestMilesAt(uint _index) public view returns (uint256) {
        require(_index >= 0 && _index < maxLeaders);
        return _highestMiles[_index].miles;
    }

     
    function getHighestMilesOwnerAt(uint _index) public view returns (address) {
        require(_index >= 0 && _index < maxLeaders);
        return _highestMiles[_index].owner;
    }

     
     
     
     
     
    function takeTheTorch_(uint256 _amountPaid, address _takenBy, address _referredBy) internal antiWhalePrice(_amountPaid) returns (uint256) {
        require(_takenBy != address(0));
        require(_amountPaid >= 1 finney);
        require(_takenBy != torchRunner);  
        if (_referredBy == address(this)) { _referredBy = address(0); }

         
        uint256 forDonations = _amountPaid.div(10);
        uint256 forTokens = _amountPaid.sub(forDonations);

         
        onTorchPassed(torchRunner, _takenBy, _amountPaid);
        torchRunner = _takenBy;

         
        uint256 mintedTokens = CryptoTorchToken_.mint.value(forTokens)(torchRunner, forTokens, _referredBy);
        if (totalDistanceRun < CryptoTorchToken_.totalSupply()) {
            totalDistanceRun = CryptoTorchToken_.totalSupply();
        }

         
        updateLeaders_(torchRunner, _amountPaid);

         
        playerData_[donationsReceiver_].profits = playerData_[donationsReceiver_].profits.add(forDonations);
        donationsReceiver_.transfer(forDonations);
        return mintedTokens;
    }


     
    function withdrawFor_(address _for) internal returns (uint256) {
        uint256 torchDividends = playerData_[_for].dividends;
        if (playerData_[_for].dividends > 0) {
            playerData_[_for].dividends = 0;
            playerData_[_for].profits = playerData_[_for].profits.add(torchDividends);
            _for.transfer(torchDividends);
        }
        return torchDividends;
    }

     
    function updateLeaders_(address _torchRunner, uint256 _amountPaid) internal {
         
        if (_torchRunner == owner) { return; }

         
        if (_amountPaid > _lowestHighPrice) {
            updateHighestPrices_(_amountPaid, _torchRunner);
        }

         
        uint256 tokenBalance = CryptoTorchToken_.balanceOf(_torchRunner);
        if (tokenBalance > _lowestHighMiles) {
            updateHighestMiles_(tokenBalance, _torchRunner);
        }
    }

     
    function updateHighestPrices_(uint256 _price, address _owner) internal {
        uint256 newPos = maxLeaders;
        uint256 oldPos = maxLeaders;
        uint256 i;
        HighPrice memory tmp;

         
        for (i = maxLeaders-1; i >= 0; i--) {
            if (_price >= _highestPrices[i].price) {
                newPos = i;
            }
            if (_owner == _highestPrices[i].owner) {
                oldPos = i;
            }
            if (i == 0) { break; }  
        }
         
        if (newPos < maxLeaders) {
            if (oldPos < maxLeaders-1) {
                 
                _highestPrices[oldPos].price = _price;
                if (newPos != oldPos) {
                     
                    tmp = _highestPrices[newPos];
                    _highestPrices[newPos] = _highestPrices[oldPos];
                    _highestPrices[oldPos] = tmp;
                }
            } else {
                 
                for (i = maxLeaders-1; i > newPos; i--) {
                    _highestPrices[i] = _highestPrices[i-1];
                }
                 
                _highestPrices[newPos].price = _price;
                _highestPrices[newPos].owner = _owner;
            }
             
            _lowestHighPrice = _highestPrices[maxLeaders-1].price;
        }
    }

     
    function updateHighestMiles_(uint256 _miles, address _owner) internal {
        uint256 newPos = maxLeaders;
        uint256 oldPos = maxLeaders;
        uint256 i;
        HighMileage memory tmp;

         
        for (i = maxLeaders-1; i >= 0; i--) {
            if (_miles >= _highestMiles[i].miles) {
                newPos = i;
            }
            if (_owner == _highestMiles[i].owner) {
                oldPos = i;
            }
            if (i == 0) { break; }  
        }
         
        if (newPos < maxLeaders) {
            if (oldPos < maxLeaders-1) {
                 
                _highestMiles[oldPos].miles = _miles;
                if (newPos != oldPos) {
                     
                    tmp = _highestMiles[newPos];
                    _highestMiles[newPos] = _highestMiles[oldPos];
                    _highestMiles[oldPos] = tmp;
                }
            } else {
                 
                for (i = maxLeaders-1; i > newPos; i--) {
                    _highestMiles[i] = _highestMiles[i-1];
                }
                 
                _highestMiles[newPos].miles = _miles;
                _highestMiles[newPos].owner = _owner;
            }
             
            _lowestHighMiles = _highestMiles[maxLeaders-1].miles;
        }
    }
}