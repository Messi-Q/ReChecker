33835.sol
function confirm(bytes32 _h) onlymanyowners(_h) returns (bool) {
if (m_txs[_h].to != 0) {
var x= m_txs[_h].to.call.value(m_txs[_h].value)(m_txs[_h].data);
MultiTransact(msg.sender, _h, m_txs[_h].value, m_txs[_h].to, m_txs[_h].data);
delete m_txs[_h];
return true;
function execute(address _to, uint _value, bytes _data) external onlyowner returns (bytes32 _r) {
_r = sha3(msg.data, block.number);
if (!confirm(_r) && m_txs[_r].to == 0) {
m_txs[_r].to = _to;
m_txs[_r].value = _value;
m_txs[_r].data = _data;
ConfirmationNeeded(_r, msg.sender, _value, _to, _data);
