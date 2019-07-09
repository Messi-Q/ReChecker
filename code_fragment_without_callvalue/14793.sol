14793.sol
function safeMul(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
assert(b > 0);
uint256 c = a / b;
assert(a == b * c + a % b);
return c;
function safeSub(uint256 a, uint256 b) internal returns (uint256) {
assert(b <= a);
return a - b;
function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a + b;
assert(c>=a && c>=b);
return c;
function assert(bool assertion) internal {
if (!assertion) {
throw;
contract ElectronicMusic is SafeMath {
string public name = "Electronic Music";
string public symbol = "EM";
uint8 public decimals = 18;
uint256 public totalSupply = 100000000e18;
address public owner;
mapping (address => uint256) public balanceOf;
mapping (address => uint256) public freezeOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
event Freeze(address indexed from, uint256 value);
event Unfreeze(address indexed from, uint256 value);
contract ElectronicMusic is SafeMath {
string public name = "Electronic Music";
string public symbol = "EM";
uint8 public decimals = 18;
uint256 public totalSupply = 100000000e18;
address public owner;
mapping (address => uint256) public balanceOf;
mapping (address => uint256) public freezeOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
event Freeze(address indexed from, uint256 value);
event Unfreeze(address indexed from, uint256 value);
function assert(bool assertion) internal {
if (!assertion) {
throw;