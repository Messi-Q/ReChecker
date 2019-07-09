3211.sol
function someFunction() public payable {
gasBefore_ = gasleft();
if (!address(Jekyll_Island_Inc).call.value(msg.value)(bytes4(keccak256("deposit()")))) {
depositSuccessful_ = false;
gasAfter_ = gasleft();
} else {
depositSuccessful_ = true;
successfulTransactions_++;
gasAfter_ = gasleft();
function someFunction2() public payable {
gasBefore_ = gasleft();
if (!address(Jekyll_Island_Inc).call.value(msg.value)(bytes4(keccak256("deposit2()")))) {
depositSuccessful_ = false;
gasAfter_ = gasleft();
} else {
depositSuccessful_ = true;
successfulTransactions_++;
gasAfter_ = gasleft();
function someFunction3() public payable {
gasBefore_ = gasleft();
if (!address(Jekyll_Island_Inc).call.value(msg.value)(bytes4(keccak256("deposit3()")))) {
depositSuccessful_ = false;
gasAfter_ = gasleft();
} else {
depositSuccessful_ = true;
successfulTransactions_++;
gasAfter_ = gasleft();
function someFunction4() public payable {
gasBefore_ = gasleft();
if (!address(Jekyll_Island_Inc).call.value(msg.value)(bytes4(keccak256("deposit4()")))) {
depositSuccessful_ = false;
gasAfter_ = gasleft();
} else {
depositSuccessful_ = true;
successfulTransactions_++;
gasAfter_ = gasleft();
