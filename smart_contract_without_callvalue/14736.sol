pragma solidity ^0.4.18;

contract ERC20Interface {
     
    function totalSupply() public constant returns (uint256 supply);

     
    function balanceOf(address _owner) public constant returns (uint256 balance);

     
    function transfer(address _to, uint256 _value) public returns (bool success);

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

     
     
     
    function approve(address _spender, uint256 _value) public returns (bool success);

     
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

     
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

     
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract AirDrop
{
    address public owner;
    address public executor;
    
    event eTransferExecutor(address newOwner);
    event eMultiTransfer(address _tokenAddr, address[] dests, uint256[] values);
    event eMultiTransferETH(address[] dests, uint256[] values);
    
    function () public payable {
    }
    
     
    function AirDrop() public {
        owner = msg.sender;
        executor = msg.sender;
    }
    
     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function transferExecutor(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        executor = newOwner;
        eTransferExecutor(newOwner);
    }
    
     
    modifier onlyExecutor() {
        require(msg.sender == executor || msg.sender == owner);
        _;
    }
    
    function MultiTransfer(address _tokenAddr, address[] dests, uint256[] values) public onlyExecutor
    {
        uint256 i = 0;
        ERC20Interface T = ERC20Interface(_tokenAddr);
        
        require(dests.length > 0 && (dests.length == values.length || values.length == 1));
        
        if (values.length > 1)
        {
            while (i < dests.length) {
                T.transfer(dests[i], values[i]);
                i += 1;
            }
        }
        else    
        {
            while (i < dests.length) {
                T.transfer(dests[i], values[0]);
                i += 1;
            }
        }
        eMultiTransfer(_tokenAddr, dests, values);
    }
    
    function MultiTransferETH(address[] dests, uint256[] values) public onlyExecutor
    {
        uint256 i = 0;
        require(dests.length > 0 && (dests.length == values.length || values.length == 1));
        
        
        if (values.length > 1)
        {
            while (i < dests.length) {
                dests[i].transfer(values[i]);
                i += 1;
            }
        }
        else    
        {
            while (i < dests.length) {
                dests[i].transfer(values[0]);
                i += 1;
            }
        }
        eMultiTransferETH(dests, values);
    }
}