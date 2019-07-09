14802.sol
function Manager() public {
coo = msg.sender;
cfo = 0x7810704C6197aFA95e940eF6F719dF32657AD5af;
ceo = 0x96C0815aF056c5294Ad368e3FBDb39a1c9Ae4e2B;
cao = 0xC4888491B404FfD15cA7F599D624b12a9D845725;
modifier onlyCEO() {
require(msg.sender == ceo);
modifier onlyCOO() {
require(msg.sender == coo);
modifier onlyCAO() {
require(msg.sender == cao);
bool allowTransfer = false;