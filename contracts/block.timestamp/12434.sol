pragma solidity ^0.4.23;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: contracts/OwnedPausableToken.sol

/**
 * @title Pausable token that allows transfers by owner while paused
 * @dev StandardToken modified with pausable transfers.
 **/
contract OwnedPausableToken is StandardToken, Pausable {

  /**
   * @dev Modifier to make a function callable only when the contract is not paused or the caller is the owner
   */
  modifier whenNotPausedOrIsOwner() {
    require(!paused || msg.sender == owner);
    _;
  }

  function transfer(address _to, uint256 _value) public whenNotPausedOrIsOwner returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

// File: contracts/interfaces/IDAVToken.sol

contract IDAVToken is ERC20 {

  function name() public view returns (string) {}
  function symbol() public view returns (string) {}
  function decimals() public view returns (uint8) {}
  function increaseApproval(address _spender, uint _addedValue) public returns (bool success);
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success);

  function owner() public view returns (address) {}
  function transferOwnership(address newOwner) public;

  function burn(uint256 _value) public;

  function pauseCutoffTime() public view returns (uint256) {}
  function paused() public view returns (bool) {}
  function pause() public;
  function unpause() public;
  function setPauseCutoffTime(uint256 _pauseCutoffTime) public;

}

// File: openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

// File: contracts/DAVToken.sol

/**
 * @title DAV Token
 * @dev ERC20 token
 */
contract DAVToken is IDAVToken, BurnableToken, OwnedPausableToken {

  // Token constants
  string public name = 'DAV Token';
  string public symbol = 'DAV';
  uint8 public decimals = 18;

  // Time after which pause can no longer be called
  uint256 public pauseCutoffTime;

  /**
   * @notice DAVToken constructor
   * Runs once on initial contract creation. Sets initial supply and balances.
   */
  constructor(uint256 _initialSupply) public {
    totalSupply_ = _initialSupply;
    balances[msg.sender] = totalSupply_;
  }

  /**
   * Set the cutoff time after which the token can no longer be paused
   * Cannot be in the past. Can only be set once.
   *
   * @param _pauseCutoffTime Time for pause cutoff.
   */
  function setPauseCutoffTime(uint256 _pauseCutoffTime) onlyOwner public {
    // Make sure time is not in the past
    // solium-disable-next-line security/no-block-members
    require(_pauseCutoffTime >= block.timestamp);
    // Make sure cutoff time hasn't been set already
    require(pauseCutoffTime == 0);
    // Set the cutoff time
    pauseCutoffTime = _pauseCutoffTime;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    // Make sure pause cut off time isn't set or if it is, it's in the future
    // solium-disable-next-line security/no-block-members
    require(pauseCutoffTime == 0 || pauseCutoffTime >= block.timestamp);
    paused = true;
    emit Pause();
  }

}

// File: contracts/Identity.sol

/**
 * @title Identity
 */
contract Identity {

  struct DAVIdentity {
    address wallet;
  }

  mapping (address => DAVIdentity) private identities;

  DAVToken private token;

  // Prefix to added to messages signed by web3
  bytes28 private constant ETH_SIGNED_MESSAGE_PREFIX = '\x19Ethereum Signed Message:\n32';
  bytes25 private constant DAV_REGISTRATION_REQUEST = 'DAV Identity Registration';

  /**
   * @dev Constructor
   *
   * @param _davTokenContract address of the DAVToken contract
   */
  function Identity(DAVToken _davTokenContract) public {
    token = _davTokenContract;
  }

  function register(address _id, uint8 _v, bytes32 _r, bytes32 _s) public {
    // Make sure id isn't registered already
    require(
      identities[_id].wallet == 0x0
    );
    // Generate message hash
    bytes32 prefixedHash = keccak256(ETH_SIGNED_MESSAGE_PREFIX, keccak256(DAV_REGISTRATION_REQUEST));
    // Verify message signature
    require(
      ecrecover(prefixedHash, _v, _r, _s) == _id
    );

    // Register in identities mapping
    identities[_id] = DAVIdentity({
      wallet: msg.sender
    });
  }

  function registerSimple() public {
    // Make sure id isn't registered already
    require(
      identities[msg.sender].wallet == 0x0
    );

    // Register in identities mapping
    identities[msg.sender] = DAVIdentity({
      wallet: msg.sender
    });
  }

  function getBalance(address _id) public view returns (uint256 balance) {
    return token.balanceOf(identities[_id].wallet);
  }

  function verifyOwnership(address _id, address _wallet) public view returns (bool verified) {
    return identities[_id].wallet == _wallet;
  }

  // Check identity registration status
  function isRegistered(address _id) public view returns (bool) {
    return identities[_id].wallet != 0x0;
  }

  // Get identity wallet
  function getIdentityWallet(address _id) public view returns (address) {
    return identities[_id].wallet;
  }
}

// File: contracts/BasicMission.sol

/**
 * @title BasicMission
 * @dev The most basic contract for conducting Missions.
 *
 * This contract represents the very basic interface of a mission contract.
 * In the real world, there is very little reason to use this and not one of the
 * contracts that extend it. Consider this an interface, more than an implementation.
 */
contract BasicMission {

  uint256 private nonce;

  struct Mission {
    address seller;
    address buyer;
    uint256 cost;
    uint256 balance;
    bool isSigned;
    mapping (uint8 => bool) resolvers;
  }

  mapping (bytes32 => Mission) private missions;

  event Create(
    bytes32 id,
    address sellerId,
    address buyerId
  );

  event Signed(
    bytes32 id
  );

  DAVToken private token;
  Identity private identity;

  /**
   * @dev Constructor
   *
   * @param _identityContract address of the Identity contract
   * @param _davTokenContract address of the DAVToken contract
   */
  function BasicMission(Identity _identityContract, DAVToken _davTokenContract) public {
    identity = _identityContract;
    token = _davTokenContract;
  }

  /**
   * @notice Create a new mission
   * @param _sellerId The DAV Identity of the person providing the service
   * @param _buyerId The DAV Identity of the person ordering the service
   * @param _cost The total cost of the mission to be paid by buyer
   */
  function create(bytes32 _missionId, address _sellerId, address _buyerId, uint256 _cost) public {
    // Verify that message sender controls the buyer's wallet
    require(
      identity.verifyOwnership(_buyerId, msg.sender)
    );

    // Verify buyer's balance is sufficient
    require(
      identity.getBalance(_buyerId) >= _cost
    );

    // Make sure id isn't registered already
    require(
      missions[_missionId].buyer == 0x0
    );

    // Transfer tokens to the mission contract
    token.transferFrom(msg.sender, this, _cost);

    // Create mission
    missions[_missionId] = Mission({
      seller: _sellerId,
      buyer: _buyerId,
      cost: _cost,
      balance: _cost,
      isSigned: false
    });

    // Event
    emit Create(_missionId, _sellerId, _buyerId);
  }

  /**
  * @notice Fund a mission
  * @param _missionId The id of the mission
  * @param _buyerId The DAV Identity of the person ordering the service
  */
  function fulfilled(bytes32 _missionId, address _buyerId) public {
    // Verify that message sender controls the seller's wallet
    require(
      identity.verifyOwnership(_buyerId, msg.sender)
    );
    
    require(
      missions[_missionId].isSigned == false
    );

    require(
      missions[_missionId].balance == missions[_missionId].cost
    );
    
    
    // designate mission as signed
    missions[_missionId].isSigned = true;
    missions[_missionId].balance = 0;
    token.approve(this, missions[_missionId].cost);
    token.transferFrom(this, identity.getIdentityWallet(missions[_missionId].seller), missions[_missionId].cost);

    // Event
    emit Signed(_missionId);
  }

}