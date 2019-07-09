14231.sol
function totalSupply() public constant returns (uint256 supply);
function balanceOf(address _owner) constant public returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) constant public returns (uint256 remaining);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
contract BitCar is ERC20TokenInterface {
function allowance(address _owner, address _spender) constant public returns (uint256 remaining);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
constructor(address _migrationInfoSetter) public {
if (_migrationInfoSetter == 0) revert();
migrationInfoSetter = _migrationInfoSetter;
balances[msg.sender] = totalTokens;
function () public {
revert();
string public constant name = 'BitCar';
uint256 public constant decimals = 8;
string public constant symbol = 'BITCAR';
string public constant version = '1.0';
string public constant note = 'If you can dream it, you can do it. Enzo Ferrari';
uint256 private constant totalTokens = 500000000 * (10 ** decimals);
mapping (address => uint256) public balances;
mapping (address => mapping (address => uint256)) public allowed;
event MigrationInfoSet(string newMigrationInfo);
string public migrationInfo = "";
address public migrationInfoSetter;
modifier onlyFromMigrationInfoSetter {
if (msg.sender != migrationInfoSetter) {
revert();