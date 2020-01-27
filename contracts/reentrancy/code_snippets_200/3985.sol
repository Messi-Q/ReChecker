3985.sol
function performFeelessTransaction(address sender, address target, bytes data, uint256 nonce, bytes sig) public payable {
require(this == target);
bytes memory prefix = "\x19Ethereum Signed Message:\n32";
bytes32 hash = keccak256(prefix, keccak256(target, data, nonce));
msgSender = ECRecovery.recover(hash, sig);
require(msgSender == sender);
require(nonces[msgSender]++ == nonce);
require(target.call.value(msg.value)(data));
msgSender = address(0);
