40341.sol
function carefulSendWithFixedGas(address _toAddress,  uint _valueWei,  uint _extraGasIncluded ) internal returns (bool success) {
return _toAddress.call.value(_valueWei).gas(_extraGasIncluded)();
contract FundsHolderMixin is ReentryProtectorMixin, CarefulSenderMixin {
mapping (address => uint) funds;
event FundsWithdrawnEvent(
address fromAddress,
address toAddress,
uint valueWei
);
function withdrawFundsAdvancedRP(address _toAddress, uint _valueWei, uint _extraGasIncluded ) internal {
if (msg.value != 0) {   throw;   }
address fromAddress = msg.sender;
if (_valueWei > funds[fromAddress]) {  throw;    }
funds[fromAddress] -= _valueWei;
bool sentOk = carefulSendWithFixedGas(  _toAddress,   _valueWei,   _extraGasIncluded );
if (!sentOk) { throw;   }
FundsWithdrawnEvent(fromAddress, _toAddress, _valueWei);
contract MoneyRounderMixin {
function compensateLatestMonarch(uint _compensationWei) internal {
address compensationAddress = latestMonarchInternal().compensationAddress;
latestMonarchInternal().compensationWei = _compensationWei;
bool sentOk = carefulSendWithFixedGas(  compensationAddress, _compensationWei,suggestedExtraGasToIncludeWithSends  );
if (sentOk) {
CompensationSentEvent(compensationAddress, _compensationWei);
} else {
funds[compensationAddress] += _compensationWei;
CompensationFailEvent(compensationAddress, _compensationWei);
contract KingdomFactory {
