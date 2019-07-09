668.sol
function call(address _to, bytes memory _data) public payable onlyWhitelistAdmin {
require(_to != address(registrar));
(bool success,) = _to.call.value(msg.value)(_data);
require(success);
