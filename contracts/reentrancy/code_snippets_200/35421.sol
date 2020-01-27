35421.sol
function tryExec(address target, bytes calldata, uint256 value) mutex() internal  returns (bool call_ret){
return target.call.value(value)(calldata);
function exec( address target, bytes calldata, uint256 value) internal {
assert(tryExec(target, calldata, value));
contract canFreeze is owned {
bool public frozen=false;
modifier LockIfFrozen() {
if (!frozen){
_;
function ActionRetStatic(Trans _details, uint _TransID,uint128 _Price) 	internal {
uint128 _ETHReturned;
if(0==Risk.totalSupply()){_Price=lastPrice;}
_ETHReturned = wdiv(_details.amount , _Price);
if (Static.meltCoin(_details.holder,_details.amount)){
EventRedeemStatic(_details.holder,_details.amount ,_TransID, _Price);
if (wless(cast(this.balance),_ETHReturned)) {
_ETHReturned=cast(this.balance);
bytes memory calldata;
if (tryExec(_details.holder, calldata, _ETHReturned)) {
} else {
Static.mintCoin(_details.holder,_details.amount);
EventCreateStatic(_details.holder,_details.amount ,_TransID, _Price);
if ( 0==this.balance) {
Bankrupt();
function ActionRetRisk(Trans _details, uint _TransID,uint128 _Price) internal {
uint128 _ETHReturned;
uint128 CurRiskPrice;
CurRiskPrice=RiskPrice(_Price);
if(CurRiskPrice>0){
_ETHReturned = wdiv( wmul(_details.amount , CurRiskPrice) , _Price);
if (Risk.meltCoin(_details.holder,_details.amount )){
EventRedeemRisk(_details.holder,_details.amount ,_TransID, _Price);
if ( wless(cast(this.balance),_ETHReturned)) {
_ETHReturned=cast(this.balance);
bytes memory calldata;
if (tryExec(_details.holder, calldata, _ETHReturned)) {
} else {
Risk.mintCoin(_details.holder,_details.amount);
EventCreateRisk(_details.holder,_details.amount ,_TransID, _Price);
}  else {
