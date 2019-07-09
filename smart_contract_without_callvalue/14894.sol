pragma solidity ^0.4.16;
contract TocIcoData{
 
 
 
 
address Mars = 0x1947f347B6ECf1C3D7e1A58E3CDB2A15639D48Be;
address Mercury = 0x00795263bdca13104309Db70c11E8404f81576BE;
address Europa = 0x00e4E3eac5b520BCa1030709a5f6f3dC8B9e1C37;
address Jupiter = 0x2C76F260707672e240DC639e5C9C62efAfB59867;
address Neptune = 0xEB04E1545a488A5018d2b5844F564135211d3696;

 
function GetContractAddr() public constant returns (address){
return this;
}	
address ContractAddr = GetContractAddr();

struct State{
bool Suspend;    
bool PrivateSale;
bool PreSale;
bool MainSale; 
bool End;
}

struct Market{
uint256 EtherPrice;    
uint256 TocPrice;    
} 

struct Admin{
bool Authorised; 
uint256 Level;
}

 
mapping (address => State) public state;
 
mapping (address => Market) public market;
 
mapping (address => Admin) public admin;

 
function AuthAdmin(address _admin, bool _authority, uint256 _level) external 
returns(bool) {
if((msg.sender != Mars) && (msg.sender != Mercury) && (msg.sender != Europa)
&& (msg.sender != Jupiter) && (msg.sender != Neptune)) revert();  
admin[_admin].Authorised = _authority; 
admin[_admin].Level = _level;
return true;
} 

 
function GeneralUpdate(uint256 _etherprice, uint256 _tocprice) external returns(bool){
     
if(admin[msg.sender].Authorised == false) revert();
if(admin[msg.sender].Level < 5 ) revert();
 
market[ContractAddr].EtherPrice = _etherprice; 
market[ContractAddr].TocPrice = _tocprice;
return true;
}

 
function EtherPriceUpdate(uint256 _etherprice)external returns(bool){
     
if(admin[msg.sender].Authorised == false) revert();
if(admin[msg.sender].Level < 5 ) revert();
 
market[ContractAddr].EtherPrice = _etherprice; 
return true;
}

 
function UpdateState(uint256 _state) external returns(bool){
     
if(admin[msg.sender].Authorised == false) revert();
if(admin[msg.sender].Level < 5 ) revert();
 
if(_state == 1){
state[ContractAddr].Suspend = true;     
state[ContractAddr].PrivateSale = false; 
state[ContractAddr].PreSale = false;
state[ContractAddr].MainSale = false;
state[ContractAddr].End = false;
}
 
if(_state == 2){
state[ContractAddr].Suspend = false;     
state[ContractAddr].PrivateSale = true; 
state[ContractAddr].PreSale = false;
state[ContractAddr].MainSale = false;
state[ContractAddr].End = false;
}
 
if(_state == 3){
state[ContractAddr].Suspend = false;    
state[ContractAddr].PrivateSale = false; 
state[ContractAddr].PreSale = true;
state[ContractAddr].MainSale = false;
state[ContractAddr].End = false;
}
 
if(_state == 4){
state[ContractAddr].Suspend = false;    
state[ContractAddr].PrivateSale = false; 
state[ContractAddr].PreSale = false;
state[ContractAddr].MainSale = true;
state[ContractAddr].End = false;
}
 
if(_state == 5){
state[ContractAddr].Suspend = false;    
state[ContractAddr].PrivateSale = false; 
state[ContractAddr].PreSale = false;
state[ContractAddr].MainSale = false;
state[ContractAddr].End = true;
}
return true;
}

 

 
function GetSuspend() public view returns (bool){
return state[ContractAddr].Suspend;
}
 
function GetPrivateSale() public view returns (bool){
return state[ContractAddr].PrivateSale;
}
 
function GetPreSale() public view returns (bool){
return state[ContractAddr].PreSale;
}
 
function GetMainSale() public view returns (bool){
return state[ContractAddr].MainSale;
}
 
function GetEnd() public view returns (bool){
return state[ContractAddr].End;
}
 
function GetEtherPrice() public view returns (uint256){
return market[ContractAddr].EtherPrice;
}
 
function GetTocPrice() public view returns (uint256){
return market[ContractAddr].TocPrice;
}

} 


pragma solidity ^0.4.16;
contract TocIcoDapp{
 
 
 
 
address Mars = 0x1947f347B6ECf1C3D7e1A58E3CDB2A15639D48Be;
address Mercury = 0x00795263bdca13104309Db70c11E8404f81576BE;
address Europa = 0x00e4E3eac5b520BCa1030709a5f6f3dC8B9e1C37;
address Jupiter = 0x2C76F260707672e240DC639e5C9C62efAfB59867;
address Neptune = 0xEB04E1545a488A5018d2b5844F564135211d3696;

 
uint256 Converter = 10000;

 
function GetContractAddr() public constant returns (address){
return this;
}	
address ContractAddr = GetContractAddr();

struct Buyer{
bool Withdrawn;    
uint256 TocBalance;
uint256 WithdrawalBlock;
uint256 Num;
}

struct Transaction{
uint256 Amount;
uint256 EtherPrice;
uint256 TocPrice;
uint256 Block;
}    

struct AddressBook{
address TOCAddr;
address DataAddr;
address Banker;
}

struct Admin{
bool Authorised; 
uint256 Level;
}

struct OrderBooks{
uint256 PrivateSupply;
uint256 PreSupply;
uint256 MainSupply;
}

 
mapping (address => Buyer) public buyer;
 
mapping(address => mapping(uint256 => Transaction)) public transaction;
 
mapping (address => OrderBooks) public orderbooks;
 
mapping (address => AddressBook) public addressbook;
 
mapping (address => Admin) public admin;

struct TA{
uint256 n1;
uint256 n2;
uint256 n3;
uint256 n4;
uint256 n5;
uint256 n6;
}

struct LA{
bool l1;
bool l2;
bool l3;
bool l4;
}

 
TA ta;
LA la;

 
function AuthAdmin(address _admin, bool _authority, uint256 _level) external 
returns(bool) {
if((msg.sender != Mars) && (msg.sender != Mercury) && (msg.sender != Europa)
&& (msg.sender != Jupiter) && (msg.sender != Neptune)) revert();  
admin[_admin].Authorised = _authority; 
admin[_admin].Level = _level;
return true;
} 

 
function AuthAddr(address _tocaddr, address _dataddr, address _banker) 
external returns(bool){
       
if(admin[msg.sender].Authorised == false) revert();
if(admin[msg.sender].Level < 5 ) revert();
 
addressbook[ContractAddr].TOCAddr = _tocaddr;
addressbook[ContractAddr].DataAddr = _dataddr;
addressbook[ContractAddr].Banker = _banker;
return true;
}

 
function SupplyOp(uint256 _type, uint256 _stage, uint256 _amount) external returns (bool){
     
if(admin[msg.sender].Authorised == false) revert();
if(admin[msg.sender].Level < 5 ) revert(); 
 
if((_type == 1) && (_stage == 1)){
orderbooks[ContractAddr].PrivateSupply += _amount; 
}
 
if((_type == 0) && (_stage == 1)){
require(orderbooks[ContractAddr].PrivateSupply >= _amount);
orderbooks[ContractAddr].PrivateSupply -= _amount; 
}
 
if((_type == 1) && (_stage == 2)){
orderbooks[ContractAddr].PreSupply += _amount; 
}
 
if((_type == 0) && (_stage == 2)){
require(orderbooks[ContractAddr].PreSupply >= _amount);    
orderbooks[ContractAddr].PreSupply -= _amount; 
}
 
if((_type == 1) && (_stage == 3)){
orderbooks[ContractAddr].MainSupply += _amount; 
}
 
if((_type == 0) && (_stage == 3)){
require(orderbooks[ContractAddr].MainSupply >= _amount);    
orderbooks[ContractAddr].MainSupply -= _amount; 
}
return true;
}

 
function CalcToc(uint256 _etherprice, uint256 _tocprice, uint256 _deposit) 
internal returns (uint256){    
ta.n1 = mul(_etherprice, _deposit);
ta.n2 = div(ta.n1,_tocprice);
return ta.n2;
}

 
function PrivateSaleBuy() payable external returns (bool){
     
if(msg.value <= 0) revert();
 
TocIcoData
DataCall = TocIcoData(addressbook[ContractAddr].DataAddr);
 
la.l1 = DataCall.GetEnd();
la.l2 = DataCall.GetPrivateSale();
la.l3 = DataCall.GetSuspend();
ta.n3 = DataCall.GetEtherPrice();    
ta.n4 = DataCall.GetTocPrice();    
  
if(la.l1 == true) revert();
if(la.l2 == false) revert();
if(la.l3 == true) revert();
 
ta.n5 = CalcToc(ta.n3, ta.n4, msg.value);
if(ta.n5 > orderbooks[ContractAddr].PrivateSupply) revert();
 
addressbook[ContractAddr].Banker.transfer(msg.value);
 
orderbooks[ContractAddr].PrivateSupply -= ta.n5;
buyer[msg.sender].TocBalance += ta.n5;
buyer[msg.sender].Num += 1;
ta.n6 = buyer[msg.sender].Num; 
transaction[msg.sender][ta.n6].Amount = ta.n5;
transaction[msg.sender][ta.n6].EtherPrice = ta.n3;
transaction[msg.sender][ta.n6].TocPrice = ta.n4;
transaction[msg.sender][ta.n6].Block = block.number;
return true;
}    

 
function PreSaleBuy() payable external returns (bool){
     
if(msg.value <= 0) revert();
 
TocIcoData
DataCall = TocIcoData(addressbook[ContractAddr].DataAddr);
 
la.l1 = DataCall.GetEnd();
la.l2 = DataCall.GetPreSale();
la.l3 = DataCall.GetSuspend();
ta.n3 = DataCall.GetEtherPrice();    
ta.n4 = DataCall.GetTocPrice();    
  
if(la.l1 == true) revert();
if(la.l2 == false) revert();
if(la.l3 == true) revert();
 
ta.n5 = CalcToc(ta.n3, ta.n4, msg.value);
if(ta.n5 > orderbooks[ContractAddr].PreSupply) revert();
 
addressbook[ContractAddr].Banker.transfer(msg.value);
 
orderbooks[ContractAddr].PreSupply -= ta.n5;
buyer[msg.sender].TocBalance += ta.n5;
buyer[msg.sender].Num += 1;
ta.n6 = buyer[msg.sender].Num; 
transaction[msg.sender][ta.n6].Amount = ta.n5;
transaction[msg.sender][ta.n6].EtherPrice = ta.n3;
transaction[msg.sender][ta.n6].TocPrice = ta.n4;
transaction[msg.sender][ta.n6].Block = block.number;
return true;
}    

 
function MainSaleBuy() payable external returns (bool){
     
if(msg.value <= 0) revert();
 
TocIcoData
DataCall = TocIcoData(addressbook[ContractAddr].DataAddr);
 
la.l1 = DataCall.GetEnd();
la.l2 = DataCall.GetMainSale();
la.l3 = DataCall.GetSuspend();
ta.n3 = DataCall.GetEtherPrice();    
ta.n4 = DataCall.GetTocPrice();    
  
if(la.l1 == true) revert();
if(la.l2 == false) revert();
if(la.l3 == true) revert();
 
ta.n5 = CalcToc(ta.n3, ta.n4, msg.value);
if(ta.n5 > orderbooks[ContractAddr].MainSupply) revert();
 
addressbook[ContractAddr].Banker.transfer(msg.value);
 
orderbooks[ContractAddr].MainSupply -= ta.n5;
buyer[msg.sender].TocBalance += ta.n5;
buyer[msg.sender].Num += 1;
ta.n6 = buyer[msg.sender].Num; 
transaction[msg.sender][ta.n6].Amount = ta.n5;
transaction[msg.sender][ta.n6].EtherPrice = ta.n3;
transaction[msg.sender][ta.n6].TocPrice = ta.n4;
transaction[msg.sender][ta.n6].Block = block.number;
return true;
}    

 
function Withdraw() external returns (bool){
 
TocIcoData
DataCall = TocIcoData(addressbook[ContractAddr].DataAddr);
 
la.l4 = DataCall.GetEnd();
  
if(la.l4 == false) revert();
if(buyer[msg.sender].TocBalance <= 0) revert();
if(buyer[msg.sender].Withdrawn == true) revert();
 
buyer[msg.sender].Withdrawn = true;
buyer[msg.sender].WithdrawalBlock = block.number;
 
TOC
TOCCall = TOC(addressbook[ContractAddr].TOCAddr);
 
assert(buyer[msg.sender].Withdrawn == true);
 
TOCCall.transfer(msg.sender,buyer[msg.sender].TocBalance);
 
assert(buyer[msg.sender].Withdrawn == true);
return true;
}  

 
function receiveApproval(address _from, uint256 _value, 
address _token, bytes _extraData) external returns(bool){ 
TOC
TOCCall = TOC(_token);
TOCCall.transferFrom(_from,this,_value);
return true;
}

 
function () payable external{
revert();  
}

 
function mul(uint256 a, uint256 b) public pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
function div(uint256 a, uint256 b) public pure returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }  
function sub(uint256 a, uint256 b) public pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
function add(uint256 a, uint256 b) public pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
 
} 


pragma solidity ^0.4.16;

 
interface tokenRecipient { 
function receiveApproval(address _from, uint256 _value, 
address _token, bytes _extraData) external; 
}

contract TOC {
 

 
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;

 
mapping (address => uint256) public balances;
 
mapping(address => mapping (address => uint256)) public allowed;

 		
 
event Transfer(address indexed from, address indexed to, uint256 value);
 
event Approval(address indexed _owner, address indexed _spender, uint _value);

 
constructor() public {
name = "Token Changer";
symbol = "TOC";
decimals = 18;
 
totalSupply = 10**27;
balances[msg.sender] = totalSupply; 
}

 
function _transfer(address _from, address _to, uint _value) internal {    
     
if(_to == 0x0) revert();
 
if(balances[_from] < _value) revert(); 
 
if(balances[_to] + _value < balances[_to]) revert();
 
uint PreviousBalances = balances[_from] + balances[_to];
 
balances[_from] -= _value;
 
balances[_to] += _value; 
 
assert(balances[_from] + balances[_to] == PreviousBalances);
 
emit Transfer(_from, _to, _value); 
}

 
function transfer(address _to, uint256 _value) external returns (bool){
_transfer(msg.sender, _to, _value);
return true;
}

 
function approve(address _spender, uint256 _value) public returns (bool success){
     
allowed[msg.sender][_spender] = _value;
 
emit Approval(msg.sender, _spender, _value); 
return true;                                        
}

 
function transferFrom(address _from, address _to, uint256 _value) 
external returns (bool success) {
 
require(_value <= allowed[_from][msg.sender]); 
 
allowed[_from][msg.sender] -= _value;
 
_transfer(_from, _to, _value);
return true;
}

 
function approveAndCall(address _spender, uint256 _value, 
 bytes _extraData) external returns (bool success) {
tokenRecipient 
spender = tokenRecipient(_spender);
if(approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
}
return true;
}

 
function () payable external{
revert();  
}

} 