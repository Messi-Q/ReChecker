14745.sol
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
contract token { function transfer(address receiver, uint amount){  } }
contract Crowdsale {
using SafeMath for uint256;
address public wallet;
address public addressOfTokenUsedAsReward;
uint256 public price = 14000;
token tokenReward;
uint256 public weiRaised;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
contract Crowdsale {
using SafeMath for uint256;
address public wallet;
address public addressOfTokenUsedAsReward;
uint256 public price = 14000;
token tokenReward;
uint256 public weiRaised;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);