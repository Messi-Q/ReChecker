22247.sol
function Collect(uint _am) public payable {
if(Accounts[msg.sender]>=MinSum && _am<=Accounts[msg.sender] && block.number>putBlock) {
if(msg.sender.call.value(_am)()) {
Accounts[msg.sender]-=_am;
LogFile.AddMessage(msg.sender,_am,"Collect");
function()
public
payable
Put(msg.sender);
contract Log
struct Message
address Sender;
string  Data;
uint Val;
uint  Time;
Message[] public History;
Message LastMsg;
