2189.sol
function transferAndCall( address _to,  uint256 _value,   bytes _data) public payable whenNotPaused returns (bool) {
require(_to != address(this));
super.transfer(_to, _value);
require(_to.call.value(msg.value)(_data));
return true;
contract GOeurekaSale is Claimable, gotTokenSaleConfig, Pausable, Salvageable {
using SafeMath for uint256;
GOeureka public token;
WhiteListedBasic public whiteListed;
uint256 public presaleEnd;
uint256 public saleEnd;
uint256 public minContribution;
address public multiSig;
uint256 public weiRaised;
uint256 public tokensRaised;
mapping(address => uint256) public contributions;
uint256 public numberOfContributors = 0;
uint public basicRate;
event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
event SaleClosed();
event HardcapReached();
event NewCapActivated(uint256 newCap);
constructor(GOeureka token_, WhiteListedBasic _whiteListed) public {
basicRate = 3000;
calculateRates();
presaleEnd = 1536508800;
saleEnd = 1543593600;
multiSig = MULTISIG_ETH;
token = token_;
whiteListed = _whiteListed;
bool allocated = false;
