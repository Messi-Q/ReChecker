pragma solidity ^0.4.18;

// File: contracts/commons/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

// File: contracts/flavours/Ownable.sol

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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

// File: contracts/flavours/Lockable.sol

/**
 * @title Lockable
 * @dev Base contract which allows children to
 *      implement main operations locking mechanism.
 */
contract Lockable is Ownable {
  event Lock();
  event Unlock();

  bool public locked = false;

  /**
   * @dev Modifier to make a function callable
  *       only when the contract is not locked.
   */
  modifier whenNotLocked() {
    require(!locked);
    _;
  }

  /**
   * @dev Modifier to make a function callable
   *      only when the contract is locked.
   */
  modifier whenLocked() {
    require(locked);
    _;
  }

  /**
   * @dev called by the owner to locke, triggers locked state
   */
  function lock() onlyOwner whenNotLocked public {
    locked = true;
    Lock();
  }

  /**
   * @dev called by the owner
   *      to unlock, returns to unlocked state
   */
  function unlock() onlyOwner whenLocked public {
    locked = false;
    Unlock();
  }
}

// File: contracts/base/BaseFixedERC20Token.sol

contract BaseFixedERC20Token is Lockable {
  using SafeMath for uint;

  /// @dev ERC20 Total supply
  uint public totalSupply;

  mapping(address => uint) balances;

  mapping(address => mapping (address => uint)) private allowed;

  /// @dev Fired if Token transfered accourding to ERC20
  event Transfer(address indexed from, address indexed to, uint value);

  /// @dev Fired if Token withdraw is approved accourding to ERC20
  event Approval(address indexed owner, address indexed spender, uint value);

  /**
   * @dev Gets the balance of the specified address.
   * @param owner_ The address to query the the balance of.
   * @return An uint representing the amount owned by the passed address.
   */
  function balanceOf(address owner_) public view returns (uint balance) {
    return balances[owner_];
  }

  /**
   * @dev Transfer token for a specified address
   * @param to_ The address to transfer to.
   * @param value_ The amount to be transferred.
   */
  function transfer(address to_, uint value_) whenNotLocked public returns (bool) {
    require(to_ != address(0) && value_ <= balances[msg.sender]);
    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(value_);
    balances[to_] = balances[to_].add(value_);
    Transfer(msg.sender, to_, value_);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from_ address The address which you want to send tokens from
   * @param to_ address The address which you want to transfer to
   * @param value_ uint the amount of tokens to be transferred
   */
  function transferFrom(address from_, address to_, uint value_) whenNotLocked public returns (bool) {
    require(to_ != address(0) && value_ <= balances[from_] && value_ <= allowed[from_][msg.sender]);
    balances[from_] = balances[from_].sub(value_);
    balances[to_] = balances[to_].add(value_);
    allowed[from_][msg.sender] = allowed[from_][msg.sender].sub(value_);
    Transfer(from_, to_, value_);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering.
   *
   * To change the approve amount you first have to reduce the addresses
   * allowance to zero by calling `approve(spender_, 0)` if it is not
   * already 0 to mitigate the race condition described in:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * @param spender_ The address which will spend the funds.
   * @param value_ The amount of tokens to be spent.
   */
  function approve(address spender_, uint value_) whenNotLocked public returns (bool) {
    if (value_ != 0 && allowed[msg.sender][spender_] != 0) {
      revert();
    }
    allowed[msg.sender][spender_] = value_;
    Approval(msg.sender, spender_, value_);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner_ address The address which owns the funds.
   * @param spender_ address The address which will spend the funds.
   * @return A uint specifying the amount of tokens still available for the spender.
   */
  function allowance(address owner_, address spender_) view public returns (uint) {
    return allowed[owner_][spender_];
  }
}

// File: contracts/base/BaseICOToken.sol

/**
 * @dev Not mintable, ERC20 compilant token, distributed by ICO/Pre-ICO.
 */
contract BaseICOToken is BaseFixedERC20Token {

  /// @dev Available supply of tokens
  uint public availableSupply;

  /// @dev ICO/Pre-ICO smart contract allowed to distribute public funds for this
  address public ico;

  /// @dev Fired if investment for `amount` of tokens performed by `to` address
  event ICOTokensInvested(address indexed to, uint amount);

  /// @dev ICO contract changed for this token
  event ICOChanged(address indexed icoContract);

  /**
   * @dev Not mintable, ERC20 compilant token, distributed by ICO/Pre-ICO.
   * @param totalSupply_ Total tokens supply.
   */
  function BaseICOToken(uint totalSupply_) public {
    locked = true; // Audit: I'd call lock() for better readability
    totalSupply = totalSupply_;
    availableSupply = totalSupply_;
  }

  /**
   * @dev Set address of ICO smart-contract which controls token
   * initial token distribution.
   * @param ico_ ICO contract address.
   */
  function changeICO(address ico_) onlyOwner public {
    ico = ico_;
    ICOChanged(ico);
  }

  // Audit: Keep the sender logic separated from the input validation
  // Audit Create modifier onlyICOAddress -  and use it in the icoInvestment method
  function isValidICOInvestment(address to_, uint amount_) internal view returns(bool) {
    return msg.sender == ico && to_ != address(0) && amount_ <= availableSupply;
  }

  /**
   * @dev Assign `amount_` of tokens to investor identified by `to_` address.
   * @param to_ Investor address.
   * @param amount_ Number of tokens distributed.
   */
  function icoInvestment(address to_, uint amount_) public returns (uint) {
    require(isValidICOInvestment(to_, amount_));
    availableSupply -= amount_; // Audit: Please keep using safe math here too 
    balances[to_] = balances[to_].add(amount_);
    ICOTokensInvested(to_, amount_);
    return amount_;
  }
}

// File: contracts/OTCToken.sol

/**
 * @title ERC20 OTC Token https://otcrit.org
 */
contract OTCToken is BaseICOToken {
  using SafeMath for uint;

  string public constant name = 'Otcrit token';

  string public constant symbol = 'OTC';

  uint8 public constant decimals = 18;

  uint internal constant ONE_TOKEN = 1e18;


  /// @dev Fired some tokens distributed to someone from team,bounty,parthners,others
  event ReservedTokensDistributed(address indexed to, uint8 group, uint amount);

  /**
   * @dev Constructor
   * @param totalSupplyTokens_ Total amount of tokens supplied
   * @param reservedTeamTokens_ Number of tokens reserved for team
   * @param reservedPartnersTokens_ Number of tokens reserved for partners
   * @param reservedBountyTokens_ Number of tokens reserved for bounty participants
   * @param reservedOtherTokens_ Number of privately distributed tokens reserved for others
   */
  function OTCToken(uint totalSupplyTokens_,
                    uint reservedTeamTokens_,
                    uint reservedPartnersTokens_,
                    uint reservedBountyTokens_,
                    uint reservedOtherTokens_)
    BaseICOToken(totalSupplyTokens_ * ONE_TOKEN) public {
    require(availableSupply == totalSupply);
    availableSupply = availableSupply
                        .sub(reservedTeamTokens_ * ONE_TOKEN)
                        .sub(reservedBountyTokens_ * ONE_TOKEN)
                        .sub(reservedPartnersTokens_ * ONE_TOKEN)
                        .sub(reservedOtherTokens_ * ONE_TOKEN);
    reserved[RESERVED_TEAM_SIDE] = reservedTeamTokens_ * ONE_TOKEN / 2;
    locktime[RESERVED_TEAM_SIDE] = 0;
    reserved[RESERVED_TEAM_LOCKED_SIDE] = reservedTeamTokens_ * ONE_TOKEN / 2;
    locktime[RESERVED_TEAM_LOCKED_SIDE] = block.timestamp + 2 years; // lock part for 2 years
    reserved[RESERVED_BOUNTY_SIDE] = reservedBountyTokens_ * ONE_TOKEN;
    locktime[RESERVED_BOUNTY_SIDE] = 0;
    reserved[RESERVED_PARTNERS_SIDE] = reservedPartnersTokens_ * ONE_TOKEN / 2;
    locktime[RESERVED_PARTNERS_SIDE] = 0;
    reserved[RESERVED_PARTNERS_LOCKED_SIDE] = reservedPartnersTokens_ * ONE_TOKEN / 2;
    locktime[RESERVED_PARTNERS_LOCKED_SIDE] = block.timestamp + 1 years; // lock part for 1 year
    reserved[RESERVED_OTHERS_SIDE] = reservedOtherTokens_ * ONE_TOKEN;
    locktime[RESERVED_OTHERS_SIDE] = 0;
  }

  // Disable direct payments
  function() external payable {
    revert();
  }

  //---------------------------- OTC specific

  /// @dev Tokens for team members
  uint8 public RESERVED_TEAM_SIDE = 0x1;

  /// @dev Tokens for bounty participants
  uint8 public RESERVED_BOUNTY_SIDE = 0x2;

  /// @dev Tokens for OTCRIT partners
  uint8 public RESERVED_PARTNERS_SIDE = 0x4;

  /// @dev Other privately distributed tokens
  uint8 public RESERVED_OTHERS_SIDE = 0x8;

  /// @dev Tokens for team members (locked)
  uint8 public RESERVED_TEAM_LOCKED_SIDE = 0x10;

  /// @dev Tokens for OTCRIT partners (locked)
  uint8 public RESERVED_PARTNERS_LOCKED_SIDE = 0x20;

  /// @dev Token reservation mapping: key(RESERVED_X) => value(number of tokens)
  mapping(uint8 => uint) public reserved;

  mapping(uint8 => uint) public locktime;

  /**
   * @dev Get reserved tokens for specific group
   */
  function getReservedTokens(uint8 group_) view public returns (uint) {
    return reserved[group_];
  }

  function getLockTime(uint8 group_) view public returns (uint) {
    return locktime[group_];
  }

  /**
   * @dev Assign `amount_` of privately distributed tokens
   *      to someone identified with `to_` address.
   * @param to_   Tokens owner
   * @param group_ Group identifier of privately distributed tokens
   * @param amount_ Number of tokens distributed with decimals part
   */
  function assignReserved(address to_, uint8 group_, uint amount_) onlyOwner public {
    require(to_ != address(0) && (group_ & 0x3f) != 0);
    // check lock
    require(block.timestamp > locktime[group_]);
    // SafeMath will check reserved[group_] >= amount
    reserved[group_] = reserved[group_].sub(amount_);
    balances[to_] = balances[to_].add(amount_);
    ReservedTokensDistributed(to_, group_, amount_);
  }
}