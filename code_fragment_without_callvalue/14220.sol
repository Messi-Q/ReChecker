14220.sol
function TJFucks() public{
ceoAddress=msg.sender;
function makeTJs(address ref) public{
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
function sellFucks() public{
require(initialized);
uint256 hasEggs=getMyEggs();
uint256 eggValue=calculateEggSell(hasEggs);
uint256 fee=devFee(eggValue);
claimedEggs[msg.sender]=0;
lastHatch[msg.sender]=now;
marketEggs=SafeMath.add(marketEggs,hasEggs);
ceoAddress.transfer(fee);
msg.sender.transfer(SafeMath.sub(eggValue,fee));