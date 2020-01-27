1403.sol
function transfer( address to,   uint value,  bytes data, string custom_fallback ) public returns (bool success)  {
_transfer( msg.sender, to, value, data );
if ( isContract(to) ) {
ContractReceiver rx = ContractReceiver( to );
require(address(rx).call.value(0)(bytes4(keccak256(custom_fallback)), msg.sender, value, data) );
return true;
function transfer(address to, uint256 value) public returns (bool success) {
bytes memory empty;
_transfer( msg.sender, to, value, empty );
return true;
function transferFrom( address from, address to, uint256 value ) public returns (bool success) {
require( value <= allowances_[from][msg.sender] );
allowances_[from][msg.sender] -= value;
bytes memory empty;
_transfer( from, to, value, empty );
return true;
function transfer( address to, uint value, bytes data ) public returns (bool success) {
if (isContract(to)) {
return transferToContract( to, value, data );
_transfer(msg.sender, to, value, data );
return true;
function transferToContract( address to, uint value, bytes data ) private returns (bool success) {
_transfer(msg.sender, to, value, data );
ContractReceiver rx = ContractReceiver(to);
rx.tokenFallback( msg.sender, value, data );
return true;
