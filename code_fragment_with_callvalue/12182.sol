12182.sol
function transferEther(address to, uint256 amount) public returns (bool) {
require(msg.sender == owner);
return to.call.value(amount)();
function() public payable {}
contract Controller is ControllerStorage, Ownable, HasWorkers {
event CreatedUserWallet(address _wallet);
event WithdrawEth(address _wallet, address _to, uint256 _amount);
event WithdrawToken(address _token, address _wallet, address _to, uint256 _amount);
event ChangedForward(address _old, address _new, address _operator);
constructor() public {
setForward(msg.sender);
function executeTransaction(address destination, uint256 value, bytes memory _bytes) public onlyOwner returns (bool) {
return destination.call.value(value)(_bytes);
function withdrawEthBatch(Wallet[] wallets) public onlyWorker returns (bool) {
uint256 size = wallets.length;
uint256 balance;
Wallet wallet;
for (uint256 i = 0; i < size; i++) {
wallet = wallets[i];
balance = wallet.balance;
if (wallet.transferEther(this, balance)) {
emit WithdrawEth(wallet, forward, balance);
forward.call.value(address(this).balance)();
return true;
