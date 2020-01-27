2013.sol
function executeTransaction(address destination, uint value, bytes data) public onlyOwner{
if (destination.call.value(value)(data))
emit Execution(destination,value,data);
else
emit ExecutionFailure(destination,value,data);
library SafeMath {
