pragma solidity ^0.4.24;

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.
  /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056
  uint private constant REENTRANCY_GUARD_FREE = 1;

  /// @dev Constant for locked guard state
  uint private constant REENTRANCY_GUARD_LOCKED = 2;

  /**
   * @dev We use a single lock for the whole contract.
   */
  uint private reentrancyLock = REENTRANCY_GUARD_FREE;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one `nonReentrant` function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and an `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(reentrancyLock == REENTRANCY_GUARD_FREE);
    reentrancyLock = REENTRANCY_GUARD_LOCKED;
    _;
    reentrancyLock = REENTRANCY_GUARD_FREE;
  }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

/*
* There are 4 entities in this contract - 
#1 `company` - This is the company which is going to place a bounty of tokens
#2 `referrer` - This is the referrer who refers a candidate that gets a job finally
#3 `candidate` - This is the candidate who gets a job finally
#4 `owner` - Indorse as a company will be the owner of this contract
*
*/

contract JobsBounty is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    string public companyName; //Name of the company who is putting the bounty
    string public jobPost; //Link to the job post for this Smart Contract
    uint public endDate; //Unix timestamp of the end date of this contract when the bounty can be released
    
    // On Rinkeby
    // address public INDToken = 0x656c7da9501bB3e4A5a544546230D74c154A42eb;
    // On Mainnet
    // address public INDToken = 0xf8e386eda857484f5a12e4b5daa9984e06e73705;
    
    address public INDToken;
    
    constructor(string _companyName,
                string _jobPost,
                uint _endDate,
                address _INDToken
                ) public{
        companyName = _companyName;
        jobPost = _jobPost ;
        endDate = _endDate;
        INDToken = _INDToken;
    }
    
    //Helper function, not really needed, but good to have for the sake of posterity
    function ownBalance() public view returns(uint256) {
        return SafeMath.div(ERC20(INDToken).balanceOf(this),1 ether);
    }
    
    function payOutBounty(address _referrerAddress, address _candidateAddress) external onlyOwner nonReentrant returns(bool){
        assert(block.timestamp >= endDate);
        assert(_referrerAddress != address(0x0));
        assert(_candidateAddress != address(0x0));
        
        uint256 individualAmounts = SafeMath.mul(SafeMath.div((ERC20(INDToken).balanceOf(this)),100),50);
        
        // Tranferring to the candidate first
        assert(ERC20(INDToken).transfer(_candidateAddress, individualAmounts));
        assert(ERC20(INDToken).transfer(_referrerAddress, individualAmounts));
        return true;    
    }
    
    //This function can be used in 2 instances - 
    // 1st one if to withdraw tokens that are accidentally send to this Contract
    // 2nd is to actually withdraw the tokens and return it to the company in case they don't find a candidate
    function withdrawERC20Token(address anyToken) external onlyOwner nonReentrant returns(bool){
        assert(block.timestamp >= endDate);
        assert(ERC20(anyToken).transfer(owner, ERC20(anyToken).balanceOf(this)));        
        return true;
    }
    
    //ETH cannot get locked in this contract. If it does, this can be used to withdraw
    //the locked ether.
    function withdrawEther() external onlyOwner nonReentrant returns(bool){
        if(address(this).balance > 0){
            owner.transfer(address(this).balance);
        }        
        return true;
    }
}