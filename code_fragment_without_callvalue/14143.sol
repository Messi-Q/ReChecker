14143.sol
function transfer(address _to, uint256 _value) isRunning isValidAddress public returns (bool success) {
require(balanceOf[msg.sender] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
emit Transfer(msg.sender, _to, _value);
return true;
function transferFrom(address _from, address _to, uint256 _value) isRunning isValidAddress public returns (bool success) {
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
require(allowance[_from][msg.sender] >= _value);
balanceOf[_to] += _value;
balanceOf[_from] -= _value;
allowance[_from][msg.sender] -= _value;
emit Transfer(_from, _to, _value);
return true;
function approve(address _spender, uint256 _value) isRunning isValidAddress public returns (bool success) {
require(_value == 0 || allowance[msg.sender][_spender] == 0);
allowance[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
function stop() isOwner public {
stopped = true;
function setName(string _name) isOwner public {
name = _name;
function airdrop(address[] _DACusers,uint256[] _values) isRunning public {
require(_DACusers.length > 0);
require(_DACusers.length == _values.length);
uint256 amount = 0;
uint i = 0;
for (i = 0; i < _DACusers.length; i++) {
require(amount + _values[i] >= amount);
amount += _values[i];
require(balanceOf[msg.sender] >= amount);
balanceOf[msg.sender] -= amount;
for (i = 0; i < _DACusers.length; i++) {
require(balanceOf[_DACusers[i]] + _values[i] >= balanceOf[_DACusers[i]]);
balanceOf[_DACusers[i]] += _values[i];
emit Transfer(msg.sender, _DACusers[i], _values[i]);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);