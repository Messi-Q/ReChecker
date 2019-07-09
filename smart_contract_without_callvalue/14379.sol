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


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() public {
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


 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}



contract DateTime {
        function getYear(uint timestamp) public constant returns (uint16);
        function getMonth(uint timestamp) public constant returns (uint8);
        function getDay(uint timestamp) public constant returns (uint8);
}

contract TokenDistributor {

    using SafeMath for uint256;

    address public owner;
    address public newOwnerCandidate;

    ERC20 public token;
    uint public neededAmountTotal;
    uint public releasedTokenTotal;

    address public approver;
    uint public distributedBountyTotal;

    struct DistributeList {
        uint totalAmount;
        uint releasedToken;
        LockUpData[] lockUpData;
    }    

    struct LockUpData {
        uint amount;
        uint releaseDate;
    }

     
     
     
    DateTime public dateTime;
    
    mapping (address => DistributeList) public distributeList;    

     
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferRequsted(address indexed previousOwner, address indexed newOwner);
    
    event ReceiverChanged(address indexed previousReceiver, address indexed newReceiver);
    event ReceiverRemoved(address indexed tokenReceiver);
    
    event ReleaseToken(address indexed tokenReceiver, uint amount);

    event BountyDistributed(uint listCount, uint amount);
   
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
     
    function TokenDistributor(ERC20 _tokenAddr, address _dateTimeAddr) public {
        owner = msg.sender;
        token = _tokenAddr;
        dateTime = DateTime(_dateTimeAddr); 
    }

     
    function () external  {
        releaseToken();
    }

    function requestTransferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferRequsted(owner, newOwner);
        newOwnerCandidate = newOwner;
    }

    function receiveTransferOwnership() public {
        require(newOwnerCandidate == msg.sender);
        emit OwnershipTransferred(owner, newOwnerCandidate);
        owner = newOwnerCandidate;
    }

    function addLockUpData(address _receiver, uint[] _amount, uint[] _releaseDate) public payable onlyOwner {
        require(_amount.length == _releaseDate.length && _receiver != address(0));

        uint tokenReserve;
        DistributeList storage dl = distributeList[_receiver];

         
        for (uint i = 0; i < _amount.length; i++) {
            tokenReserve += _amount[i];
        }
        
        require(neededAmountTotal.add(tokenReserve) <= token.balanceOf(this));

        for (i = 0; i < _amount.length; i++) {
            dl.lockUpData.push(LockUpData(_amount[i], _releaseDate[i]));
        }
        
        dl.totalAmount += tokenReserve;
        neededAmountTotal += tokenReserve;
        
    }
    
    function changeReceiver(address _from, address _to) public onlyOwner {
         
        require(_to != address(0) && distributeList[_to].totalAmount == 0);
        
        distributeList[_to] = distributeList[_from];
        delete distributeList[_from];
        emit ReceiverChanged(_from, _to);
    }
    
    function removeReceiver(address _receiver) public onlyOwner {
        require(distributeList[_receiver].totalAmount >= distributeList[_receiver].releasedToken);
        
         
        neededAmountTotal -= (distributeList[_receiver].totalAmount).sub(distributeList[_receiver].releasedToken);

        delete distributeList[_receiver];

        emit ReceiverRemoved(_receiver);
    }
    
    function releaseTokenByOwner(address _tokenReceiver) public onlyOwner {
        _releaseToken(_tokenReceiver);
    }
    
    function releaseToken() public {
        _releaseToken(msg.sender);
    }
    
    function _releaseToken(address _tokenReceiver) internal {

        DistributeList storage dl = distributeList[_tokenReceiver];
        uint releasableToken;

        for (uint i=0; i < dl.lockUpData.length ; i++){

            if(dl.lockUpData[i].releaseDate <= now && dl.lockUpData[i].amount > 0){
                releasableToken += dl.lockUpData[i].amount;
                dl.lockUpData[i].amount = 0;
            }
        }
        
        dl.releasedToken    += releasableToken;
        releasedTokenTotal  += releasableToken;
        neededAmountTotal   -= releasableToken;
        
        token.transfer(_tokenReceiver, releasableToken);
        emit ReleaseToken(_tokenReceiver, releasableToken);
    }
    
    function transfer(address _to, uint _amount) public onlyOwner {
        require(neededAmountTotal.add(_amount) <= token.balanceOf(this) && token.balanceOf(this) > 0);
        token.transfer(_to, _amount);
    }
    
     
    function setApprover(address _approver) public onlyOwner {
        approver = _approver;
    }
    
     
    function distributeBounty(address[] _receiver, uint[] _amount) public payable onlyOwner {
        require(_receiver.length == _amount.length);
        uint bountyAmount;
        
        for (uint i = 0; i < _amount.length; i++) {
            distributedBountyTotal += _amount[i];
            bountyAmount += _amount[i];
            token.transferFrom(approver, _receiver[i], _amount[i]);
        }
        emit BountyDistributed(_receiver.length, bountyAmount);
    }

    function viewLockUpStatus(address _tokenReceiver) public view returns (uint _totalLockedToken, uint _releasedToken, uint _releasableToken) {
    
        DistributeList storage dl = distributeList[_tokenReceiver];
        uint releasableToken;

        for (uint i=0; i < dl.lockUpData.length ; i++) {
            if(dl.lockUpData[i].releaseDate <= now && dl.lockUpData[i].amount > 0) {
                releasableToken += dl.lockUpData[i].amount;
            }
        }
        
        return (dl.totalAmount, dl.releasedToken, releasableToken);
        
    }

    function viewNextRelease(address _tokenRecv) public view returns (uint _amount, uint _year, uint _month, uint _day) {
    
        DistributeList storage dl = distributeList[_tokenRecv];
        uint _releasableToken;
        uint _releaseDate;

        for (uint i=0; i < dl.lockUpData.length ; i++){
            if(dl.lockUpData[i].releaseDate > now && dl.lockUpData[i].amount > 0){
                if(_releaseDate < dl.lockUpData[i].releaseDate || _releaseDate == 0 ){
                    _releasableToken = dl.lockUpData[i].amount;
                    _releaseDate = dl.lockUpData[i].releaseDate;
                }
            }
        }
        
        return (_releasableToken, dateTime.getYear(_releaseDate), dateTime.getMonth(_releaseDate), dateTime.getDay(_releaseDate) );

    }

    function viewContractHoldingToken() public view returns (uint _amount) {
        return (token.balanceOf(this));
    }

}