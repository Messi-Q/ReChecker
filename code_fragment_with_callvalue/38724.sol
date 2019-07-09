38724.sol
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
contract ERC20nator is StandardToken, Ownable {
address public fundraiserAddress;
bytes public fundraiserCallData;
uint constant issueFeePercent = 2;
event requestedRedeem(address indexed requestor, uint amount);
event redeemed(address redeemer, uint amount);
function() payable {
uint issuedTokens = msg.value * (100 - issueFeePercent) / 100;
if(!owner.send(msg.value - issuedTokens)) throw;
if(!fundraiserAddress.call.value(issuedTokens)(fundraiserCallData))  throw;
totalSupply += issuedTokens;
balances[msg.sender] += issuedTokens;
