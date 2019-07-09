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