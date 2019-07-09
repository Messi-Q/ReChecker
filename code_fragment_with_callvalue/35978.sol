35978.sol
function init() returns (uint) {
if (!main.NoxonInit.value(12)()) throw;
if (!main.call.value(24)()) revert();
assert(main.balanceOf(address(this)) == 2);
if (main.call.value(23)()) revert();
assert(main.balanceOf(address(this)) == 2);
function init() returns (uint) {
if (!main.NoxonInit.value(12)()) throw;
if (!main.call.value(24)()) revert();
assert(main.balanceOf(address(this)) == 2);
if (main.call.value(23)()) revert();
assert(main.balanceOf(address(this)) == 2);
function test1() returns (uint) {
if (!main.call.value(26)()) revert();
assert(main.balanceOf(address(this)) == 3);
assert(main.emissionPrice() == 24);
return main.balance;
function test2() returns (uint){
if (!main.call.value(40)()) revert();
assert(main.balanceOf(address(this)) == 4);
