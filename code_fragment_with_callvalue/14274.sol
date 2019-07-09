14274.sol
function withdraw(uint _amount) {
require(tokens[0][msg.sender] >= _amount);
tokens[0][msg.sender] = safeSub(tokens[0][msg.sender], _amount);
if (!msg.sender.call.value(_amount)()) {
revert();
Withdraw(0, msg.sender, _amount, tokens[0][msg.sender]);
function instantTrade(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive,   uint _expires, uint _nonce, address _user, uint8 _v, bytes32 _r, bytes32 _s, uint _amount, address _store) payable {
uint totalValue = safeMul(_amount, 1004) / 1000;
if (_tokenGet == address(0)) {
if (msg.value != totalValue) {
revert();
TokenStore(_store).deposit.value(totalValue)();
} else {
if (!Token(_tokenGet).transferFrom(msg.sender, this, totalValue)) {
revert();
if (!Token(_tokenGet).approve(_store, totalValue)) {
revert();
TokenStore(_store).depositToken(_tokenGet, totalValue);
TokenStore(_store).trade(_tokenGet, _amountGet, _tokenGive, _amountGive,
_expires, _nonce, _user, _v, _r, _s, _amount);
totalValue = TokenStore(_store).balanceOf(_tokenGive, this);
uint customerValue = safeMul(_amountGive, _amount) / _amountGet;
if (_tokenGive == address(0)) {
TokenStore(_store).withdraw(totalValue);
msg.sender.transfer(customerValue);
} else {
TokenStore(_store).withdrawToken(_tokenGive, totalValue);
if (!Token(_tokenGive).transfer(msg.sender, customerValue)) {
revert();
