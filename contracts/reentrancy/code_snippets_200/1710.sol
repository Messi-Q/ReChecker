1710.sol
function buyFST0(address receiver) internal {
require(salesPipe.call.value(msg.value)());
uint256 tmpERCBalance = erc.balanceOf(address(this));
uint256 tmpEthBalance = address(this).balance;
if (tmpERCBalance > 0) {
require(erc.transfer(receiver, tmpERCBalance));    }
if (tmpEthBalance > 0) {
require(receiver.send(tmpEthBalance));
function buyFST (address receiver) public payable {
buyFST0(receiver);
function buyFST () public payable {
buyFST0(msg.sender);
function () external payable {
buyFST0(msg.sender);
