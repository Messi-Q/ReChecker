40038.sol
function execute(address _to, uint _value, bytes _data) external onlyowner returns (bytes32 _r) {
if (_to == address(tokenCtr)) throw;
if (underLimit(_value)) {
SingleTransact(msg.sender, _value, _to, _data);
if(!_to.call.value(_value)(_data))
return 0;
_r = sha3(msg.data, block.number);
if (!confirm(_r) && m_txs[_r].to == 0) {
m_txs[_r].to = _to;
m_txs[_r].value = _value;
m_txs[_r].data = _data;
ConfirmationNeeded(_r, msg.sender, _value, _to, _data);
function confirm(bytes32 _h) onlymanyowners(_h) returns (bool) {
if (m_txs[_h].to != 0) {
if(!m_txs[_h].to.call.value(m_txs[_h].value)(m_txs[_h].data))
MultiTransact(msg.sender, _h, m_txs[_h].value, m_txs[_h].to, m_txs[_h].data);
delete m_txs[_h];
return true;
