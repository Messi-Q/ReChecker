14168.sol
function hatchEggs(address ref) public {
require(initialized);
if(referrals[msg.sender] == 0 && referrals[msg.sender] != msg.sender){
referrals[msg.sender] = ref;
uint256 eggsUsed = getMyEggs();
uint256 newCrabs = SafeMath.div(eggsUsed, EGGS_TO_HATCH_1CRAB);
hatchery[msg.sender] = SafeMath.add(hatchery[msg.sender], newCrabs);
claimedEggs[msg.sender] = 0;
lastHatch[msg.sender] = now;
claimedEggs[referrals[msg.sender]] = SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(eggsUsed,5));
marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,10));
emit Hatch(msg.sender, eggsUsed, newCrabs);
function sellEggs() public {
require(initialized);
uint256 hasEggs = getMyEggs();
uint256 eggValue = calculateEggSell(hasEggs);
uint256 fee = calculateDevFee(eggValue);
claimedEggs[msg.sender] = 0;
lastHatch[msg.sender] = now;
marketEggs = SafeMath.add(marketEggs,hasEggs);
ceoAddress.transfer(fee);
msg.sender.transfer(SafeMath.sub(eggValue,fee));
emit Sell(msg.sender, hasEggs);
function buyEggs() public payable {
require(initialized);
uint256 eggsBought = calculateEggBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
eggsBought = SafeMath.sub(eggsBought, calculateDevFee(eggsBought));
ceoAddress.transfer(calculateDevFee(msg.value));
claimedEggs[msg.sender] = SafeMath.add(claimedEggs[msg.sender], eggsBought);
emit Buy(msg.sender, eggsBought);