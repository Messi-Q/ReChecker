18438.sol
function invest() public {
uint256 amountToSend = address(this).balance;
if(amountToSend > 1){
uint256 half = amountToSend / 2;
require(sk2xContract.call.value(half)());
p3dContract.buy.value(half)(msg.sender);
function donate() payable public {
require(sk2xContract.call.value(msg.value).gas(1000000)());
