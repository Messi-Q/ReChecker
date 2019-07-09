10297.sol
function execute0(address to, uint256 value, bytes data) private returns (address created)  {
if (to == 0) {
created = create0(value, data);
} else {
require(to.call.value(value)(data));
