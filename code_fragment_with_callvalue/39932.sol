39932.sol
function process(bytes32 _destination) payable returns (bool) {
if (msg.value < 100) throw;
var tax = msg.value * taxPerc / 100;
var refill = bytes4(sha3("refill(bytes32)"));
if ( !ledger.call.value(tax)(refill, taxman)|| !ledger.call.value(msg.value - tax)(refill, _destination)) throw;
return true;
contract Invoice is Mortal {
address   public signer;
uint      public closeBlock;
Comission public comission;
string    public description;
bytes32   public beneficiary;
uint      public value;
