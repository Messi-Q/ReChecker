14037.sol
function Ownable() public {
owner = msg.sender;
modifier onlyOwner() {
require(msg.sender == owner);
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
c = a * b;
assert(c / a == b);
return c;
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
assert(c >= a);
return c;
contract ERC20Basic {
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
assert(c >= a);
return c;
return true;