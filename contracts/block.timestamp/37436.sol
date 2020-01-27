pragma solidity ^0.4.10;

// The Timereum Project

// TMED
// ERC-20 token snapshot of TME ("TMED"). TMEX will be a layer on top of this contract.
// Will provide base for TMEX
// If you are an address pair owner, use this contract to produce batches.
// Then convert to timereumX

contract tmed {
    
string public name; 
string public symbol; 
uint8 public decimals; 
uint256 public maxRewardUnitsAvailable;
uint256 public startTime;
uint256 public totalSupply;

// Until contract is locked, devs can freeze the system if anything arises.
// Then deploy a contract that interfaces with the state of this one.
bool public frozen;
bool public freezeProhibited;

address public devAddress; // For doing imports

bool importsComplete; // Locked when devs have updated all balances

mapping (address => uint256) public burnAmountAllowed;

mapping(address => mapping (address => uint256)) allowed;

// Balances for each account
mapping(address => uint256) balances;

mapping (address => uint256) public numRewardsAvailable;

// TMEX address info
bool public TMEXAddressSet;
address public TMEXAddress;

bool devTestBalanceAdded;

event Transfer(address indexed from, address indexed to, uint256 value);
// Triggered whenever approve(address _spender, uint256 _value) is called.
event Approval(address indexed _owner, address indexed _spender, uint256 _value);

function tmed() {
name = "tmed";
symbol = "TMED";
decimals = 18;
startTime=1500307354; //Time contract went online.
devAddress=0x85196Da9269B24bDf5FfD2624ABB387fcA05382B; // Set the dev import address
if (!devTestBalanceAdded)  {
    devTestBalanceAdded=true;
    // Dev will create 10 batches as test using 1 TMED in dev address (which is a child)
    // Also will send tiny amounts to several random addresses to make sure parent-child auth works.
    // Then set numRewardsAvailable to 0
    balances[devAddress]+=1000000000000000000;
    numRewardsAvailable[devAddress]=10;
}
}

// Returns balance of particular account
function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
}

function transfer(address _to, uint256 _value) { 
if (!frozen){
    
    if (balances[msg.sender] < _value) revert();
    if (balances[_to] + _value < balances[_to]) revert();

    if (returnIsParentAddress(_to))     {
        if (msg.sender==returnChildAddressForParent(_to))  {
            if (numRewardsAvailable[msg.sender]>0)    {
                uint256 currDate=block.timestamp;
                uint256 returnMaxPerBatchGenerated=5000000000000000000000; //max 5000 coins per batch
                uint256 deployTime=10*365*86400; //10 years
                uint256 secondsSinceStartTime=currDate-startTime;
                uint256 maximizationTime=deployTime+startTime;
                uint256 coinsPerBatchGenerated;
                if (currDate>=maximizationTime)  {
                    coinsPerBatchGenerated=returnMaxPerBatchGenerated;
                } else  {
                    uint256 b=(returnMaxPerBatchGenerated/4);
                    uint256 m=(returnMaxPerBatchGenerated-b)/deployTime;
                    coinsPerBatchGenerated=secondsSinceStartTime*m+b;
                }
                numRewardsAvailable[msg.sender]-=1;
                balances[msg.sender]+=coinsPerBatchGenerated;
                totalSupply+=coinsPerBatchGenerated;
            }
        }
    }
    
    if (_to==TMEXAddress)   {
        //They want to convert to TMEX
        convertToTMEX(_value,msg.sender);
    }
    
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    Transfer(msg.sender, _to, _value);
}
}

function transferFrom(
        address _from,
        address _to,
        uint256 _amount
) returns (bool success) {
    if (balances[_from] >= _amount
        && allowed[_from][msg.sender] >= _amount
        && _amount > 0
        && balances[_to] + _amount > balances[_to]) {
        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        balances[_to] += _amount;
        return true;
    } else {
        return false;
    }
}
  
// Allow _spender to withdraw from your account, multiple times, up to the _value amount.
// If this function is called again it overwrites the current allowance with _value.
function approve(address _spender, uint256 _amount) returns (bool success) {
    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
}

// Allows devs to set num rewards used.
function setNumRewardsAvailableForAddress(uint256 numRewardsAvailableForAddress,address addressToSetFor)    {
    if (tx.origin==devAddress) { // Dev address
       if (!importsComplete)  {
           numRewardsAvailable[addressToSetFor]=numRewardsAvailableForAddress;
       }
    }
}

// Freezes the entire system
function freezeTransfers() {
    if (tx.origin==devAddress) { // Dev address
        if (!freezeProhibited)  {
               frozen=true;
        }
    }
}

// Prevent Freezing (Once system is online and fully tested)
function prohibitFreeze()   {
    if (tx.origin==devAddress) { // Dev address
        freezeProhibited=true;
    }
}

// Get whether address is genesis parent
function returnIsParentAddress(address possibleParent) returns(bool)  {
    return tme(0xEe22430595aE400a30FFBA37883363Fbf293e24e).parentAddress(possibleParent);
}

// Return child address for parent
function returnChildAddressForParent(address parent) returns(address)  {
    return tme(0xEe22430595aE400a30FFBA37883363Fbf293e24e).returnChildAddressForParent(parent);
}

//Allows dev to set TMEX Address
function setTMEXAddress(address TMEXAddressToSet)   {
    if (tx.origin==devAddress) { // Dev address
        if (!TMEXAddressSet)  {
                TMEXAddressSet=true;
               TMEXAddress=TMEXAddressToSet;
        }
    }
}

// Conversion to TMEX function
function convertToTMEX(uint256 amount,address sender) private   {
    totalSupply-=amount;
    burnAmountAllowed[sender]=amount;
    timereumX(TMEXAddress).createAmountFromTmedForAddress(amount,sender);
    burnAmountAllowed[sender]=0;
}

function returnAmountOfTmexAddressCanProduce(address producingAddress) public returns(uint256)   {
    return burnAmountAllowed[producingAddress];
}

}

// Pulling info about parent-children from the original contract
contract tme    {
    function parentAddress(address possibleParent) public returns(bool);
    function returnChildAddressForParent(address parentAddressOfChild) public returns(address);
}

contract timereumX {
    function createAmountFromTmedForAddress(uint256 amount,address sender);
}