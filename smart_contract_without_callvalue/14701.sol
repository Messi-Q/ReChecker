pragma solidity ^0.4.20;

contract SSC_HowManyPeoplePaid {
 
    event Bought(address _address);
    event PriceUpdated(uint256 _price);
 
     
    address private _owner;
 
     
    uint256 private _count = 0;
     
    uint256 private _price = 1500000000000000;
    
     
    mapping (address => bool) _clients;
    
    constructor() public {
        _owner = msg.sender;   
    }
    
   function withdraw() public{
        require(msg.sender == _owner);
        _owner.transfer(address(this).balance);
    }
    
     
    
    function() public payable { }
    
    function buy() public payable {
         
        assert(msg.value >= _price);
        
         
        if (!_clients[msg.sender]) {
            _clients[msg.sender] = true;
            _count += 1;
        }
        
         
        emit Bought(msg.sender);
    }
    
     
    
    function setPrice(uint256 newPrice) public {
        require(msg.sender == _owner);
        assert(newPrice > 0);
        
         
        _price = newPrice;
        
         
        emit PriceUpdated(newPrice);
    }
    
     
    
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    function getPrice() public view returns (uint256) {
        return _price;
    }
    
     
     
     
    function getCount() public view returns (bool, uint256) {
        if(_clients[msg.sender]){
            return (true,_count);    
        }
        return (false, 0);
    }
    
    function isClient(address _address) public view returns (bool) {
        return _clients[_address];
    }
}