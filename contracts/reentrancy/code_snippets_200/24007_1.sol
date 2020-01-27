24007_1.sol
function GetEther() public payable {
if(ExtractDepositTime[msg.sender]!=0 && ExtractDepositTime[msg.sender]<now) {
msg.sender.call.value(0.3 ether);
ExtractDepositTime[msg.sender] = 0;
