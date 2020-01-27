36732.sol
function claim_bounty(){
if (this.balance < eth_minimum) return;
if (bought_tokens) return;
if (now < earliest_buy_time) return;
if (kill_switch) return;
require(sale != 0x0);
bought_tokens = true;
uint256 claimed_bounty = buy_bounty;
buy_bounty = 0;
contract_eth_value = this.balance - (claimed_bounty + withdraw_bounty);
require(sale.call.value(contract_eth_value)());
msg.sender.transfer(claimed_bounty);
