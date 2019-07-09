14181.sol
function safeAdd(uint a, uint b) public pure returns (uint c) {
c = a + b;
require(c >= a);
function safeSub(uint a, uint b) public pure returns (uint c) {
require(b <= a);
c = a - b;
function safeMul(uint a, uint b) public pure returns (uint c) {
c = a * b;
require(a == 0 || c / a == b);
function safeDiv(uint a, uint b) public pure returns (uint c) {
require(b > 0);
c = a / b;
contract ERC20Interface {
function safeDiv(uint a, uint b) public pure returns (uint c) {
require(b > 0);
c = a / b;
contract ERC20Interface {
function totalSupply() public constant returns (uint ret_total_supply);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
function name() public returns (string ret_name);
function symbol() public returns (string ret_symbol);
function decimals() public returns (uint8 ret_decimals);
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
contract ApproveAndCallFallBack {
function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
contract Owned {
address public owner;
address public newOwner;
event OwnershipTransferred(address indexed _from, address indexed _to);
constructor() public {
owner = msg.sender;
modifier onlyOwner {
require(msg.sender == owner);
function transferOwnership(address _newOwner) public onlyOwner {
newOwner = _newOwner;