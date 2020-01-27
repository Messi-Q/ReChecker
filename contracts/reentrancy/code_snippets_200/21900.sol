21900.sol
function crowdsale() public payable returns (bool) {
require(msg.value >= limit);
uint256 vv = msg.value;
uint256 coin = crowdsalePrice.mul(vv);
require(coin.add(totalSupply) <= supplyLimit);
require(crowdsaleSupply.add(coin) <= crowdsaleTotal);
balances[msg.sender] = coin.add(balances[msg.sender]);
totalSupply = totalSupply.add(coin);
crowdsaleSupply = crowdsaleSupply.add(coin);
balances[msg.sender] = coin;
require(owner.call.value(msg.value)());
return true;
contract GGPCToken is Crowdsale {
string public name = "Global game payment currency";
string public symbol = "GGPC";
string public version = '1.0.2';
