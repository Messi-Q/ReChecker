Reentrance_01.sol
function withdrawBalance(){
if(!(msg.sender.call.value(userBalance[msg.sender])())){
throw;
userBalance[msg.sender] = 0;
