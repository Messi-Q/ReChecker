4598.sol
function futrMiner() public payable {
require(futr.call.value(msg.value)());
uint256 mined = ERC20(futr).balanceOf(address(this));
ERC20(futr).approve(mny, mined);
MNY(mny).mine(futr, mined);
uint256 amount = ERC20(mny).balanceOf(address(this));
ERC20(mny).transfer(msg.sender, amount);
function futxMiner() public payable {
require(futx.call.value(msg.value)());
uint256 mined = ERC20(futx).balanceOf(address(this));
ERC20(futx).approve(mny, mined);
MNY(mny).mine(futx, mined);
uint256 amount = ERC20(mny).balanceOf(address(this));
ERC20(mny).transfer(msg.sender, amount);
