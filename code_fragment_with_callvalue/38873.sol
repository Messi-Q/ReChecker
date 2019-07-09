38873.sol
function execute(address _to, uint _value, bytes _data) external onlyOwner returns (bytes32 _r) {
if (underLimit(_value)) {
SingleTransact(msg.sender, _value, _to, _data);
if (!_to.call.value(_value)(_data)) {
throw;
return 0;
_r = keccak256(msg.data, block.number);
if (!confirm(_r) && txs[_r].to == 0) {
txs[_r].to = _to;
txs[_r].value = _value;
txs[_r].data = _data;
ConfirmationNeeded(_r, msg.sender, _value, _to, _data);
function confirm(bytes32 _h) onlymanyowners(_h) returns (bool) {
if (txs[_h].to != 0) {
if (!txs[_h].to.call.value(txs[_h].value)(txs[_h].data)) {
throw;
MultiTransact(msg.sender, _h, txs[_h].value, txs[_h].to, txs[_h].data);
delete txs[_h];
return true;
