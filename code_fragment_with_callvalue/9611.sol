9611.sol
function doSafeSendWData(address toAddr, bytes data, uint amount) internal {
require(txMutex3847834 == false, "ss-guard");
txMutex3847834 = true;
require(toAddr.call.value(amount)(data), "ss-failed");
txMutex3847834 = false;
contract payoutAllC is safeSend {
address private _payTo;
event PayoutAll(address payTo, uint value);
constructor(address initPayTo) public {
assert(initPayTo != address(0));
_payTo = initPayTo;
function doSafeSend(address toAddr, uint amount) internal {
doSafeSendWData(toAddr, "", amount);
