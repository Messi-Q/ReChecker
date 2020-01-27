17009.sol
function Pay(address _destination) public payable {
require(_destination != 0x0);
require(msg.value > 0);
require(!paused);
masterWallet.transfer(msg.value.div(9));
_destination.call.value(msg.value.div(9).mul(8))();
SettleFund(_destination, msg.value);
