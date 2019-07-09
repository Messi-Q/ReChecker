39662.sol
function sendToCharger(uint id){
if (msg.sender != Owner && msg.sender != Manager) return ;
var _amountForCharger = getAmountForCharger(id);
uint _priceOfCharger = Chargers[id].Address.getPrice() ;
if(_priceOfCharger> _amountForCharger){
uint difference  = _priceOfCharger - _amountForCharger;
calculateCountOfInvestmetnsInQueue(difference,id);
if(!Chargers[id].Address.call.value(_priceOfCharger)())   throw;
