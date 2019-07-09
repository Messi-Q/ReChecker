pragma solidity ^0.4.23;

 
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
  constructor() public {
    owner = msg.sender;
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

 
contract WhiteListRegistry is Ownable {

    mapping (address => WhiteListInfo) public whitelist;

    struct WhiteListInfo {
        bool whiteListed;
        uint minCap;
    }

    event AddedToWhiteList(address contributor, uint minCap);

    event RemovedFromWhiteList(address _contributor);

    function addToWhiteList(address _contributor, uint _minCap) public onlyOwner {
        require(_contributor != address(0));
        whitelist[_contributor] = WhiteListInfo(true, _minCap);
        emit AddedToWhiteList(_contributor, _minCap);
    }

    function removeFromWhiteList(address _contributor) public onlyOwner {
        require(_contributor != address(0));
        delete whitelist[_contributor];
        emit RemovedFromWhiteList(_contributor);
    }

    function isWhiteListed(address _contributor) public view returns(bool) {
        return whitelist[_contributor].whiteListed;
    }

    function isAmountAllowed(address _contributor, uint _amount) public view returns(bool) {
        return whitelist[_contributor].minCap <= _amount && isWhiteListed(_contributor);
    }
}