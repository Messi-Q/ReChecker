9920.sol
function tryExec(address target, bytes calldata, uint value) internal returns (bool call_ret){
return target.call.value(value)(calldata);
function exec(address target, bytes calldata, uint value) internal {
if(!tryExec(target, calldata, value)) {
throw;
function tryExec( address t, bytes c ) internal returns (bool) {
return tryExec(t, c, 0);
function tryExec( address t, uint256 v ) internal returns (bool) {
bytes memory c; return tryExec(t, c, v);
contract DSMath {
