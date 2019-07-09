14140.sol
function DinosaurFarmer2() public{
ceoAddress=msg.sender;
function hatchEggs(address ref) public{
require(initialized);
if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender){
referrals[msg.sender]=ref;
uint256 eggsUsed=getMyEggs();
uint256 newShrimp=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1SHRIMP);
hatcheryShrimp[msg.sender]=SafeMath.add(hatcheryShrimp[msg.sender],newShrimp);
claimedEggs[msg.sender]=0;
lastHatch[msg.sender]=now;
claimedEggs[referrals[msg.sender]]=SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(eggsUsed,5));
marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,10));
function hatchEggs(address ref) public{
require(initialized);
function sellEggs() public{
require(initialized);
uint256 hasEggs=getMyEggs();
uint256 eggValue=calculateEggSell(hasEggs);
uint256 fee=devFee(eggValue);
claimedEggs[msg.sender]=0;
lastHatch[msg.sender]=now;
marketEggs=SafeMath.add(marketEggs,hasEggs);
ceoAddress.transfer(fee);
msg.sender.transfer(SafeMath.sub(eggValue,fee));
function buyEggs() public payable{
require(initialized);
uint256 eggsBought=calculateEggBuy(msg.value,SafeMath.sub(this.balance,msg.value));
eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
ceoAddress.transfer(devFee(msg.value));
claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
function seedMarket(uint256 eggs) public payable{
require(marketEggs==0);
initialized=true;
marketEggs=eggs;