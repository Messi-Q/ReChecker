6881.sol
function buyOne(ERC20 token, address _exchange, uint256 _value, bytes _data) payable public {
balances[msg.sender] = balances[msg.sender].add(msg.value);
uint256 tokenBalance = token.balanceOf(this);
require(_exchange.call.value(_value)(_data));
balances[msg.sender] = balances[msg.sender].sub(_value);
tokenBalances[msg.sender][token] = tokenBalances[msg.sender][token].add(token.balanceOf(this).sub(tokenBalance));
