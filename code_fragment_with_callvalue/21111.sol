21111.sol
function submitPool(uint amountInWei) public onlyOwner noReentrancy {
require(contractStage < 3);
require(receiverAddress != 0x00);
require(block.number >= addressChangeBlock.add(6000));
require(contributionMin <= amountInWei && amountInWei <= this.balance);
finalBalance = this.balance;
require(receiverAddress.call.value(amountInWei).gas(msg.gas.sub(5000))());
if (this.balance > 0) ethRefundAmount.push(this.balance);
contractStage = 3;
PoolSubmitted(receiverAddress, amountInWei);
