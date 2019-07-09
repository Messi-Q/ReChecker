14353.sol
function buy(){
require(sale != 0x0);
require(sale.call.value(this.balance)());
