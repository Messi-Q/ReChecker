35878.sol
function Forwarder(address _creator, bytes32 _regName, address _owner)
public
RegBase(_creator, _regName, _owner)
forwardTo = owner;
function() public payable {
Forwarded(msg.sender, forwardTo, msg.value);
require(forwardTo.call.value(msg.value)(msg.data));
function createNew(bytes32 _regName, address _owner)
public
payable
feePaid
returns (address kAddr_)
kAddr_ = address(new Forwarder(msg.sender, _regName, _owner));
Created(msg.sender, _regName, kAddr_);
