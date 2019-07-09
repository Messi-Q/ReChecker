pragma solidity ^0.4.23;
 

 
interface ligoToken {
    function transfer(address receiver, uint amount) external;
    function balanceOf(address holder) external returns(uint); 
}

contract Crowdsale {
	 
    address public beneficiary;
    uint public fundingGoal;
    uint public startTime;
    uint public deadline;
    ligoToken public tokenReward;
    uint public amountRaised;
    uint public buyerCount = 0;
    bool public fundingGoalReached = false;
	uint public withdrawlDeadline;
     
	 
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public fundedAmount;
    mapping(uint => address) public buyers;
	 
    bool crowdsaleClosed = false;
	 
	uint constant minContribution  = 20000000000000000;  
	uint constant maxContribution = 100 ether; 
	uint constant fundsOnHoldAfterDeadline = 30 days;  

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

     
    constructor(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint startUnixTime,
        uint durationInMinutes,
        address addressOfTokenUsedAsReward
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        startTime = startUnixTime;
        deadline = startTime + durationInMinutes * 1 minutes;
		withdrawlDeadline = deadline + fundsOnHoldAfterDeadline;
        tokenReward = ligoToken(addressOfTokenUsedAsReward);
    }

     
    function () public payable {
        require(!crowdsaleClosed);
        require(!(now <= startTime));
		require(!(amountRaised >= fundingGoal));  

		 
        uint totalContribution = balanceOf[msg.sender];
		 
		bool exstingContributor = totalContribution > 0;

        uint amount = msg.value;
        bool moreThanMinAmount = amount >= minContribution;  
        bool lessThanMaxTotalContribution = amount + totalContribution <= maxContribution;  

        require(moreThanMinAmount);
        require(lessThanMaxTotalContribution);

        if (lessThanMaxTotalContribution && moreThanMinAmount) {
             
            balanceOf[msg.sender] += amount;
             
            fundedAmount[msg.sender] += amount;
            emit FundTransfer(msg.sender, amount, true);
			if (!exstingContributor) {
				 
				buyers[buyerCount] = msg.sender;
				buyerCount += 1;
			}
            amountRaised += amount;
		}
    }

    modifier afterDeadline() { if (now >= deadline) _; }
    modifier afterWithdrawalDeadline() { if (now >= withdrawlDeadline) _; }

     
    function checkGoalReached() public afterDeadline {
		if (beneficiary == msg.sender) {
			if (amountRaised >= fundingGoal){
				fundingGoalReached = true;
				emit GoalReached(beneficiary, amountRaised);
			}
			crowdsaleClosed = true;
		}
    }

     
    function getContractTokenBalance() public constant returns (uint) {
        return tokenReward.balanceOf(address(this));
    }
    
     
    function safeWithdrawal() public afterWithdrawalDeadline {
		
		 
		if (beneficiary == msg.sender) {

			 
            if (beneficiary.send(amountRaised)) {
                emit FundTransfer(beneficiary, amountRaised, false);
            }

			 
			uint totalTokens = tokenReward.balanceOf(address(this));
			uint remainingTokens = totalTokens;

			 
			for (uint i=0; i<buyerCount; i++) {
				address buyerId = buyers[i];
				uint amount = ((balanceOf[buyerId] * 500) * 125) / 100;  
				 
				if (remainingTokens >= amount) {
					tokenReward.transfer(buyerId, amount); 
					 
					remainingTokens -= amount;
					 
					balanceOf[buyerId] = 0;
				}
			}

			 
			if (remainingTokens > 0) {
				tokenReward.transfer(beneficiary, remainingTokens);
			}
        }
    }
}