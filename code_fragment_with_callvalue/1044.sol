1044.sol
function donateToWhale(uint256 amount) internal {
whale.call.value(amount)(bytes4(keccak256("donate()")));
totalDonated += amount;
emit Donate(amount, whale, msg.sender);
function loseWager(uint256 amount) internal {
whale.call.value(amount)(bytes4(keccak256("donate()")));
totalDonated += amount;
emit Lose(amount, msg.sender);
