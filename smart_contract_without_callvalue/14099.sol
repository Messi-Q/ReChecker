pragma solidity ^0.4.2;


contract Lottery {

     
    modifier onlyOwner 
    {
        require(msg.sender == owner);
         _;
    }

     
    address public owner;

    uint private randomNumber;   

     
    event LogRandNumberBC(uint64 taskID,uint16 randomNum);

     
    constructor() public {
        owner = msg.sender;
    }

    function RollLottery(uint64 taskID) public
        onlyOwner
    {
        uint16 randResult;

        randomNumber 	= uint(keccak256(randomNumber,taskID,block.difficulty)) * uint(blockhash(block.number - 1));
        randResult 		= uint16(randomNumber % 1000);

        emit LogRandNumberBC(taskID,randResult);
    }


    function ()
        public payable
    {
        return;
    }


     
    function ownerChangeOwner(address newOwner) public
        onlyOwner
    {
        owner = newOwner;
    }

     
    function ownerkill() public
        onlyOwner
    {
        selfdestruct(owner);
    }

}