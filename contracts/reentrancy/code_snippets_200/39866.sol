39866.sol
function funding() payable {
if(fundingLock||block.number<startBlock||block.number>startBlock+blockDuration) throw;
if(balances[msg.sender]>balances[msg.sender]+msg.value*fundingExchangeRate || msg.value>msg.value*fundingExchangeRate) throw;
if(!fundingAccount.call.value(msg.value)()) throw;
balances[msg.sender]+=msg.value*fundingExchangeRate;
Funding(msg.sender,msg.value);
function buy(string _commit) payable{
if(balances[msg.sender]>balances[msg.sender]+msg.value*price || msg.value>msg.value*price) throw;
if(!fundingAccount.call.value(msg.value)()) throw;
balances[msg.sender]+=msg.value*price;
commit[msg.sender]=_commit;
Buy(msg.sender,msg.value);
