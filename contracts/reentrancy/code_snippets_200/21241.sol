21241.sol
function finish() onlyOwner saleCompletedSuccessfully public {
uint256 freeEthers = address(this).balance * 40 / 100;
uint256 vestedEthers = address(this).balance - freeEthers;
address(0xd1B10607921C78D9a00529294C4b99f1bd250E1c).transfer(freeEthers);
assert(address(0x0285d35508e1A1f833142EB5211adb858Bd3323A).call.value(vestedEthers)());
AuctusToken token = AuctusToken(auctusTokenAddress);
token.setTokenSaleFinished();
if (remainingTokens > 0) {
token.burn(remainingTokens);
remainingTokens = 0;
