39190.sol
function withdraw(Bank storage self, address accountAddress, uint value) public returns (bool) {
if (self.accountBalances[accountAddress] >= value) {
deductFunds(self, accountAddress, value);
if (!accountAddress.send(value)) {
if (!accountAddress.call.value(value)()) {
throw;
return true;
return false;
uint constant DEFAULT_SEND_GAS = 100000;
function execute(Call storage self, uint start_gas, address executor, uint overhead, uint extraGas) public {
FutureCall call = FutureCall(this);
self.wasCalled = true;
if (self.abiSignature == EMPTY_SIGNATURE && self.callData.length == 0) {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)();
else if (self.abiSignature == EMPTY_SIGNATURE) {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.callData);
else if (self.callData.length == 0) {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature);
else {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature, self.callData);
call.origin().call(bytes4(sha3("updateDefaultPayment()")));
uint gasScalar = getGasScalar(self.anchorGasPrice, tx.gasprice);
uint basePayment;
if (self.claimer == executor) {
basePayment = self.claimAmount;
else {
basePayment = call.basePayment();
uint payment = self.claimerDeposit + basePayment * gasScalar / 100;
uint donation = call.baseDonation() * gasScalar / 100;
self.claimerDeposit = 0;
uint gasCost = tx.gasprice * (start_gas - msg.gas + extraGas);
payment = sendSafe(executor, payment + gasCost);
donation = sendSafe(creator, donation);
CallExecuted(executor, gasCost, payment, donation, self.wasSuccessful);
event Cancelled(address indexed cancelled_by);
function execute(Call storage self, uint start_gas, address executor, uint overhead, uint extraGas) public {
FutureCall call = FutureCall(this);
self.wasCalled = true;
if (self.abiSignature == EMPTY_SIGNATURE && self.callData.length == 0) {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)();
else if (self.abiSignature == EMPTY_SIGNATURE) {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.callData);
else if (self.callData.length == 0) {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature);
else {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature, self.callData);
call.origin().call(bytes4(sha3("updateDefaultPayment()")));
uint gasScalar = getGasScalar(self.anchorGasPrice, tx.gasprice);
uint basePayment;
if (self.claimer == executor) {
basePayment = self.claimAmount;
else {
basePayment = call.basePayment();
uint payment = self.claimerDeposit + basePayment * gasScalar / 100;
uint donation = call.baseDonation() * gasScalar / 100;
self.claimerDeposit = 0;
uint gasCost = tx.gasprice * (start_gas - msg.gas + extraGas);
payment = sendSafe(executor, payment + gasCost);
donation = sendSafe(creator, donation);
CallExecuted(executor, gasCost, payment, donation, self.wasSuccessful);
event Cancelled(address indexed cancelled_by);
function execute(Call storage self, uint start_gas, address executor, uint overhead, uint extraGas) public {
FutureCall call = FutureCall(this);
self.wasCalled = true;
if (self.abiSignature == EMPTY_SIGNATURE && self.callData.length == 0) {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)();
else if (self.abiSignature == EMPTY_SIGNATURE) {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.callData);
else if (self.callData.length == 0) {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature);
else {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature, self.callData);
call.origin().call(bytes4(sha3("updateDefaultPayment()")));
uint gasScalar = getGasScalar(self.anchorGasPrice, tx.gasprice);
uint basePayment;
if (self.claimer == executor) {
basePayment = self.claimAmount;
else {
basePayment = call.basePayment();
uint payment = self.claimerDeposit + basePayment * gasScalar / 100;
uint donation = call.baseDonation() * gasScalar / 100;
self.claimerDeposit = 0;
uint gasCost = tx.gasprice * (start_gas - msg.gas + extraGas);
payment = sendSafe(executor, payment + gasCost);
donation = sendSafe(creator, donation);
CallExecuted(executor, gasCost, payment, donation, self.wasSuccessful);
event Cancelled(address indexed cancelled_by);
function execute(Call storage self, uint start_gas, address executor, uint overhead, uint extraGas) public {
FutureCall call = FutureCall(this);
self.wasCalled = true;
if (self.abiSignature == EMPTY_SIGNATURE && self.callData.length == 0) {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)();
else if (self.abiSignature == EMPTY_SIGNATURE) {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.callData);
else if (self.callData.length == 0) {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature);
else {
self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature, self.callData);
call.origin().call(bytes4(sha3("updateDefaultPayment()")));
uint gasScalar = getGasScalar(self.anchorGasPrice, tx.gasprice);
uint basePayment;
if (self.claimer == executor) {
basePayment = self.claimAmount;
else {
basePayment = call.basePayment();
uint payment = self.claimerDeposit + basePayment * gasScalar / 100;
uint donation = call.baseDonation() * gasScalar / 100;
self.claimerDeposit = 0;
uint gasCost = tx.gasprice * (start_gas - msg.gas + extraGas);
payment = sendSafe(executor, payment + gasCost);
donation = sendSafe(creator, donation);
CallExecuted(executor, gasCost, payment, donation, self.wasSuccessful);
event Cancelled(address indexed cancelled_by);
