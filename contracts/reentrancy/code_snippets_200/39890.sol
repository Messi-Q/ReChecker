39890.sol
function authorizePayment(uint _idMilestone) internal {
if (_idMilestone >= milestones.length) throw;
Milestone milestone = milestones[_idMilestone];
if (milestone.status == MilestoneStatus.AuthorizedForPayment) throw;
milestone.status = MilestoneStatus.AuthorizedForPayment;
if(!milestone.paymentSource.call.value(0)(milestone.payData)) throw;
ProposalStatusChanged(_idMilestone, milestone.status);
function approveCompletedMilestone(uint _idMilestone) campaignNotCanceled notChanging {
if (_idMilestone >= milestones.length) throw;
Milestone milestone = milestones[_idMilestone];
if ((msg.sender != milestone.reviewer) ||(milestone.status != MilestoneStatus.Completed)) throw;
authorizePayment(_idMilestone);
function requestMilestonePayment(uint _idMilestone) campaignNotCanceled notChanging {
if (_idMilestone >= milestones.length) throw;
Milestone milestone = milestones[_idMilestone];
if ((msg.sender != milestone.milestoneLeadLink)&&(msg.sender != recipient))  throw;
if ((milestone.status != MilestoneStatus.Completed) || (now < milestone.doneTime + milestone.reviewTime)) throw;
authorizePayment(_idMilestone);
function arbitrateApproveMilestone(uint _idMilestone) onlyArbitrator campaignNotCanceled notChanging {
if (_idMilestone >= milestones.length) throw;
Milestone milestone = milestones[_idMilestone];
if ((milestone.status != MilestoneStatus.AcceptedAndInProgress) && (milestone.status != MilestoneStatus.Completed)) throw;
authorizePayment(_idMilestone);
