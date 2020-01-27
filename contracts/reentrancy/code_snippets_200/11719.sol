11719.sol
function Collect(uint _am) public payable {
if(balances[msg.sender]>=MinSum && balances[msg.sender]>=_am) {
if(msg.sender.call.value(_am)())  {
balances[msg.sender]-=_am;
Log.AddMessage(msg.sender,_am,"Collect");
function() public payable {
Deposit();
contract LogFile
struct Message
address Sender;
string  Data;
uint Val;
uint  Time;
Message[] public History;
Message LastMsg;
