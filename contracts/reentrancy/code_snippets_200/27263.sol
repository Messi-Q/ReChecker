27263.sol
function loggedTransfer(uint amount, bytes32 logMsg, address target, address currentOwner) payable{
if(msg.sender != address(this))throw;
if(target.call.value(amount)()) {
CashMove(amount, logMsg, target, currentOwner);
function Divest(uint amount)  public  {
if ( investors[msg.sender] > 0 && amount > 0)  {
this.loggedTransfer(amount, "", msg.sender, owner);
investors[msg.sender] -= amount;
function withdraw() public {
if(msg.sender==owner) {
this.loggedTransfer(this.balance, "", msg.sender, owner);
