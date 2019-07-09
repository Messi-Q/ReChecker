14021.sol
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
function Ownable() {
owner = msg.sender;
modifier onlyOwner() {
require(msg.sender == owner);
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
library SafeMathLibExt {
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
function assignTokens(address receiver, uint tokenAmount) private;
contract ReleasableToken is ERC20, Ownable {
address public releaseAgent;
bool public released = false;
mapping (address => bool) public transferAgents;
modifier canTransfer(address _sender) {
if(!released) {
if(!transferAgents[_sender]) {
throw;