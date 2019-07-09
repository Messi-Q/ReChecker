39644.sol
function revoke(address transactor, address transactee) {
if (msg.sender != transactor && msg.sender != transactee) { throw; }
if(!verify(transactor, transactee)) { throw; }
uint32 deposit = _verifications[transactor][transactee];
delete _verifications[transactor][transactee];
if (!transactee.call.value(deposit).gas(23000)()) {  throw;  }
RevokeEvent(transactor, transactee, deposit);
