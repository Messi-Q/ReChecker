pragma solidity ^0.4.23;

 
 
 
interface IStandardToken {
    function totalSupply() external constant returns (uint);
    function balanceOf(address tokenOwner) external constant returns (uint balance);
    function allowance(address tokenOwner, address spender) external constant returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    function decimals() external returns (uint256);
}

 
 
contract YeekAirdropper {
    IStandardToken public tokenContract;   
    address public owner;
    uint256 public numberOfTokensPerUser;
    uint256 public tokensDispensed;
    mapping(address => bool) public airdroppedUsers;
    address[] public airdropRecipients;
    event Dispensed(address indexed buyer, uint256 amount);
    
     
    constructor(IStandardToken _tokenContract, uint256 _numTokensPerUser) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        numberOfTokensPerUser = _numTokensPerUser * 10 ** tokenContract.decimals();
    }

     
     
     
     
    function airdropRecipientCount() public view returns(uint) {
        return airdropRecipients.length;
    }

     
     
    function withdrawAirdropTokens() public  {
        require(tokenContract.allowance(owner, this) >= numberOfTokensPerUser);
        require(tokenContract.balanceOf(owner) >= numberOfTokensPerUser);
        require(!airdroppedUsers[msg.sender]);   
        
        tokensDispensed += numberOfTokensPerUser;

        airdroppedUsers[msg.sender]  = true;
        airdropRecipients.length++;
        airdropRecipients[airdropRecipients.length - 1]= msg.sender;
        
        emit Dispensed(msg.sender, numberOfTokensPerUser);
        tokenContract.transferFrom(owner, msg.sender, numberOfTokensPerUser);
    }

     
    function tokensRemaining() public view returns (uint256) {
        return tokenContract.allowance(owner, this);
    }

     
     
    function endAirdrop() public {
        require(msg.sender == owner);
        selfdestruct(msg.sender);  
    }
}