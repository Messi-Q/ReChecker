14182.sol
function buyImplementation(address buyerAddress, uint64 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s)
private returns (bool)
bytes32 hash = sha256("Eidoo icoengine authorization", address(0), buyerAddress, buyerId, maxAmount);
address signer = ecrecover(hash, v, r, s);
if (!isKycSigner[signer]) {
revert();
} else {
uint256 totalPayed = alreadyPayed[buyerId].add(msg.value);
require(totalPayed <= maxAmount);
alreadyPayed[buyerId] = totalPayed;
emit KycVerified(signer, buyerAddress, buyerId, maxAmount);
return releaseTokensTo(buyerAddress);
contract RC is ICOEngineInterface, KYCBase {
using SafeMath for uint256;
TokenSale tokenSaleContract;
uint256 public startTime;
uint256 public endTime;
uint256 public etherMinimum;
uint256 public soldTokens;
uint256 public remainingTokens;
uint256 public oneTokenInFiatWei;
mapping(address => uint256) public etherUser;
mapping(address => uint256) public pendingTokenUser;
mapping(address => uint256) public tokenUser;
uint256[] public tokenThreshold;
uint256[] public bonusThreshold;
function RC(address _tokenSaleContract, uint256 _oneTokenInFiatWei, uint256 _remainingTokens, uint256 _etherMinimum, uint256 _startTime , uint256 _endTime, address [] kycSigner, uint256[] _tokenThreshold, uint256[] _bonusThreshold ) public KYCBase(kycSigner) {
require ( _tokenSaleContract != 0 );
require ( _oneTokenInFiatWei != 0 );
require( _remainingTokens != 0 );
require ( _tokenThreshold.length != 0 );
require ( _tokenThreshold.length == _bonusThreshold.length );
bonusThreshold = _bonusThreshold;
tokenThreshold = _tokenThreshold;
tokenSaleContract = TokenSale(_tokenSaleContract);
tokenSaleContract.addMeByRC();
soldTokens = 0;
remainingTokens = _remainingTokens;
oneTokenInFiatWei = _oneTokenInFiatWei;
etherMinimum = _etherMinimum;
setTimeRC( _startTime, _endTime );