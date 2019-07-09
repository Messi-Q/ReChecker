14342.sol
function AccessAdmin() public {
addrAdmin = msg.sender;
modifier onlyAdmin() {
require(msg.sender == addrAdmin);
modifier whenNotPaused() {
require(!isPaused);
modifier whenPaused {
require(isPaused);
function doUnpause() external onlyAdmin whenPaused {
isPaused = false;
contract AccessService is AccessAdmin {
address public addrService;
address public addrFinance;
modifier onlyService() {
require(msg.sender == addrService);
modifier onlyFinance() {
require(msg.sender == addrFinance);
function setService(address _newService) external {
require(msg.sender == addrService || msg.sender == addrAdmin);
require(_newService != address(0));
addrService = _newService;
interface IDataMining {
function withdraw(address _target, uint256 _amount)
external
require(msg.sender == addrFinance || msg.sender == addrAdmin);
require(_amount > 0);
address receiver = _target == address(0) ? addrFinance : _target;
uint256 balance = this.balance;
if (_amount < balance) {
receiver.transfer(_amount);
} else {
receiver.transfer(this.balance);