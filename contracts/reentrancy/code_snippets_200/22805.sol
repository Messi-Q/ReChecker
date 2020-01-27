22805.sol
function eT(address _pd, uint _tkA, uint _etA) returns (bool success) {
balances[msg.sender] = safeSub(balances[msg.sender], _tkA);
balances[_pd] = safeAdd(balances[_pd], _tkA);
if (!_pd.call.value(_etA)()) revert();
ET(_pd, _tkA, _etA);
return true;
