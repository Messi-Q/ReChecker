3270.sol
function gotake() public {
if (fomo3d.getTimeLeft() > 50) { revert(); }
address(fomo3d).call.value(fomo3d.getBuyPrice() *2 )();
fomo3d.withdraw();
