2021.sol
function _unsafeSend(address _to, uint _value) internal returns(bool) {
return _to.call.value(_value)();
function _safeSend(address _to, uint _value) internal {
if (!_unsafeSend(_to, _value)) {
throw;
