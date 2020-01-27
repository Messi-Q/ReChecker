pragma solidity ^0.4.24;

/**
 * Band Protocol ERC 20 Token Contract - https://bandprotocol.com
 * 
 * Based on OpenZeppelin smart contracts framework - https://openzeppelin.org
 */


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


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/**
 * @title Vesting Token
 * @dev Simple ERC20 Token with added functionality to allow adding tokens
 * to benefiaries gradually in a typical vesting scheme, with a cliff and
 * vesting period.
 */
contract VestingToken is StandardToken, Ownable {

  event Mint(
    address indexed beneficiary,
    uint256 start,
    uint256 cliff,
    uint256 duration,
    uint256 amount
  );

  event Release(
    address indexed beneficiary,
    uint256 amount
  );

  event Revoke(
    address indexed beneficiary
  );

  enum VestingStatus {
    NONEXISTENT, //< Vesting does not exist. This is the default value.
    ACTIVE,      //< Vesting is active. Beneficiary can withdraw tokens.
    REVOKED      //< Vesting has been disabled by the contract owner.
  }

  /**
   * Data structure to keep track of each beneficiary's vesting information.
   */
  struct Vesting {
    uint256 start;          //< UNIX time at which vesting starts
    uint256 cliff;          //< Duration in seconds of the cliff
    uint256 duration;       //< Duration in seconds of the vesting period
    uint256 totalAmount;    //< Total token value of this vesting
    uint256 releasedAmount; //< Total token value already released to benefiary

    VestingStatus status;   //< Status of this vesting
  }

  mapping(address => Vesting) public vestings;

  /**
   * @dev Function to mint token aggreement to the given beneficiary with
   * certain given vesting parameters.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _beneficiary,
    uint256 _start,
    uint256 _cliff,
    uint256 _duration,
    uint256 _amount
  )
    public
    onlyOwner
    returns (bool)
  {
    Vesting storage vesting = vestings[_beneficiary];
    require(vesting.status == VestingStatus.NONEXISTENT);

    vesting.start = _start;
    vesting.cliff = _cliff;
    vesting.duration = _duration;
    vesting.totalAmount = _amount;
    vesting.releasedAmount = 0;
    vesting.status = VestingStatus.ACTIVE;

    emit Mint(_beneficiary, _start, _cliff, _duration, _amount);
    return true;
  }

  /**
   * @dev Function to release tokens already vested of the transaction sender.
   * @return A boolean that indicates if the operation was successful.
   */
  function release() public returns (bool)
  {
    address beneficiary = msg.sender;

    Vesting storage vesting = vestings[beneficiary];
    require(vesting.status == VestingStatus.ACTIVE);

    uint256 amount = vestedAmount(beneficiary).sub(vesting.releasedAmount);
    require(amount > 0);

    vesting.releasedAmount = vesting.releasedAmount.add(amount);
    totalSupply_ = totalSupply_.add(amount);
    balances[beneficiary] = balances[beneficiary].add(amount);

    emit Release(beneficiary, amount);
    emit Transfer(address(0), beneficiary, amount);
    return true;
  }

  /**
   * @dev Function to revoke the beneficiary's access to unvested tokens.
   * @param _beneficiary address of the beneficiary to revoke vesting.
   * @return A boolean that indicates if the operation was successful.
   */
  function revoke(address _beneficiary) public onlyOwner returns (bool)
  {
    Vesting storage vesting = vestings[_beneficiary];
    require(vesting.status == VestingStatus.ACTIVE);

    vesting.status = VestingStatus.REVOKED;
    emit Revoke(_beneficiary);
    return true;
  }

  /**
   * @dev Calculates the amount that has already been vested.
   * @param _beneficiary The beneficiary to query for vested amount.
   */
  function vestedAmount(address _beneficiary) public view returns (uint256) {
    Vesting storage vesting = vestings[_beneficiary];

    if (block.timestamp < vesting.start.add(vesting.cliff)) {
      return 0;
    } else if (block.timestamp >= vesting.start.add(vesting.duration)) {
      return vesting.totalAmount;
    } else {
      return vesting.totalAmount.mul(
        block.timestamp.sub(vesting.start)).div(vesting.duration);
    }
  }
}


/**
 * @title Band Protocol Token
 * @dev see https://bandprotocol.com
 */
contract BandProtocolToken is VestingToken {
  string public name = "Band Protocol";
  string public symbol = "BAND";
  uint8 public decimals = 36;
}