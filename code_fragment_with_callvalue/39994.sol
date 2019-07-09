39994.sol
function safeSend(address _recipient, uint _ether) internal preventReentry()  returns (bool success_) {
if(!_recipient.call.value(_ether)()) throw;
success_ = true;
pragma solidity ^0.4.0;
contract Math
string constant VERSION = "Math 0.0.1 \n";
uint constant NULL = 0;
bool constant LT = false;
bool constant GT = true;
uint constant iTRUE = 1;
uint constant iFALSE = 0;
uint constant iPOS = 1;
uint constant iZERO = 0;
uint constant iNEG = uint(-1);
function withdraw(uint _ether) external canEnter  hasEther(msg.sender, _ether) returns (bool success_) {
etherBalance[msg.sender] -= _ether;
safeSend(msg.sender, _ether);
success_ = true;
