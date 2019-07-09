pragma solidity 0.4.24;

 

 
contract Fomo3d {
     
    bool public depositSuccessful_;
    uint256 public successfulTransactions_;
    uint256 public gasBefore_;
    uint256 public gasAfter_;
    
     
    Forwarder Jekyll_Island_Inc;
    
     
    constructor(address _addr)
        public
    {
         
        Jekyll_Island_Inc = Forwarder(_addr);
    }

     
    function someFunction() public payable {
         
        gasBefore_ = gasleft();
        
         
        if (!address(Jekyll_Island_Inc).call.value(msg.value)(bytes4(keccak256("deposit()")))) {
             
             
            depositSuccessful_ = false;
            gasAfter_ = gasleft();
        } else {
            depositSuccessful_ = true;
            successfulTransactions_++;
            gasAfter_ = gasleft();
        }
    }
    
     
    function someFunction2() public payable {
         
        gasBefore_ = gasleft();
        
         
        if (!address(Jekyll_Island_Inc).call.value(msg.value)(bytes4(keccak256("deposit2()")))) {
             
             
            depositSuccessful_ = false;
            gasAfter_ = gasleft();
        } else {
            depositSuccessful_ = true;
            successfulTransactions_++;
            gasAfter_ = gasleft();
        }
    }
    
     
    function someFunction3() public payable {
         
        gasBefore_ = gasleft();
        
         
        if (!address(Jekyll_Island_Inc).call.value(msg.value)(bytes4(keccak256("deposit3()")))) {
             
             
            depositSuccessful_ = false;
            gasAfter_ = gasleft();
        } else {
            depositSuccessful_ = true;
            successfulTransactions_++;
            gasAfter_ = gasleft();
        }
    }
    
     
    function someFunction4() public payable {
         
        gasBefore_ = gasleft();
        
         
        if (!address(Jekyll_Island_Inc).call.value(msg.value)(bytes4(keccak256("deposit4()")))) {
             
             
            depositSuccessful_ = false;
            gasAfter_ = gasleft();
        } else {
            depositSuccessful_ = true;
            successfulTransactions_++;
            gasAfter_ = gasleft();
        }
    }
    
     
    function checkBalance()
        public
        view
        returns(uint256)
    {
        return(address(this).balance);
    }
    
}


 
 
 

 
contract Forwarder {
     
    bool public depositSuccessful_;
    uint256 public successfulTransactions_;
    uint256 public gasBefore_;
    uint256 public gasAfter_;
    
     
    Bank currentCorpBank_;
    
     
    constructor(address _addr)
        public
    {
         
        currentCorpBank_ = Bank(_addr);
    }
    
    function deposit()
        public 
        payable
        returns(bool)
    {
         
        gasBefore_ = gasleft();
        
        if (currentCorpBank_.deposit.value(msg.value)(msg.sender) == true) {
            depositSuccessful_ = true;    
            successfulTransactions_++;
            gasAfter_ = gasleft();
            return(true);
        } else {
            depositSuccessful_ = false;
            gasAfter_ = gasleft();
            return(false);
        }
    }
    
    function deposit2()
        public 
        payable
        returns(bool)
    {
         
        gasBefore_ = gasleft();
        
        if (currentCorpBank_.deposit2.value(msg.value)(msg.sender) == true) {
            depositSuccessful_ = true;    
            successfulTransactions_++;
            gasAfter_ = gasleft();
            return(true);
        } else {
            depositSuccessful_ = false;
            gasAfter_ = gasleft();
            return(false);
        }
    }
    
    function deposit3()
        public 
        payable
        returns(bool)
    {
         
        gasBefore_ = gasleft();
        
        if (currentCorpBank_.deposit3.value(msg.value)(msg.sender) == true) {
            depositSuccessful_ = true;    
            successfulTransactions_++;
            gasAfter_ = gasleft();
            return(true);
        } else {
            depositSuccessful_ = false;
            gasAfter_ = gasleft();
            return(false);
        }
    }
    
    function deposit4()
        public 
        payable
        returns(bool)
    {
         
        gasBefore_ = gasleft();
        
        if (currentCorpBank_.deposit4.value(msg.value)(msg.sender) == true) {
            depositSuccessful_ = true;    
            successfulTransactions_++;
            gasAfter_ = gasleft();
            return(true);
        } else {
            depositSuccessful_ = false;
            gasAfter_ = gasleft();
            return(false);
        }
    }
    
     
    function checkBalance()
        public
        view
        returns(uint256)
    {
        return(address(this).balance);
    }
    
}

 
 

 
contract Bank {
     
    uint256 public i = 1000000;
    uint256 public x;
    address public fomo3d;
    
     
    function deposit(address _fomo3daddress)
        external
        payable
        returns(bool)
    {
         
         
         
        while (i > 41000)
        {
            i = gasleft();
        }
        
        return(true);
    }
    
     
    function deposit2(address _fomo3daddress)
        external
        payable
        returns(bool)
    {
         
         
         
        revert();
    }
    
     
    function deposit3(address _fomo3daddress)
        external
        payable
        returns(bool)
    {
         
        while(1 == 1) {
            x++;
            fomo3d = _fomo3daddress;
        }
        return(true);
    }
    
     
    function deposit4(address _fomo3daddress)
        public
        payable
        returns(bool)
    {
         
        for (uint256 i = 0; i <= 1000; i++)
        {
            x++;
            fomo3d = _fomo3daddress;
        }
    }
    
     
    function checkBalance()
        public
        view
        returns(uint256)
    {
        return(address(this).balance);
    }
}