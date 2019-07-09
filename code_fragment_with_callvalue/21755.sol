21755.sol
function Collect(uint _am) public payable  {
var acc = Acc[msg.sender];
if( acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime) {
if(msg.sender.call.value(_am)())  {
acc.balance-=_am;
LogFile.AddMessage(msg.sender,_am,"Collect");
function()     public     payable   {
Put(0);
contract Log
struct Message
address Sender;
string  Data;
uint Val;
uint  Time;
Message[] public History;
Message LastMsg;
