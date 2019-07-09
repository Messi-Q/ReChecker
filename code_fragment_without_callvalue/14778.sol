14778.sol
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
contract Ownable {
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
library SafeMathLibExt {
function times(uint a, uint b) returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
function divides(uint a, uint b) returns (uint) {
assert(b > 0);
uint c = a / b;
assert(a == b * c + a % b);
return c;
function minus(uint a, uint b) returns (uint) {
assert(b <= a);
return a - b;
function plus(uint a, uint b) returns (uint) {
uint c = a + b;
assert(c>=a);
return c;