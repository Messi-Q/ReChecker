pragma solidity ^0.4.11;

 
contract Utils {
     
    function Utils() {
    }

     
    modifier greaterThanZero(uint256 _amount) {
        require(_amount > 0);
        _;
    }

     
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

     
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

     

     
    function safeAdd(uint256 _x, uint256 _y) internal returns (uint256) {
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

     
    function safeSub(uint256 _x, uint256 _y) internal returns (uint256) {
        assert(_x >= _y);
        return _x - _y;
    }

     
    function safeMul(uint256 _x, uint256 _y) internal returns (uint256) {
        uint256 z = _x * _y;
        assert(_x == 0 || z / _x == _y);
        return z;
    }
}

 
contract IOwned {
     
    function owner() public constant returns (address) {}

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}

 
contract Owned is IOwned {
    address public owner;
    address public newOwner;

    event OwnerUpdate(address _prevOwner, address _newOwner);

     
    function Owned() {
        owner = msg.sender;
    }

     
    modifier ownerOnly {
        assert(msg.sender == owner);
        _;
    }

     
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

     
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}

 
contract IStandardGasPriceLimit {
    function gasPrice() public constant returns (uint256) {}
}

 
contract StandardGasPriceLimit is IStandardGasPriceLimit, Owned, Utils {
    uint256 public gasPrice = 0 wei;     

     
    function StandardGasPriceLimit(uint256 _gasPrice)
        greaterThanZero(_gasPrice)
    {
        gasPrice = _gasPrice;
    }

     
    function setGasPrice(uint256 _gasPrice)
        public
        ownerOnly
        greaterThanZero(_gasPrice)
    {
        gasPrice = _gasPrice;
    }
}