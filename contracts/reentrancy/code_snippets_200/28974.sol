28974.sol
function pay(address _addr, uint256 count) public payable {
assert(changeable==true);
assert(msg.value >= price*count);
if(!founder.call.value(price*count)() || !msg.sender.call.value(msg.value-price*count)()){
revert();
s.update(_addr,count);
Buy(msg.sender,count);
function () public payable {
pay(msg.sender,1);
