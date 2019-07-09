pragma solidity 0.4.21;


 
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


 
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}


 
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


contract Whitelisting is Ownable {
    mapping(address => bool) public isInvestorApproved;

    event Approved(address indexed investor);
    event Disapproved(address indexed investor);

    function approveInvestor(address toApprove) public onlyOwner {
        isInvestorApproved[toApprove] = true;
        emit Approved(toApprove);
    }

    function approveInvestorsInBulk(address[] toApprove) public onlyOwner {
        for (uint i=0; i<toApprove.length; i++) {
            isInvestorApproved[toApprove[i]] = true;
            emit Approved(toApprove[i]);
        }
    }

    function disapproveInvestor(address toDisapprove) public onlyOwner {
        delete isInvestorApproved[toDisapprove];
        emit Disapproved(toDisapprove);
    }

    function disapproveInvestorsInBulk(address[] toDisapprove) public onlyOwner {
        for (uint i=0; i<toDisapprove.length; i++) {
            delete isInvestorApproved[toDisapprove[i]];
            emit Disapproved(toDisapprove[i]);
        }
    }
}


 
contract TokenVesting is Ownable {
    using SafeERC20 for ERC20Basic;
    using SafeMath for uint256;

     
    ERC20Basic public token;
     
    Whitelisting public whitelisting;

    struct VestingObj {
        uint256 token;
        uint256 releaseTime;
    }

    mapping (address  => VestingObj[]) public vestingObj;

    uint256 public totalTokenVested;

    event AddVesting ( address indexed _beneficiary, uint256 token, uint256 _vestingTime);
    event Release ( address indexed _beneficiary, uint256 token, uint256 _releaseTime);

    modifier checkZeroAddress(address _add) {
        require(_add != address(0));
        _;
    }

    function TokenVesting(ERC20Basic _token, Whitelisting _whitelisting)
        public
        checkZeroAddress(_token)
        checkZeroAddress(_whitelisting)
    {
        token = _token;
        whitelisting = _whitelisting;
    }

    function addVesting( address[] _beneficiary, uint256[] _token, uint256[] _vestingTime) 
        external 
        onlyOwner
    {
        require((_beneficiary.length == _token.length) && (_beneficiary.length == _vestingTime.length));
        
        for (uint i = 0; i < _beneficiary.length; i++) {
            require(_vestingTime[i] > now);
            require(checkZeroValue(_token[i]));
            require(uint256(getBalance()) >= totalTokenVested.add(_token[i]));
            vestingObj[_beneficiary[i]].push(VestingObj({
                token : _token[i],
                releaseTime : _vestingTime[i]
            }));
            totalTokenVested = totalTokenVested.add(_token[i]);
            emit AddVesting(_beneficiary[i], _token[i], _vestingTime[i]);
        }
    }

     
    function claim() external {
        require(whitelisting.isInvestorApproved(msg.sender));
        uint256 transferTokenCount = 0;
        for (uint i = 0; i < vestingObj[msg.sender].length; i++) {
            if (now >= vestingObj[msg.sender][i].releaseTime) {
                transferTokenCount = transferTokenCount.add(vestingObj[msg.sender][i].token);
                delete vestingObj[msg.sender][i];
            }
        }
        require(transferTokenCount > 0);
        token.safeTransfer(msg.sender, transferTokenCount);
        emit Release(msg.sender, transferTokenCount, now);
    }

    function getBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
    
    function checkZeroValue(uint256 value) internal returns(bool){
        return value > 0;
    }
}