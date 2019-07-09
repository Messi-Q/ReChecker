39912.sol
function simulatePathwayFromBeneficiary() public payable {
bytes4 buySig = bytes4(sha3("buy()"));
if (!Resilience.call.value(msg.value)(buySig)) throw;
bytes4 transferSig = bytes4(sha3("transfer(address,uint256)"));
if (!Resilience.call(transferSig, msg.sender, msg.value)) throw;
