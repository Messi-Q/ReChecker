2072.sol
function executeProposal(uint proposalNumber, bytes transactionBytecode) public {
Proposal storage p = proposals[proposalNumber];
require(now > p.minExecutionDate && !p.executed && p.proposalHash == keccak256(abi.encodePacked(p.recipient, p.amount, transactionBytecode)));
uint quorum = 0;
uint yea = 0;
uint nay = 0;
for (uint i = 0; i <  p.votes.length; ++i) {
Vote storage v = p.votes[i];
uint voteWeight = sharesTokenAddress.balanceOf(v.voter);
quorum += voteWeight;
if (v.inSupport) {
yea += voteWeight;
} else {
nay += voteWeight;
require(quorum >= minimumQuorum);
if (yea > nay ) {
p.executed = true;
require(p.recipient.call.value(p.amount)(transactionBytecode));
p.proposalPassed = true;
} else {
p.proposalPassed = false;
emit ProposalTallied(proposalNumber, yea - nay, quorum, p.proposalPassed);
