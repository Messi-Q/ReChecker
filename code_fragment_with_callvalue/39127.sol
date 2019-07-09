39127.sol
function executeProposal(uint256 _proposalID, bytes _transactionBytecode) onlyCongressMembers {
Proposal p = proposals[_proposalID];
if (p.state != ProposalState.Passed) throw;
p.state = ProposalState.Executed;
if (!p.beneficiary.call.value(p.etherAmount * 1 ether)(_transactionBytecode)) { throw; }
ProposalExecutedEvent(_proposalID);
