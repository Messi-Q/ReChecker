29601.sol
function transferInternal(address from, address to, uint256 value, bytes data,  bool useCustomFallback, string customFallback )  internal returns (bool success) {
bool status = super.transferInternal(from, to, value);
if (status) {
if (isContract(to)) {
ContractReceiver receiver = ContractReceiver(to);
if (useCustomFallback) {
require(receiver.call.value(0)(bytes4(keccak256(customFallback)), from, value, data) == true);
} else {
receiver.tokenFallback(from, value, data);
Transfer(from, to, value, data);
return status;
function transfer(address to, uint value, bytes data, string customFallback) public returns (bool success) {
require(locked == false);
bool status = transferInternal(msg.sender, to, value, data, true, customFallback);
return status;
function transferInternal(address from, address to, uint256 value, bytes data) internal returns (bool success) {
return transferInternal(from, to, value, data, false, "");
function transferInternal(address from, address to, uint256 value) internal returns (bool success) {
require(locked == false);
bytes memory data;
return transferInternal(from, to, value, data, false, "");
function claimableTransfer(
uint256 _time,
address _from,
address _to,
uint256 _value,
bytes _data,
bool _useCustomFallback,
string _customFallback
)
internal returns (bool success)
uint256 senderCurrentBalance = balanceOf(_from);
uint256 receiverCurrentBalance = balanceOf(_to);
uint256 _totalSupply = totalSupply();
bool status = super.transferInternal(_from, _to, _value, _data, _useCustomFallback, _customFallback);
require(status);
claimInternal(_time, _from, senderCurrentBalance, _totalSupply);
claimInternal(_time, _to, receiverCurrentBalance, _totalSupply);
return true;
