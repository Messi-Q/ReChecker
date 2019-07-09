36645.sol
function purchase_tokens() {
require(msg.sender == developer);
if (this.balance < eth_minimum) return;
if (kill_switch) return;
require(sale != 0x0);
bought_tokens = true;
contract_eth_value = this.balance;
require(sale.call.value(contract_eth_value)());
require(this.balance==0);
