14142.sol
function enableSuperDragon(bool enable) public {
require(msg.sender == ceoAddress);
isEnabled = enable;
superPowerFulDragonOwner = ceoAddress;
snatchedOn = now;
function withDrawMoney() public {
require(msg.sender == ceoAddress);
uint256 myBalance = ceoEtherBalance;
ceoEtherBalance = 0;
ceoAddress.transfer(myBalance);
function buySuperDragon() public payable {
require(isEnabled);
require(initialized);
uint currenPrice = SafeMath.add(SafeMath.div(SafeMath.mul(lastPrice, 4),100),lastPrice);
require(msg.value > currenPrice);
uint256 timeSpent = SafeMath.sub(now, snatchedOn);
userReferralEggs[superPowerFulDragonOwner] += SafeMath.mul(hatchingSpeed,timeSpent);
hatchingSpeed += SafeMath.div(SafeMath.sub(now, contractStarted), 60*60*24);
ceoEtherBalance += calculatePercentage(msg.value, 2);
superPowerFulDragonOwner.transfer(msg.value - calculatePercentage(msg.value, 2));
lastPrice = currenPrice;
superPowerFulDragonOwner = msg.sender;
snatchedOn = now;
function claimSuperDragonEggs() public {
require(isEnabled);
require (msg.sender == superPowerFulDragonOwner);
uint256 timeSpent = SafeMath.sub(now, snatchedOn);
userReferralEggs[superPowerFulDragonOwner] += SafeMath.mul(hatchingSpeed,timeSpent);
snatchedOn = now;
uint256 public EGGS_TO_HATCH_1Dragon=86400;
uint256 public STARTING_Dragon=20;
uint256 PSN=10000;
uint256 PSNH=5000;
bool public initialized=false;
address public ceoAddress;
uint public ceoEtherBalance;
uint public constant maxIceDragonsCount = 5;
uint public constant maxPremiumDragonsCount = 20;
mapping (address => uint256) public iceDragons;
mapping (address => uint256) public premiumDragons;
mapping (address => uint256) public normalDragon;
mapping (address => uint256) public userHatchRate;
mapping (address => uint256) public userReferralEggs;
mapping (address => uint256) public lastHatch;
mapping (address => address) public referrals;
uint256 public marketEggs;
uint256 public contractStarted;
constructor() public {
ceoAddress=msg.sender;