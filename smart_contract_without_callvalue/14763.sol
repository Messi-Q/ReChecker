pragma solidity ^0.4.18;


 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
    uint256 c = a / b;
     
    return c;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


 

 contract IHFVesting {
    using SafeMath for uint256;

    address public beneficiary;
    uint256 public fundingEndBlock;

    bool private initClaim = false;  

    uint256 public firstRelease;  
    bool private firstDone = false;
    uint256 public secondRelease;
    bool private secondDone = false;
    uint256 public thirdRelease;
    bool private thirdDone = false;
    uint256 public fourthRelease;

    ERC20Basic public ERC20Token;  

    enum Stages {
        initClaim,
        firstRelease,
        secondRelease,
        thirdRelease,
        fourthRelease
    }

    Stages public stage = Stages.initClaim;

    modifier atStage(Stages _stage) {
        if(stage == _stage) _;
    }

    function IHFVesting(address _token, uint256 fundingEndBlockInput) public {
        require(_token != address(0));
        beneficiary = msg.sender;
        fundingEndBlock = fundingEndBlockInput;
        ERC20Token = ERC20Basic(_token);
    }

    function changeBeneficiary(address newBeneficiary) external {
        require(newBeneficiary != address(0));
        require(msg.sender == beneficiary);
        beneficiary = newBeneficiary;
    }

    function updateFundingEndBlock(uint256 newFundingEndBlock) public {
        require(msg.sender == beneficiary);
        require(block.number < fundingEndBlock);
        require(block.number < newFundingEndBlock);
        fundingEndBlock = newFundingEndBlock;
    }

    function checkBalance() public view returns (uint256 tokenBalance) {
        return ERC20Token.balanceOf(this);
    }

     
     
     
     
     
     
     
     
     
     
     

    function claim() external {
        require(msg.sender == beneficiary);
        require(block.number > fundingEndBlock);
        uint256 balance = ERC20Token.balanceOf(this);
         
        fourth_release(balance);
        third_release(balance);
        second_release(balance);
        first_release(balance);
        init_claim(balance);
    }

    function nextStage() private {
        stage = Stages(uint256(stage) + 1);
    }

    function init_claim(uint256 balance) private atStage(Stages.initClaim) {
        firstRelease = now + 26 weeks;  
        secondRelease = firstRelease + 26 weeks;
        thirdRelease = secondRelease + 26 weeks;
        fourthRelease = thirdRelease + 26 weeks;
        uint256 amountToTransfer = balance.mul(52).div(100);
        ERC20Token.transfer(beneficiary, amountToTransfer);  
        nextStage();
    }
    function first_release(uint256 balance) private atStage(Stages.firstRelease) {
        require(now > firstRelease);
        uint256 amountToTransfer = balance.div(4);
        ERC20Token.transfer(beneficiary, amountToTransfer);  
        nextStage();
    }
    function second_release(uint256 balance) private atStage(Stages.secondRelease) {
        require(now > secondRelease);
        uint256 amountToTransfer = balance.div(3);
        ERC20Token.transfer(beneficiary, amountToTransfer);  
        nextStage();
    }
    function third_release(uint256 balance) private atStage(Stages.thirdRelease) {
        require(now > thirdRelease);
        uint256 amountToTransfer = balance.div(2);
        ERC20Token.transfer(beneficiary, amountToTransfer);  
        nextStage();
    }
    function fourth_release(uint256 balance) private atStage(Stages.fourthRelease) {
        require(now > fourthRelease);
        ERC20Token.transfer(beneficiary, balance);  
    }

    function claimOtherTokens(address _token) external {
        require(msg.sender == beneficiary);
        require(_token != address(0));
        ERC20Basic token = ERC20Basic(_token);
        require(token != ERC20Token);
        uint256 balance = token.balanceOf(this);
        token.transfer(beneficiary, balance);
     }

 }