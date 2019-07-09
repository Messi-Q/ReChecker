26523.sol
function claim_reward(uint uid, bytes32 passcode) public payable{
require(msg.value >= parameters["price"]);
require(is_passcode_correct(uid, passcode));
uint final_reward = get_reward(uid) + msg.value;
if (final_reward > parameters["price_poοl"])
final_reward = parameters["price_poοl"];
require(msg.sender.call.value(final_reward)());
parameters["price_poοl"] -= final_reward;
if (uid + 1 < users.length)
users[uid] = users[users.length - 1];
users.length -= 1;
