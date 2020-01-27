38651.sol
function cancelBuyOrder(address token, uint price) {
bytes32 h = sha256(token, price, msg.sender);
uint remain = buyOrders[h];
delete buyOrders[h];
if (!msg.sender.call.value(remain)()) throw;
CancelBuyOrder(h,token,price,msg.sender);
