pragma experimental "v0.5.0";

 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

contract HourlyPay { 

     
     

    address public owner;            
    address public employeeAddress = 0x0;   


     
     
    
    uint public beginTimeTS;                
    uint public ratePerHourInWei;           
    uint public earnings = 0;               
    bool public hired = false;              
    bool public working = false;            
    uint public startedWorkTS;              
    uint public workedTodayInSeconds = 0;   
    uint public currentDayTS;
    uint public lastPaydayTS;
    string public contractName = "Hourly Pay Contract";

     
     
    
    uint16 public contractDurationInDays = 365;   
    uint8 public dailyHourLimit = 8;                
    uint8 public paydayFrequencyInDays = 3;        

    uint8 constant hoursInWeek = 168;
    uint8 constant maxDaysInFrequency = 30;  


     
     

    constructor() public {
        owner = msg.sender;
        beginTimeTS = now;
        currentDayTS = beginTimeTS;
        lastPaydayTS = beginTimeTS;
    }


     
     

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyEmployee {
        require(msg.sender == employeeAddress);
        _;
    }
    
    modifier onlyOwnerOrEmployee {
        require((msg.sender == employeeAddress) || (msg.sender == owner));
        _;
    }

    modifier beforeHire {
        require(employeeAddress == 0x0);                         
        require(hired == false);                                 
        _;
    }


     
     
    
    event GotFunds(address sender, uint amount);
    event ContractDurationInDaysChanged(uint16 contractDurationInDays);
    event DailyHourLimitChanged(uint8 dailyHourLimit);
    event PaydayFrequencyInDaysChanged(uint32 paydayFrequencyInDays);
    event BeginTimeTSChanged(uint beginTimeTS);
    event Hired(address employeeAddress, uint ratePerHourInWei, uint hiredTS);
    event NewDay(uint currentDayTS, uint16 contractDaysLeft);
    event StartedWork(uint startedWorkTS, uint workedTodayInSeconds, string comment);
    event StoppedWork(uint stoppedWorkTS, uint workedInSeconds, uint earned);
    event Withdrawal(uint amount, address employeeAddress, uint withdrawalTS);
    event Fired(address employeeAddress, uint firedTS);
    event Refunded(uint amount, address whoInitiatedRefund, uint refundTS);
    event ClientWithdrawal(uint amount, uint clientWithdrawalTS);
    event ContractNameChanged(string contractName);
    
     
     
    
    function () external payable {
        emit GotFunds(msg.sender, msg.value);
    }
    
    
     
     

    function setContractName(string newContractName) external onlyOwner beforeHire {
        contractName = newContractName;
        emit ContractNameChanged(contractName);
    }

    function setContractDurationInDays(uint16 newContractDurationInDays) external onlyOwner beforeHire {
        require(newContractDurationInDays <= 365);
        contractDurationInDays = newContractDurationInDays;
        emit ContractDurationInDaysChanged(contractDurationInDays);
    }
    
    function setDailyHourLimit(uint8 newDailyHourLimit) external onlyOwner beforeHire {
        require(newDailyHourLimit <= 24);
        dailyHourLimit = newDailyHourLimit;
        emit DailyHourLimitChanged(dailyHourLimit);
    }

    function setPaydayFrequencyInDays(uint8 newPaydayFrequencyInDays) external onlyOwner beforeHire {
        require(newPaydayFrequencyInDays < maxDaysInFrequency);
        paydayFrequencyInDays = newPaydayFrequencyInDays;
        emit PaydayFrequencyInDaysChanged(paydayFrequencyInDays);
    }
    
    function setBeginTimeTS(uint newBeginTimeTS) external onlyOwner beforeHire {
        beginTimeTS = newBeginTimeTS;
        currentDayTS = beginTimeTS;
        lastPaydayTS = beginTimeTS;
        emit BeginTimeTSChanged(beginTimeTS);
    }
    
     
     
    
    function getWorkSecondsInProgress() public view returns(uint) {
        if (!working) return 0;
        return now - startedWorkTS;
    }
    
    function isOvertime() external view returns(bool) {
        if (workedTodayInSeconds + getWorkSecondsInProgress() > dailyHourLimit * 1 hours) return true;
        return false;
    }
    
    function hasEnoughFundsToStart() public view returns(bool) {
        return ((address(this).balance > earnings) &&
                (address(this).balance - earnings >= ratePerHourInWei * (dailyHourLimit * 1 hours - (isNewDay() ? 0 : workedTodayInSeconds)) / 1 hours));
    }
    
    function isNewDay() public view returns(bool) {
        return (now - currentDayTS > 1 days);
    }
    
    function canStartWork() public view returns(bool) {
        return (hired
            && !working
            && (now > beginTimeTS)
            && (now < beginTimeTS + (contractDurationInDays * 1 days))
            && hasEnoughFundsToStart()
            && ((workedTodayInSeconds < dailyHourLimit * 1 hours) || isNewDay()));
    }

    function canStopWork() external view returns(bool) {
        return (working
            && hired
            && (now > startedWorkTS));
    }

    function currentTime() external view returns(uint) {
        return now;
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }

     
     

    function releaseOwnership() external onlyOwner {
        owner = 0x0;
    }

    function hire(address newEmployeeAddress, uint newRatePerHourInWei) external onlyOwner beforeHire {
        require(newEmployeeAddress != 0x0);                      

         
        require(address(this).balance >= newRatePerHourInWei * dailyHourLimit);
        employeeAddress = newEmployeeAddress;
        ratePerHourInWei = newRatePerHourInWei;
        
        hired = true;
        emit Hired(employeeAddress, ratePerHourInWei, now);
    }

    function startWork(string comment) external onlyEmployee {
        require(hired == true);
        require(working == false);
        
        require(now > beginTimeTS);  
        require(now < beginTimeTS + (contractDurationInDays * 1 days));  
        
        checkForNewDay();
        
        require(workedTodayInSeconds < dailyHourLimit * 1 hours);  

        require(address(this).balance > earnings);  

         
        require(address(this).balance - earnings >= ratePerHourInWei * (dailyHourLimit * 1 hours - workedTodayInSeconds) / 1 hours);
        
        if (earnings == 0) lastPaydayTS = now;  

        startedWorkTS = now;
        working = true;
        
        emit StartedWork(startedWorkTS, workedTodayInSeconds, comment);
    }
    
    function checkForNewDay() internal {
        if (now - currentDayTS > 1 days) {  
            while (currentDayTS < now) {
                currentDayTS += 1 days;
            }
            currentDayTS -= 1 days;
            workedTodayInSeconds = 0;
            emit NewDay(currentDayTS, uint16 ((beginTimeTS + (contractDurationInDays * 1 days) - currentDayTS) / 1 days));
        }
    }
    
    function stopWork() external onlyEmployee {
        stopWorkInternal();
    }
    
    function stopWorkInternal() internal {
        require(hired == true);
        require(working == true);
    
        require(now > startedWorkTS);  
        
        
        uint newWorkedTodayInSeconds = workedTodayInSeconds + (now - startedWorkTS);
        if (newWorkedTodayInSeconds > dailyHourLimit * 1 hours) {  
            newWorkedTodayInSeconds = dailyHourLimit * 1 hours;    
        }
        
        uint earned = (newWorkedTodayInSeconds - workedTodayInSeconds) * ratePerHourInWei / 1 hours;
        earnings += earned;  
        
        emit StoppedWork(now, newWorkedTodayInSeconds - workedTodayInSeconds, earned);

        workedTodayInSeconds = newWorkedTodayInSeconds;  
        working = false;

        checkForNewDay();
    }

    function withdraw() external onlyEmployee {
        require(working == false);
        require(earnings > 0);
        require(earnings <= address(this).balance);
        
        require(now - lastPaydayTS > paydayFrequencyInDays * 1 days);  
        
        lastPaydayTS = now;
        uint amountToWithdraw = earnings;
        earnings = 0;
        
        employeeAddress.transfer(amountToWithdraw);
        
        emit Withdrawal(amountToWithdraw, employeeAddress, now);
    }
    
    function withdrawAfterEnd() external onlyEmployee {
        require(owner == 0x0);  
        require(now > beginTimeTS + (contractDurationInDays * 1 days));  
        require(address(this).balance > 0);  

        employeeAddress.transfer(address(this).balance);
        emit Withdrawal(address(this).balance, employeeAddress, now);
    }
    
    function fire() external onlyOwner {
        if (working) stopWorkInternal();  
        
        hired = false;  
        
        emit Fired(employeeAddress, now);
    }

    function refundAll() external onlyOwnerOrEmployee {     
        require(working == false);
        require(earnings > 0);
        uint amount = earnings;
        earnings = 0;

        emit Refunded(amount, msg.sender, now);
    }
    
    function refund(uint amount) external onlyOwnerOrEmployee {   
        require(working == false);
        require(amount < earnings);
        earnings -= amount;

        emit Refunded(amount, msg.sender, now);
    }

    function clientWithdrawAll() external onlyOwner {  
        require(hired == false);
        require(address(this).balance > earnings);
        uint amount = address(this).balance - earnings;
        
        owner.transfer(amount);
        
        emit ClientWithdrawal(amount, now);
    }
    
    function clientWithdraw(uint amount) external onlyOwner {  
        require(hired == false);
        require(address(this).balance > earnings);
        require(amount < address(this).balance);
        require(address(this).balance - amount > earnings);
        
        owner.transfer(amount);

        emit ClientWithdrawal(amount, now);
    }
}