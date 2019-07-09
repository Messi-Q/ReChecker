14750.sol
function subscribe() external;
function unsubscribe() external;
function trade(address[3] addresses, uint[4] values, bytes signature, uint maxFillAmount) external;
function cancel(address[3] addresses, uint[4] values) external;
function order(address[2] addresses, uint[4] values) external;
function canTrade(address[3] addresses, uint[4] values, bytes signature) external view
returns (bool);
function isSubscribed(address subscriber) external view returns (bool);
function availableAmount(address[3] addresses, uint[4] values) external view returns (uint);
function filled(bytes32 hash) external view returns (uint);
function isOrdered(address user, bytes32 hash) public view returns (bool);
function vault() public view returns (VaultInterface);
interface VaultInterface {
event Deposited(address indexed user, address token, uint amount);
event Withdrawn(address indexed user, address token, uint amount);
event Approved(address indexed user, address indexed spender);
event Unapproved(address indexed user, address indexed spender);
event AddedSpender(address indexed spender);
event RemovedSpender(address indexed spender);
function vault() public view returns (VaultInterface);
struct Order {
address maker;
address makerToken;
address takerToken;
uint makerTokenAmount;
uint takerTokenAmount;
uint expires;
uint nonce;
function isValidSignature(bytes32 hash, address signer, bytes signature) internal pure returns (bool) {
require(signature.length == 66);
SignatureMode mode = SignatureMode(uint8(signature[0]));
uint8 v = uint8(signature[1]);
bytes32 r;
bytes32 s;
assembly {
r := mload(add(signature, 34))
s := mload(add(signature, 66))
if (mode == SignatureMode.GETH) {
hash = keccak256("\x19Ethereum Signed Message:\n32", hash);
} else if (mode == SignatureMode.TREZOR) {
hash = keccak256("\x19Ethereum Signed Message:\n\x20", hash);
return ecrecover(hash, v, r, s) == signer;
library OrderLibrary {
bytes32 constant public HASH_SCHEME = keccak256(
"address Taker Token",
"uint Taker Token Amount",
"address Maker Token",
"uint Maker Token Amount",
"uint Expires",
"uint Nonce",
"address Maker",
"address Exchange"
);