pragma solidity ^0.4.22;

 
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
         
        uint256 c = a / b;

         
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);

        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);

        return c;
    }
}

 
contract Ownable {
     
    address public owner;

     
    event ChangeOwnership(address indexed _owner, address indexed _newOwner);

     
    modifier OnlyOwner() {
        require(msg.sender == owner);

        _;
    }

     
    function Ownable() public {
        owner = msg.sender;
    }

     
    function transferOwnership(address _newOwner) public OnlyOwner {
        require(_newOwner != address(0x0));

        owner = _newOwner;

        emit ChangeOwnership(owner, _newOwner);
    }
}

 
contract Pausable is Ownable {
     
    event Pause(string pauseReason);
     
    event Unpause(string unpauseReason);

    bool public isPaused;
    string public pauseNotice;

     
    modifier IsNotPaused() {
        require(!isPaused);
        _;
    }

     
    modifier IsPaused() {
        require(isPaused);
        _;
    }

     
    function pause(string _reason) OnlyOwner IsNotPaused public {
        isPaused = true;
        pauseNotice = _reason;
        emit Pause(_reason);
    }

     
    function unpause(string _reason) OnlyOwner IsPaused public {
        isPaused = false;
        pauseNotice = _reason;
        emit Unpause(_reason);
    }
}

 
contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) public view returns(uint256 theBalance);
    function transfer(address to, uint256 value) public returns(bool success);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns(uint256 theAllowance);
    function transferFrom(address from, address to, uint256 value) public returns(bool success);
    function approve(address spender, uint256 value) public returns(bool success);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

     
    mapping(address => uint256) balances;

     
    function balanceOf(address _address) public constant returns(uint256 theBalance){
        return balances[_address];
    }

     
    function transfer(address _to, uint256 _value) public returns(bool success){
        require(_to != address(0x0) && _value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }
}

 
contract StandardToken is BasicToken, ERC20 {
     
    mapping (address => mapping (address => uint256)) allowed;

     
    function allowance(address _owner, address _spender) public constant returns(uint256 theAllowance){
        return allowed[_owner][_spender];
    }

     
    function approve(address _spender, uint256 _value) public returns(bool success){
        require(allowed[msg.sender][_spender] == 0 || _value == 0);

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }
}

 
contract BurnableToken is BasicToken {
    event Burn(address indexed burner, uint256 value);

     
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);

        emit Burn(msg.sender, _value);
    }
}

 
contract Cherrio is StandardToken, BurnableToken, Ownable, Pausable {
    using SafeMath for uint256;

     
    string  public constant name = "CHERR.IO";
    string  public constant symbol = "CHR";
    uint8   public constant decimals = 18;

     
    uint256 public constant INITIAL_SUPPLY =  200000000 * (10 ** uint256(decimals));
    uint256 public constant ADMIN_ALLOWANCE =  80000000 * (10 ** uint256(decimals));
    uint256 public constant CONTRACT_ALLOWANCE = INITIAL_SUPPLY - ADMIN_ALLOWANCE;

     
    uint256 public constant FUNDING_ETH_HARD_CAP = 15000 ether;
     
    uint256 public constant MINIMUM_ETH_SOFT_CAP = 3750 ether;
     
    uint256 public constant MINIMUM_CONTRIBUTION = 100 finney;
     
    uint256 public constant RATE = 5333;
     
    uint256 public constant RATE_TIER1 = 8743;
     
    uint256 public constant RATE_TIER2 = 7306;
     
    uint256 public constant RATE_TIER3 = 6584;
     
    uint256 public constant RATE_PUBLIC_SALE = 5926;
     
    uint256 public constant TIER1_CAP = 60000000 * (10 ** uint256(decimals));
     
    uint256 public constant TIER2_CAP = 36000000 * (10 ** uint256(decimals));

     
    uint256 public participantCapTier1;
     
    uint256 public participantCapTier2;

     
    uint256 public poolAddressCapTier1;
     
    uint256 public poolAddressCapTier2;

     
    address public adminAddress;
     
    address public beneficiaryAddress;
     
    address public contractAddress;
     
    address public poolAddress;

     
    bool public transferIsEnabled;

     
    uint256 public weiRaised;

     
    uint256[4] public tokensSent;

     
    uint256 startTimePresale;

     
    uint256 startTime;
    uint256 endTime;

     
    uint256 publicSaleDiscountEndTime;

     
    uint256[3] public tierEndTime;

     
    bool contractAddressIsSet;

    struct Contributor {
        bool canContribute;
        uint8 tier;
        uint256 contributionInWeiTier1;
        uint256 contributionInWeiTier2;
        uint256 contributionInWeiTier3;
        uint256 contributionInWeiPublicSale;
    }

    struct Pool {
        uint256 contributionInWei;
    }

    enum Stages {
        Pending,
        PreSale,
        PublicSale,
        Ended
    }

     
    Stages public stage;

    mapping(address => Contributor) public contributors;
    mapping(address => mapping(uint8 => Pool)) public pool;

     
    modifier TransferIsEnabled {
        require(transferIsEnabled || msg.sender == adminAddress || msg.sender == contractAddress);

        _;
    }

     
    modifier ValidDestination(address _to) {
        require(_to != address(0x0));
        require(_to != address(this));
        require(_to != owner);
        require(_to != address(adminAddress));
        require(_to != address(contractAddress));
        require(_to != address(beneficiaryAddress));

        _;
    }

     
    modifier AtStage(Stages _expectedStage) {
        require(stage == _expectedStage);

        _;
    }

     
    modifier CheckIfICOIsLive() {
        require(stage != Stages.Pending && stage != Stages.Ended);

        if(stage == Stages.PreSale) {
            require(
                startTimePresale > 0 &&
                now >= startTimePresale &&
                now <= tierEndTime[2]
            );
        }
        else {
            require(
                startTime > 0 &&
                now >= startTime &&
                now <= endTime
            );
        }

        _;
    }

     
    modifier CheckPurchase() {
        require(msg.value >= MINIMUM_CONTRIBUTION);

        _;
    }

     
    event TokenPurchase(address indexed _purchaser, uint256 _value, uint256 _tokens);

     
    event OfferingOpens(string _msg, uint256 _startTime, uint256 _endTime);

     
    event OfferingCloses(uint256 _endTime, uint256 _totalWeiRaised);

     
    function Cherrio() public {
        totalSupply = INITIAL_SUPPLY;

         
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0x0), msg.sender, totalSupply);

         
        adminAddress = 0xe0509bB3921aacc433108D403f020a7c2f92e936;
        approve(adminAddress, ADMIN_ALLOWANCE);

        participantCapTier1 = 100 ether;
        participantCapTier2 = 100 ether;
        poolAddressCapTier1 = 2000 ether; 
        poolAddressCapTier2 = 2000 ether;

        weiRaised = 0;
        startTimePresale = 0;
        startTime = 0;
        endTime = 0;
        publicSaleDiscountEndTime = 0;
        transferIsEnabled = false;
        contractAddressIsSet = false;
    }

     
    function addApprovedAddresses(address[] _addresses, uint8 _tier) external OnlyOwner {
        uint256 length = _addresses.length;

        for(uint256 i = 0; i < length; i++) {
            if(!contributors[_addresses[i]].canContribute) {
                contributors[_addresses[i]].canContribute = true;
                contributors[_addresses[i]].tier = _tier;
                contributors[_addresses[i]].contributionInWeiTier1 = 0;
                contributors[_addresses[i]].contributionInWeiTier2 = 0;
                contributors[_addresses[i]].contributionInWeiTier3 = 0;
                contributors[_addresses[i]].contributionInWeiPublicSale = 0;
            }
        }
    }

     
    function addSingleApprovedAddress(address _address, uint8 _tier) external OnlyOwner {
        if(!contributors[_address].canContribute) {
            contributors[_address].canContribute = true;
            contributors[_address].tier = _tier;
            contributors[_address].contributionInWeiTier1 = 0;
            contributors[_address].contributionInWeiTier2 = 0;
            contributors[_address].contributionInWeiTier3 = 0;
            contributors[_address].contributionInWeiPublicSale = 0;
        }
    }

     
    function setTokenOffering() external OnlyOwner{
        require(!contractAddressIsSet);
        require(!transferIsEnabled);

        contractAddress = address(this);
        approve(contractAddress, CONTRACT_ALLOWANCE);

        beneficiaryAddress = 0xAec8c4242c8c2E532c6D6478A7de380263234845;
        poolAddress = 0x1A2C916B640520E1e93A78fEa04A49D8345a5aa9;

        pool[poolAddress][0].contributionInWei = 0;
        pool[poolAddress][1].contributionInWei = 0;
        pool[poolAddress][2].contributionInWei = 0;
        pool[poolAddress][3].contributionInWei = 0;

        tokensSent[0] = 0;
        tokensSent[1] = 0;
        tokensSent[2] = 0;
        tokensSent[3] = 0;

        stage = Stages.Pending;
        contractAddressIsSet = true;
    }

     
    function startPresale(uint256 _startTimePresale) external OnlyOwner AtStage(Stages.Pending) {
        if(_startTimePresale == 0) {
            startTimePresale = now;
        }
        else {
            startTimePresale = _startTimePresale;
        }

        setTierEndTime();

        stage = Stages.PreSale;
    }

     
    function startPublicSale(uint256 _startTime) external OnlyOwner AtStage(Stages.PreSale) {
        if(_startTime == 0) {
            startTime = now;
        }
        else {
            startTime = _startTime;
        }

        endTime = startTime + 15 days;
        publicSaleDiscountEndTime = startTime + 3 days;

        stage = Stages.PublicSale;
    }

     
    function () public payable {
        buy();
    }

    function buy() public payable IsNotPaused CheckIfICOIsLive returns(bool _success) {
        uint8 currentTier = getCurrentTier();

        if(currentTier > 3) {
            revert();
        }

        if(!buyTokens(currentTier)) {
            revert();
        }

        return true;
    }

     
    function buyTokens(uint8 _tier) internal ValidDestination(msg.sender) CheckPurchase returns(bool _success) {
        if(weiRaised.add(msg.value) > FUNDING_ETH_HARD_CAP) {
            revert();
        }

        uint256 contributionInWei = msg.value;

        if(!checkTierCap(_tier, contributionInWei)) {
            revert();
        }

        uint256 rate = getTierTokens(_tier);
        uint256 tokens = contributionInWei.mul(rate);

        if(msg.sender != poolAddress) {
            if(stage == Stages.PreSale) {
                if(!checkAllowedTier(msg.sender, _tier)) {
                    revert();
                }
            }

            if(!checkAllowedContribution(msg.sender, contributionInWei, _tier)) {
                revert();
            }

            if(!this.transferFrom(owner, msg.sender, tokens)) {
                revert();
            }

            if(stage == Stages.PreSale) {
                if(_tier == 0) {
                    contributors[msg.sender].contributionInWeiTier1 = contributors[msg.sender].contributionInWeiTier1.add(contributionInWei);
                }
                else if(_tier == 1) {
                    contributors[msg.sender].contributionInWeiTier2 = contributors[msg.sender].contributionInWeiTier2.add(contributionInWei);
                }
                else if(_tier == 2) {
                    contributors[msg.sender].contributionInWeiTier3 = contributors[msg.sender].contributionInWeiTier3.add(contributionInWei);
                }
            }
            else {
                contributors[msg.sender].contributionInWeiPublicSale = contributors[msg.sender].contributionInWeiPublicSale.add(contributionInWei);
            }
        }
        else {
            if(!checkPoolAddressTierCap(_tier, contributionInWei)) {
                revert();
            }

            if(!this.transferFrom(owner, msg.sender, tokens)) {
                revert();
            }

            pool[poolAddress][_tier].contributionInWei = pool[poolAddress][_tier].contributionInWei.add(contributionInWei);
        }

        weiRaised = weiRaised.add(contributionInWei);
        tokensSent[_tier] = tokensSent[_tier].add(tokens);

        if(weiRaised >= FUNDING_ETH_HARD_CAP) {
            offeringEnded();
        }

        beneficiaryAddress.transfer(address(this).balance);
        emit TokenPurchase(msg.sender, contributionInWei, tokens);

        return true;
    }

     
    function withdrawCrowdsaleTokens(address _to, uint256 _value) external OnlyOwner ValidDestination(_to) returns (bool _success) {
        if(!this.transferFrom(owner, _to, _value)) {
            revert();
        }

        return true;
    }

     
    function transfer(address _to, uint256 _value) public ValidDestination(_to) TransferIsEnabled IsNotPaused returns(bool _success){
         return super.transfer(_to, _value);
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public ValidDestination(_to) TransferIsEnabled IsNotPaused returns(bool _success){
        return super.transferFrom(_from, _to, _value);
    }

     
    function checkAllowedTier(address _address, uint8 _tier) internal view returns (bool _allowed) {
        if(contributors[_address].tier <= _tier) {
            return true;
        }
        else{
          return false;
        }
    }

     
    function checkTierCap(uint8 _tier, uint256 _value) internal view returns (bool _success) {
        uint256 currentlyTokensSent = tokensSent[_tier];
        bool status = true;

        if(_tier == 0) {
            if(TIER1_CAP < currentlyTokensSent.add(_value)) {
                status = false;
            }
        }
        else if(_tier == 1) {
            if(TIER2_CAP < currentlyTokensSent.add(_value)) {
                status = false;
            }
        }

        return status;
    }
    
     
    function checkPoolAddressTierCap(uint8 _tier, uint256 _value) internal view returns (bool _success) {
        uint256 currentContribution = pool[poolAddress][_tier].contributionInWei;

        if((_tier == 0 && (poolAddressCapTier1 < currentContribution.add(_value))) || (_tier == 1 && (poolAddressCapTier2 < currentContribution.add(_value)))) {
            return false;
        }

        return true;
    }

     
    function checkAllowedContribution(address _address, uint256 _value, uint8 _tier) internal view returns (bool _success) {
        bool status = false;

        if(contributors[_address].canContribute) {
            if(_tier == 0) {
                if(participantCapTier1 >= contributors[_address].contributionInWeiTier1.add(_value)) {
                    status = true;
                }
            }
            else if(_tier == 1) {
                if(participantCapTier2 >= contributors[_address].contributionInWeiTier2.add(_value)) {
                    status = true;
                }
            }
            else if(_tier == 2) {
                status = true;
            }
            else {
                status = true;
            }
        }

        return status;
    }
    
     
    function getTierTokens(uint8 _tier) internal view returns(uint256 _tokens) {
        uint256 tokens = RATE_TIER1;

        if(_tier == 1) {
            tokens = RATE_TIER2;
        }
        else if(_tier == 2) {
            tokens = RATE_TIER3;
        }
        else if(_tier == 3) {
            if(now <= publicSaleDiscountEndTime) {
                tokens = RATE_PUBLIC_SALE;
            }
            else {
                tokens = RATE;
            }
        }

        return tokens;
    }

     
    function getCurrentTier() public view returns(uint8 _tier) {
        uint8 currentTier = 3;  

        if(stage == Stages.PreSale) {
            if(now <= tierEndTime[0]) {
                currentTier = 0;
            }
            else if(now <= tierEndTime[1]) {
                currentTier = 1;
            }
            else if(now <= tierEndTime[2]) {
                currentTier = 2;
            }
        }
        else {
            if(now > endTime) {
                currentTier = 4;  
            }
        }

        return currentTier;
    }

     
    function setTierEndTime() internal AtStage(Stages.Pending) {
        tierEndTime[0] = startTimePresale + 1 days; 
        tierEndTime[1] = tierEndTime[0] + 2 days;   
        tierEndTime[2] = tierEndTime[1] + 6 days;   
    }

     
    function endOffering() public OnlyOwner {
        offeringEnded();
    }

     
    function offeringEnded() internal {
        endTime = now;
        stage = Stages.Ended;

        emit OfferingCloses(endTime, weiRaised);
    }

     
    function enableTransfer() public OnlyOwner returns(bool _success){
        transferIsEnabled = true;
        uint256 tokensToBurn = allowed[msg.sender][contractAddress];

        if(tokensToBurn != 0){
            burn(tokensToBurn);
            approve(contractAddress, 0);
        }

        return true;
    }
    
     
    function extendEndTime(uint256 _addedTime) external OnlyOwner {
        endTime = endTime + _addedTime;
    }
    
     
    function extendPublicSaleDiscountEndTime(uint256 _addedPublicSaleDiscountEndTime) external OnlyOwner {
        publicSaleDiscountEndTime = publicSaleDiscountEndTime + _addedPublicSaleDiscountEndTime;
    }
    
     
    function updatePoolAddressCapTier1(uint256 _poolAddressCapTier1) external OnlyOwner {
        poolAddressCapTier1 = _poolAddressCapTier1;
    }
    
     
    function updatePoolAddressCapTier2(uint256 _poolAddressCapTier2) external OnlyOwner {
        poolAddressCapTier2 = _poolAddressCapTier2;
    }

     
    
     
    function updateParticipantCapTier1(uint256 _participantCapTier1) external OnlyOwner {
        participantCapTier1 = _participantCapTier1;
    }
    
     
    function updateParticipantCapTier2(uint256 _participantCapTier2) external OnlyOwner {
        participantCapTier2 = _participantCapTier2;
    }
}