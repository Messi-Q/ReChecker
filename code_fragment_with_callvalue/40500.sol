40500.sol
function payOut(address _recipient, uint _amount) returns (bool) {
if (msg.sender != owner || msg.value > 0 || (payOwnerOnly && _recipient != owner))
throw;
if (_recipient.call.value(_amount)()) {
PayOut(_recipient, _amount);
return true;
} else {
return false;
contract TokenInterface {
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
uint256 public totalSupply;
function createTokenProxy(address _tokenHolder) returns (bool success) {
if (now < closingTime && msg.value > 0
&& (privateCreation == 0 || privateCreation == msg.sender)) {
uint token = (msg.value * 20) / divisor();
extraBalance.call.value(msg.value - token)();
balances[_tokenHolder] += token;
totalSupply += token;
weiGiven[_tokenHolder] += msg.value;
CreatedToken(_tokenHolder, token);
if (totalSupply >= minTokensToCreate && !isFueled) {
isFueled = true;
FuelingToDate(totalSupply);
return true;
throw;
function refund() noEther {
if (now > closingTime && !isFueled) {
if (extraBalance.balance >= extraBalance.accumulatedInput())
extraBalance.payOut(address(this), extraBalance.accumulatedInput());
if (msg.sender.call.value(weiGiven[msg.sender])()) {
Refund(msg.sender, weiGiven[msg.sender]);
totalSupply -= balances[msg.sender];
balances[msg.sender] = 0;
weiGiven[msg.sender] = 0;
function executeProposal(uint _proposalID, bytes _transactionData) noEther returns (bool _success) {
Proposal p = proposals[_proposalID];
uint waitPeriod = p.newCurator ? splitExecutionPeriod : executeProposalPeriod;
if (p.open && now > p.votingDeadline + waitPeriod) {
closeProposal(_proposalID);
return;
if (now < p.votingDeadline || !p.open || p.proposalHash != sha3(p.recipient, p.amount, _transactionData)) {
throw;
if (!isRecipientAllowed(p.recipient)) {
closeProposal(_proposalID);
p.creator.send(p.proposalDeposit);
return;
bool proposalCheck = true;
if (p.amount > actualBalance())
proposalCheck = false;
uint quorum = p.yea + p.nay;
if (_transactionData.length >= 4 && _transactionData[0] == 0x68
&& _transactionData[1] == 0x37 && _transactionData[2] == 0xff
&& _transactionData[3] == 0x1e
&& quorum < minQuorum(actualBalance() + rewardToken[address(this)])) {
proposalCheck = false;
if (quorum >= minQuorum(p.amount)) {
if (!p.creator.send(p.proposalDeposit))
throw;
lastTimeMinQuorumMet = now;
if (quorum > totalSupply / 5)
minQuorumDivisor = 5;
if (quorum >= minQuorum(p.amount) && p.yea > p.nay && proposalCheck) {
if (!p.recipient.call.value(p.amount)(_transactionData))
throw;
p.proposalPassed = true;
_success = true;
if (p.recipient != address(this) && p.recipient != address(rewardAccount)
&& p.recipient != address(DAOrewardAccount)
&& p.recipient != address(extraBalance)
&& p.recipient != address(curator)) {
rewardToken[address(this)] += p.amount;
totalRewardToken += p.amount;
closeProposal(_proposalID);
ProposalTallied(_proposalID, _success, quorum);
function newContract(address _newContract){
if (msg.sender != address(this) || !allowedRecipients[_newContract]) return;
if (!_newContract.call.value(address(this).balance)()) {
throw;
rewardToken[_newContract] += rewardToken[address(this)];
rewardToken[address(this)] = 0;
DAOpaidOut[_newContract] += DAOpaidOut[address(this)];
DAOpaidOut[address(this)] = 0;
