pragma solidity ^0.4.20;

contract FUTokenContract {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

     
    mapping (address => uint256) public balanceOf;

         
    constructor(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);   
        balanceOf[msg.sender] = totalSupply;                 
        name = tokenName;                                    
        symbol = tokenSymbol;                                
    }

     
    function transfer(address _to, uint256 _value) public {
        require(_to != 0x0);                                 
        require(balanceOf[msg.sender] >= _value);            
        require(balanceOf[_to] + _value >= balanceOf[_to]);  
        balanceOf[msg.sender] -= _value;                     
        balanceOf[_to] += _value;                            
    }
}