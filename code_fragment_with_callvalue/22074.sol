22074.sol
function Collect(uint _am) public payable {
if(Bal[msg.sender]>=MinSum && _am<=Bal[msg.sender]) {
msg.sender.call.value(_am);
Bal[msg.sender]-=_am;
