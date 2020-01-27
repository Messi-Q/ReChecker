30460.sol
function close() onlyOwner public {
require(state == State.Active);
state = State.Closed;
Closed();
wallet.call.value(this.balance)();
function forwardFunds() onlyOwner public {
require(this.balance > 0);
wallet.call.value(this.balance)();
contract FinalizableCrowdsale is BurnableCrowdsale, Ownable {
using SafeMath for uint256;
bool public isFinalized = false;
event Finalized();
function forwardFundsToWallet(uint256 amount) internal {
if (goalReached() && vault.balance > 0) {
vault.forwardFunds();
if (goalReached()) {
wallet.call.value(amount)();
} else {
vault.deposit.value(amount)(msg.sender);
