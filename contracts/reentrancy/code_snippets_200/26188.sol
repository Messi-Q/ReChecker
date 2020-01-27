26188.sol
function GetPrizeFund() public payable {
require(now>EndTime);
require(Bids[msg.sender]>=MaxOffer);
uint prizeAmount = Bids[msg.sender]+PrizeFund;
PrizeFund = 0;
Bids[msg.sender]=0;
msg.sender.call.value(prizeAmount);
function RevokeBid() public payable {
require(now>EndTime);
uint toTransfer = Bids[msg.sender];
Bids[msg.sender]=0;
msg.sender.call.value(toTransfer);
