14153.sol
function owner(bytes32 node) constant returns(address);
function resolver(bytes32 node) constant returns(address);
function ttl(bytes32 node) constant returns(uint64);
function setOwner(bytes32 node, address owner);
function setSubnodeOwner(bytes32 node, bytes32 label, address owner);
function setResolver(bytes32 node, address resolver);
function setTTL(bytes32 node, uint64 ttl);
event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);
event Transfer(bytes32 indexed node, address owner);
event NewResolver(bytes32 indexed node, address resolver);
event NewTTL(bytes32 indexed node, uint64 ttl);
contract ENS is AbstractENS {
struct Record {
address owner;
address resolver;
uint64 ttl;
mapping(bytes32=>Record) records;
modifier only_owner(bytes32 node) {
if(records[node].owner != msg.sender) throw;
function setTTL(bytes32 node, uint64 ttl);
event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);
event Transfer(bytes32 indexed node, address owner);
event NewResolver(bytes32 indexed node, address resolver);
event NewTTL(bytes32 indexed node, uint64 ttl);
contract ENS is AbstractENS {
struct Record {
address owner;
address resolver;
uint64 ttl;
mapping(bytes32=>Record) records;
modifier only_owner(bytes32 node) {
if(records[node].owner != msg.sender) throw;