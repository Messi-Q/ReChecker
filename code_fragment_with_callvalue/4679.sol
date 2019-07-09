4679.sol
function giveToken(address _buyer) internal {
require( pendingTokenUser[_buyer] > 0, "pendingTokenUser[_buyer] > 0" );
tokenUser[_buyer] = tokenUser[_buyer].add(pendingTokenUser[_buyer]);
tokenSaleContract.sendTokens(_buyer, pendingTokenUser[_buyer]);
soldTokens = soldTokens.add(pendingTokenUser[_buyer]);
pendingTokenUser[_buyer] = 0;
require( address(tokenSaleContract).call.value( etherUser[_buyer] )( bytes4( keccak256("forwardEther()") ) ) );
etherUser[_buyer] = 0;
function forwardEther() onlyRC payable public returns(bool) {
require(milestoneSystem.call.value(msg.value)(), "wallet.call.value(msg.value)()");
return true;
