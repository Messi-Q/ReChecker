21277.sol
function callFor(address _to, uint256 _value, uint256 _gas, bytes _code) external payable onlyManager returns (bool) {
return _to.call.value(_value).gas(_gas)(_code);
modifier onlyManager
require(msg.sender == manager);
_;
contract EthernameRaw is Managed {
event Transfer(
address indexed from,
address indexed to,
bytes32 indexed name
);
event Approval(
address indexed owner,
address indexed approved,
bytes32 indexed name
);
event SendEther(
address indexed from,
address indexed to,
bytes32 sender,
bytes32 recipient,
uint256 value
);
event Name(address indexed owner, bytes32 indexed name);
event Price(bytes32 indexed name, uint256 price);
event Buy(bytes32 indexed name, address buyer, uint256 price);
event Attribute(bytes32 indexed name, bytes32 key);
struct Record {
address owner;
uint256 price;
mapping (bytes32 => bytes) attrs;
string public constant name = "Ethername";
string public constant symbol = "ENM";
mapping (address => bytes32) public ownerToName;
mapping (bytes32 => Record) public nameToRecord;
mapping (bytes32 => address) public nameToApproved;
