14156.sol
function CraigGrantShrimper() public{
ceoAddress=msg.sender;
modifier onlyCEO(){
require(msg.sender == ceoAddress );
function becomeYouTubemaster() public{
require(initialized);
require(hatcheryCraigGrant[msg.sender]>=YouTubemasterReq);
hatcheryCraigGrant[msg.sender]=SafeMath.sub(hatcheryCraigGrant[msg.sender],YouTubemasterReq);
YouTubemasterReq=SafeMath.add(YouTubemasterReq,100000);
ceoAddress=msg.sender;
function hatchsubscribers(address ref) public{
require(initialized);
if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender){
referrals[msg.sender]=ref;
uint256 subscribersUsed=getMysubscribers();
uint256 newCraigGrant=SafeMath.div(subscribersUsed,subscribers_TO_HATCH_1CraigGrant);
hatcheryCraigGrant[msg.sender]=SafeMath.add(hatcheryCraigGrant[msg.sender],newCraigGrant);
claimedsubscribers[msg.sender]=0;
lastHatch[msg.sender]=now;
claimedsubscribers[referrals[msg.sender]]=SafeMath.add(claimedsubscribers[referrals[msg.sender]],SafeMath.div(subscribersUsed,5));
marketsubscribers=SafeMath.add(marketsubscribers,SafeMath.div(subscribersUsed,10));
function sellsubscribers() public{
require(initialized);
uint256 hassubscribers=getMysubscribers();
uint256 eggValue=calculatesubscribersell(hassubscribers);
uint256 fee=devFee(eggValue);
claimedsubscribers[msg.sender]=0;
lastHatch[msg.sender]=now;
marketsubscribers=SafeMath.add(marketsubscribers,hassubscribers);
ceoAddress.transfer(fee);