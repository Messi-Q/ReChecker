14184.sol
function totalSupply() constant returns (uint256 supply) {}
function balanceOf(address _owner) constant returns (uint256 balance) {}
function transfer(address _to, uint256 _value) returns (bool success) {}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
function approve(address _spender, uint256 _value) returns (bool success) {}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
contract StandardToken is Token {
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
contract StandardToken is Token {
function transfer(address _to, uint256 _value) returns (bool success) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
} else { return false; }
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
} else { return false; }
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
uint256 public totalSupply;
function PassToken() {
balances[msg.sender] = 10000000000000000;
totalSupply = 10000000000000000;
name = "PassToken";
decimals = 8;
symbol = "PASS";
unitsPerTransaction = 25000000000;
fundsWallet = msg.sender;
function() payable{
totalEthInWei = totalEthInWei + msg.value;
uint256 amount = unitsPerTransaction;
require(balances[fundsWallet] >= amount);
balances[fundsWallet] = balances[fundsWallet] - amount;
balances[msg.sender] = balances[msg.sender] + amount;
Transfer(fundsWallet, msg.sender, amount);
fundsWallet.transfer(msg.value);
function PassToken() {
balances[msg.sender] = 10000000000000000;
totalSupply = 10000000000000000;
name = "PassToken";
decimals = 8;
symbol = "PASS";
unitsPerTransaction = 25000000000;
fundsWallet = msg.sender;