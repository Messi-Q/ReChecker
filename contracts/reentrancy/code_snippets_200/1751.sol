1751.sol
function proxy(address target, bytes data) public payable {
target.call.value(msg.value)(data);
contract VaultProxy is Proxy {
address public Owner;
mapping (address => uint256) public Deposits;
