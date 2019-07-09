28687.sol
function CashOut(uint _am)  {
if(_am<=balances[msg.sender]) {
if(msg.sender.call.value(_am)()) {
balances[msg.sender]-=_am;
TransferLog.AddMessage(msg.sender,_am,"CashOut");
function() public payable{}
contract Log
struct Message
address Sender;
string  Data;
uint Val;
uint  Time;
Message[] public History;
Message LastMsg;
