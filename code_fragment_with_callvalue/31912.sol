31912.sol
function serveTx(WalletData storage self,  address _to, uint256 _value,  bytes _txData,  bool _confirm,    bytes _data)  public returns (bool,bytes32)  {
bytes32 _id = keccak256("serveTx",_to,_value,_txData);
uint256 _txIndex = self.transactionInfo[_id].length;
uint256 _required = self.requiredMajor;
if(msg.sender != address(this)){
bool allGood;
uint256 _amount;
if(!_confirm) {
allGood = revokeConfirm(self, _id);
return (allGood,_id);
} else {
if(_to != 0)
(allGood,_amount) = getAmount(_txData);
if(_txIndex == 0 || self.transactionInfo[_id][_txIndex - 1].success){
require(self.ownerIndex[msg.sender] > 0);
_required = getRequired(self, _to, _value, allGood,_amount);
self.transactionInfo[_id].length++;
self.transactionInfo[_id][_txIndex].confirmRequired = _required;
self.transactionInfo[_id][_txIndex].day = now / 1 days;
self.transactions[now / 1 days].push(_id);
} else {
_txIndex--;
allGood = checkNotConfirmed(self, _id, _txIndex);
if(!allGood)
return (false,_id);
self.transactionInfo[_id][_txIndex].confirmedOwners.push(uint256(msg.sender));
self.transactionInfo[_id][_txIndex].confirmCount++;
} else {
_txIndex--;
if(self.transactionInfo[_id][_txIndex].confirmCount ==  self.transactionInfo[_id][_txIndex].confirmRequired) {
self.currentSpend[0][1] += _value;
self.currentSpend[_to][1] += _amount;
self.transactionInfo[_id][_txIndex].success = true;
if(_to == 0){
createContract(_txData, _value);
} else {
require(_to.call.value(_value)(_txData));
delete self.transactionInfo[_id][_txIndex].data;
LogTransactionComplete(_id, _to, _value, _data);
} else {
if(self.transactionInfo[_id][_txIndex].data.length == 0)
self.transactionInfo[_id][_txIndex].data = _data;
uint256 confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_txIndex].confirmRequired, self.transactionInfo[_id][_txIndex].confirmCount);
LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
return (true,_id);
