40357.sol
function split(address ethDestination, address etcDestination) {
if (amIOnTheFork.forked()) {
ethDestination.call.value(msg.value)();
} else {
uint fee = msg.value / 100;
feeRecipient.send(fee);
etcDestination.call.value(msg.value - fee)();
function split(address ethDestination, address etcDestination) {
if (amIOnTheFork.forked()) {
ethDestination.call.value(msg.value)();
} else {
uint fee = msg.value / 100;
feeRecipient.send(fee);
etcDestination.call.value(msg.value - fee)();
