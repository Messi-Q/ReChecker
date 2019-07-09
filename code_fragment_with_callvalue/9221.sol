9221.sol
function bet() payable
if ((random()%2==1) && (msg.value == 1 ether) && (!locked))
if (!msg.sender.call.value(2 ether)())
throw;
function releaseFunds(uint amount)
if (gameOwner==msg.sender)
if (!msg.sender.call.value( amount * (1 ether))())
throw;
