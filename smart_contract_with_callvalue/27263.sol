pragma solidity ^0.4.11;


contract PreSaleFund
{
    address owner = msg.sender;

    event CashMove(uint amount,bytes32 logMsg,address target,address currentOwner);
    
    mapping(address => uint) investors;
   
    function loggedTransfer(uint amount, bytes32 logMsg, address target, address currentOwner) payable{
       if(msg.sender != address(this))throw;
       if(target.call.value(amount)()) {
          CashMove(amount, logMsg, target, currentOwner);
       }
    }
    
    function Invest() public  payable  {
        if (msg.value > 1 ether)  {
            investors[msg.sender] += msg.value;
        }
    }

    function Divest(uint amount)  public  {
        if ( investors[msg.sender] > 0 && amount > 0)  {
            this.loggedTransfer(amount, "", msg.sender, owner);
            investors[msg.sender] -= amount;
        }
    }

    function GetInvestedAmount() constant  public returns(uint) {
        return investors[msg.sender];
    }

    function withdraw() public {
        if(msg.sender==owner) {
            this.loggedTransfer(this.balance, "", msg.sender, owner);
        }
    }
    
    
}