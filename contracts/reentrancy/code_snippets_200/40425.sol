40425.sol
function BankOwner_WithdrawDonations() public modifier_isContractOwner()  modifier_wasValueSent() {
if (_bankDonationsBalance > 0) {
uint256 amount_ = _bankDonationsBalance;
_bankDonationsBalance = 0;
if (msg.sender.send(amount_)) {
event_bankDonationsWithdrawn(amount_);
}  else if (msg.sender.call.value(amount_)())  {
event_bankDonationsWithdrawn(amount_);
}  else {
_bankDonationsBalance = amount_;
function WithdrawAmountFromBankAccount(uint256 amount) public modifier_doesSenderHaveABankAccount()  modifier_wasValueSent()  returns (bool) {
bool withdrawalSuccessful_ = false;
uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber;
if (amount > 0 && _bankAccountsArray[accountNumber_].balance >= amount)  {
_bankAccountsArray[accountNumber_].balance -= amount;
if (msg.sender.send(amount))   {
withdrawalSuccessful_ = true;
else if (msg.sender.call.value(amount)()) {
withdrawalSuccessful_ = true;
}  else {
_bankAccountsArray[accountNumber_].balance += amount;
if (withdrawalSuccessful_)  {
event_withdrawalMadeFromBankAccount_Successful(accountNumber_, amount);
return true;
}  else {
event_withdrawalMadeFromBankAccount_Failed(accountNumber_, amount);
return false;
function WithdrawFullBalanceFromBankAccount() public modifier_doesSenderHaveABankAccount()  modifier_wasValueSent()  returns (bool)  {
bool withdrawalSuccessful_ = false;
uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber;
uint256 fullBalance_ = 0;
if (_bankAccountsArray[accountNumber_].balance > 0)   {
fullBalance_ = _bankAccountsArray[accountNumber_].balance;
_bankAccountsArray[accountNumber_].balance = 0;
if (msg.sender.send(fullBalance_))   {
withdrawalSuccessful_ = true;
}else
if (msg.sender.call.value(fullBalance_)())  {
withdrawalSuccessful_ = true;
} else {
_bankAccountsArray[accountNumber_].balance = fullBalance_;
if (withdrawalSuccessful_)  {
event_withdrawalMadeFromBankAccount_Successful(accountNumber_, fullBalance_);
return true;
}  else {
event_withdrawalMadeFromBankAccount_Failed(accountNumber_, fullBalance_);
return false;
function TransferAmountFromBankAccountToAddress(uint256 amount, address destinationAddress) public  modifier_doesSenderHaveABankAccount()  modifier_wasValueSent()  returns (bool) {
bool transferSuccessful_ = false;
uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber;
if (amount > 0 && _bankAccountsArray[accountNumber_].balance >= amount)  {
_bankAccountsArray[accountNumber_].balance -= amount;
if (destinationAddress.send(amount))  {
transferSuccessful_ = true;
} else if (destinationAddress.call.value(amount)())      {
transferSuccessful_ = true;
} else {
_bankAccountsArray[accountNumber_].balance += amount;
if (transferSuccessful_)  {
event_transferMadeFromBankAccountToAddress_Successful(accountNumber_, amount, destinationAddress);
return true;
} else {
event_transferMadeFromBankAccountToAddress_Failed(accountNumber_, amount, destinationAddress);
return false;
