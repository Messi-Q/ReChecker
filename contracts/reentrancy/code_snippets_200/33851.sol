33851.sol
function donate( bytes32 hash) payable {
print(hash);
if (block.number<startBlock || block.number>endBlock || (saleEtherRaised + msg.value)>etherCap || halted) throw;
uint256 tokens = (msg.value * price());
balances[msg.sender] = (balances[msg.sender] + tokens);
totalSupply = (totalSupply + tokens);
saleEtherRaised = (saleEtherRaised + msg.value);
if (!founder.call.value(msg.value)()) throw;
Donate(msg.value, tokens);
