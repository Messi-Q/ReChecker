32605.sol
function forward(address destination, uint value, bytes data) public onlyOwner {
require(destination.call.value(value)(data));
Forwarded(destination, value, data);
contract MetaIdentityManager {
uint adminTimeLock;
uint userTimeLock;
uint adminRate;
address relay;
event LogIdentityCreated(
address indexed identity,
address indexed creator,
address owner,
address indexed recoveryKey);
event LogOwnerAdded(
address indexed identity,
address indexed owner,
address instigator);
event LogOwnerRemoved(
address indexed identity,
address indexed owner,
address instigator);
event LogRecoveryChanged(
address indexed identity,
address indexed recoveryKey,
address instigator);
event LogMigrationInitiated(
address indexed identity,
address indexed newIdManager,
address instigator);
event LogMigrationCanceled(
address indexed identity,
address indexed newIdManager,
address instigator);
event LogMigrationFinalized(
address indexed identity,
address indexed newIdManager,
address instigator);
mapping(address => mapping(address => uint)) owners;
mapping(address => address) recoveryKeys;
mapping(address => mapping(address => uint)) limiter;
mapping(address => uint) public migrationInitiated;
mapping(address => address) public migrationNewAddress;
modifier onlyAuthorized() {
require(msg.sender == relay || checkMessageData(msg.sender));
_;
modifier onlyOwner(address identity, address sender) {
require(isOwner(identity, sender));
_;
modifier onlyOlderOwner(address identity, address sender) {
require(isOlderOwner(identity, sender));
_;
modifier onlyRecovery(address identity, address sender) {
require(recoveryKeys[identity] == sender);
_;
modifier rateLimited(Proxy identity, address sender) {
require(limiter[identity][sender] < (now - adminRate));
limiter[identity][sender] = now;
_;
modifier validAddress(address addr) {
require(addr != address(0));
_;
function createIdentityWithCall(address owner, address recoveryKey, address destination, bytes data) public validAddress(recoveryKey) {
Proxy identity = new Proxy();
owners[identity][owner] = now - adminTimeLock;
recoveryKeys[identity] = recoveryKey;
LogIdentityCreated(identity, msg.sender, owner,  recoveryKey);
identity.forward(destination, 0, data);
function forwardTo(address sender, Proxy identity, address destination, uint value, bytes data) public onlyAuthorized onlyOwner(identity, sender){
identity.forward(destination, value, data);
