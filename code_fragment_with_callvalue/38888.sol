38888.sol
function withdraw() onlyOwner {
if (!owner.call.value(this.balance)()) throw;
