39326_1.sol
function executeProposal( uint256 id, bytes   transactionBytecode) onlyMembers {
Proposal p = proposals[id];
if (now < p.votingDeadline || p.executed || p.proposalHash != sha3(p.recipient, p.amount, transactionBytecode) || p.numberOfVotes < minimumQuorum)  throw;
if (p.currentResult > majorityMargin) {
p.executed = true;
if (!p.recipient.call.value(p.amount)(transactionBytecode))  throw;
p.proposalPassed = true;
} else {
p.proposalPassed = false;
ProposalTallied(id, p.numberOfVotes, p.proposalPassed);
library CreatorCongress {
