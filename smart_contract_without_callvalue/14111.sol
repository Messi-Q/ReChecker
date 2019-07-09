pragma solidity ^0.4.20;

contract BenToken {
    string public name="BenToken";
    string public symbol="BenCoin";
    uint8 public decimals=8;

     
    mapping (address => uint256) public balanceOf;

         
    function constrcutor() public {
        balanceOf[msg.sender] = 10000;
    }

     
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);            
        require(balanceOf[_to] + _value >= balanceOf[_to]);  
        balanceOf[msg.sender] -= _value;                     
        balanceOf[_to] += _value;                            
    }
}