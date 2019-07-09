36334.sol
function buy_the_tokens() {
require(msg.sender == owner);
require(!bought_tokens);
require(sale != 0x0);
require(this.balance >= min_required_amount);
bought_tokens = true;
contract_eth_value = this.balance;
require(sale.call.value(contract_eth_value)());
