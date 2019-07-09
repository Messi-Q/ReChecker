14814.sol
contract SEKCapitalToken is SafeStandardToken{
string public constant name = "SEK Capital Token";
string public constant symbol = "SEKCC";
uint256 public constant decimals = 18;
uint256 public constant INITIAL_SUPPLY = 300000000 * (10 ** uint256(decimals));
function decreaseApproval (address _spender, uint _subtractedValue) public
returns (bool success) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;