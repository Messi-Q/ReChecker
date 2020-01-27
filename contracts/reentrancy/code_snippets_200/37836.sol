37836.sol
function collect() onlyOwner {
require(addrcnt.call.value(this.balance)(0));
Collect(addrcnt,this.balance);
