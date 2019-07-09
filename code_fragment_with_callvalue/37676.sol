37676.sol
function send(address _to, uint _value, bytes _data) only_owner {
if (!_to.call.value(_value)(_data)) throw;
Sent(_to, _value, _data);
