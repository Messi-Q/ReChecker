pragma solidity ^0.4.13;

/// @dev This contract is used to generate clone contracts from a contract.
///  In solidity this is the way to create a contract from a contract of the
///  same class
contract MiniMeTokenFactory {

    function MiniMeTokenFactory() {
    }

    /// @notice Update the DApp by creating a new token with new functionalities
    ///  the msg.sender becomes the controller of this clone token
    /// @param _parentToken Address of the token being cloned
    /// @param _snapshotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    /// @return The address of the new token contract
    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) returns (MiniMeToken) 
    {
        MiniMeToken newToken = new MiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}

/// @dev The token controller contract must implement these functions
contract TokenController {
    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) payable returns(bool);

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) returns(bool);

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool);
}


contract Controlled {
    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() { controller = msg.sender;}

    /// @notice Changes the controller of the contract
    /// @param _newController The new controller of the contract
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data);
}

/*
    Copyright 2016, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title MiniMeToken Contract
/// @author Jordi Baylina
/// @dev This token contract's goal is to make it easy for anyone to clone this
///  token using the token distribution at a given block, this will allow DAO's
///  and DApps to upgrade their features in a decentralized manner without
///  affecting the original token
/// @dev It is ERC20 compliant, but still needs to under go further testing.

/// @dev The actual token contract, the default controller is the msg.sender
///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract MiniMeToken is Controlled {

    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = 'MMT_0.1'; //An arbitrary versioning scheme


    /// @dev `Checkpoint` is the structure that attaches a block number to a
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct  Checkpoint {

        // `fromBlock` is the block number that the value was generated from
        uint128 fromBlock;

        // `value` is the amount of tokens at a specific block number
        uint128 value;
    }

    // `parentToken` is the Token address that was cloned to produce this token;
    //  it will be 0x0 for a token that was not cloned
    MiniMeToken public parentToken;

    // `parentSnapShotBlock` is the block number from the Parent Token that was
    //  used to determine the initial distribution of the Clone Token
    uint public parentSnapShotBlock;

    // `creationBlock` is the block number that the Clone Token was created
    uint public creationBlock;

    // `balances` is the map that tracks the balance of each address, in this
    //  contract when the balance changes the block number that the change
    //  occurred is also included in the map
    mapping (address => Checkpoint[]) balances;

    // `allowed` tracks any extra transfer rights as in all ERC20 tokens
    mapping (address => mapping (address => uint256)) allowed;

    // Tracks the history of the `totalSupply` of the token
    Checkpoint[] totalSupplyHistory;

    // Flag that determines if the token is transferable or not.
    bool public transfersEnabled;

    // The factory used to create new clone tokens
    MiniMeTokenFactory public tokenFactory;

////////////////
// Constructor
////////////////

    /// @notice Constructor to create a MiniMeToken
    /// @param _tokenFactory The address of the MiniMeTokenFactory contract that
    ///  will create the Clone token contracts, the token factory needs to be
    ///  deployed first
    /// @param _parentToken Address of the parent token, set to 0x0 if it is a
    ///  new token
    /// @param _parentSnapShotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token, set to 0 if it
    ///  is a new token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    function MiniMeToken(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) 
    Controlled()
    {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }


///////////////////
// ERC20 Methods
///////////////////

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) returns (bool success) {
        require(transfersEnabled);
        return doTransfer(msg.sender, _to, _amount);
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount
    ) returns (bool success) {

        // The controller of this contract can move tokens around at will,

        //  controller of this contract, which in most situations should be
        //  another open source smart contract or 0x0
        if (msg.sender != controller) {
            require(transfersEnabled);

            // The standard ERC 20 transferFrom functionality
            if (allowed[_from][msg.sender] < _amount) return false;
            allowed[_from][msg.sender] -= _amount;
        }
        return doTransfer(_from, _to, _amount);
    }

    /// @dev This is the actual transfer function in the token contract, it can
    ///  only be called by other functions in this contract.
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function doTransfer(address _from, address _to, uint _amount
    ) internal returns(bool) {

           if (_amount == 0) {
               return true;
           }

           require(parentSnapShotBlock < block.number);

           // Do not allow transfer to 0x0 or the token contract itself
           require((_to != 0) && (_to != address(this)));

           // If the amount being transfered is more than the balance of the
           //  account the transfer returns false
           var previousBalanceFrom = balanceOfAt(_from, block.number);
           if (previousBalanceFrom < _amount) {
               return false;
           }

           // First update the balance array with the new value for the address
           //  sending the tokens
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           // Then update the balance array with the new value for the address
           //  receiving the tokens
           var previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           // An event to make the transfer easy to find on the blockchain
           Transfer(_from, _to, _amount);

           return true;
    }

    /// @param _owner The address that's balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount) returns (bool success) {
        require(transfersEnabled);

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    ///  to spend
    function allowance(address _owner, address _spender
    ) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    /// @param _spender The address of the contract able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the function call was successful
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

    /// @dev This function makes it easy to get the total number of tokens
    /// @return The total number of tokens
    function totalSupply() constant returns (uint) {
        return totalSupplyAt(block.number);
    }


////////////////
// Query balance and totalSupply in History
////////////////

    /// @dev Queries the balance of `_owner` at a specific `_blockNumber`
    /// @param _owner The address from which the balance will be retrieved
    /// @param _blockNumber The block number when the balance is queried
    /// @return The balance at `_blockNumber`
    function balanceOfAt(address _owner, uint _blockNumber) constant
        returns (uint) {

        // These next few lines are used when the balance of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.balanceOfAt` be queried at the
        //  genesis block for that token as this contains initial balance of
        //  this token
        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                // Has no parent
                return 0;
            }

        // This will return the expected balance during normal situations
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    /// @notice Total amount of tokens at a specific `_blockNumber`.
    /// @param _blockNumber The block number when the totalSupply is queried
    /// @return The total amount of tokens at `_blockNumber`
    function totalSupplyAt(uint _blockNumber) constant returns(uint) {

        // These next few lines are used when the totalSupply of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.totalSupplyAt` be queried at the
        //  genesis block for this token as that contains totalSupply of this
        //  token at this block number.
        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        // This will return the expected totalSupply during normal situations
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

////////////////
// Clone Token Method
////////////////

    /// @notice Creates a new clone token with the initial distribution being
    ///  this token at `_snapshotBlock`
    /// @param _cloneTokenName Name of the clone token
    /// @param _cloneDecimalUnits Number of decimals of the smallest unit
    /// @param _cloneTokenSymbol Symbol of the clone token
    /// @param _snapshotBlock Block when the distribution of the parent token is
    ///  copied to set the initial distribution of the new clone token;
    ///  if the block is zero than the actual block, the current block is used
    /// @param _transfersEnabled True if transfers are allowed in the clone
    /// @return The address of the new MiniMeToken Contract
    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

        // An event to make the token easy to find on the blockchain
        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

////////////////
// Generate and destroy tokens
////////////////


    /// @notice Generates `_amount` tokens that are assigned to `_owner`
    /// @param _owner The address that will be assigned the new tokens
    /// @param _amount The quantity of tokens generated
    /// @return True if the tokens are generated correctly
    function generateTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


    /// @notice Burns `_amount` tokens from `_owner`
    /// @param _owner The address that will lose the tokens
    /// @param _amount The quantity of tokens to burn
    /// @return True if the tokens are burned correctly
    function destroyTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }

////////////////
// Enable tokens transfers
////////////////


    /// @notice Enables token holders to transfer their tokens freely if true
    /// @param _transfersEnabled True if transfers are allowed in the clone
    function enableTransfers(bool _transfersEnabled) onlyController {
        transfersEnabled = _transfersEnabled;
    }

////////////////
// Internal helper functions to query and set a value in a snapshot array
////////////////

    /// @dev `getValueAt` retrieves the number of tokens at a given block number
    /// @param checkpoints The history of values being queried
    /// @param _block The block number to retrieve the value at
    /// @return The number of tokens being queried
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    /// @dev `updateValueAtNow` used to update the `balances` map and the
    ///  `totalSupplyHistory`
    /// @param checkpoints The history of data being updated
    /// @param _value The new number of tokens
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    /// @dev Helper function to return a min betwen the two uints
    function min(uint a, uint b) internal returns (uint) {
        return a < b ? a : b;
    }

    /// @notice The fallback function: If the contract's controller has not been
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function () payable {
        // Fail any transfers into the token contract
        require(false);
    }

//////////
// Safety Methods
//////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

////////////////
// Events
////////////////
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * This contract inherits from the MinimeToken and adds minting capability.
 * When the sale is started, the token ownership is handed over to the Crowsdale contract.
 * The crowdsale contract will not call the "generateTokens()" call directly in the MinimeToken, 
 * but will instead use the minting functionality here.
 */
contract MiniMeMintableToken is MiniMeToken {
  using SafeMath for uint256;

  // Events to notify about Minting
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  // Flag to track whether minting is still allowed.
  bool public mintingFinished = false;

  // This map will keep track of how many tokens were issued during the token sale.
  // This value will then be used for vesting calculations from the point where the token contract is finished minting.
  mapping (address => uint256) issuedTokens;

  // Modifier to allow minting of tokens.
  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  // Pass through consructor
  function MiniMeMintableToken(
    address _tokenFactory,
    address _parentToken,
    uint _parentSnapShotBlock,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol,
    bool _transfersEnabled
  ) 
  MiniMeToken(
    _tokenFactory,
    _parentToken,
    _parentSnapShotBlock,
    _tokenName,
    _decimalUnits,
    _tokenSymbol,
    _transfersEnabled
  )
  {
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyController canMint returns (bool) {

    // First, generate the tokens in the base Minime class balances.
    generateTokens(_to, _amount);

    // Save off the amount that this account has been issued during the minting period so vesting can be calculated.
    issuedTokens[_to] = issuedTokens[_to].add(_amount);

    // Trigger the minting event notification
    Mint(_to, _amount);

    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyController canMint returns (bool) {

    // Set the minting finished so that tokens can be transferred once vested.
    // This flag will prevent new tokens from being minted in the future.
    mintingFinished = true;

    // Trigger the notification that minting has finished.
    MintFinished();
    
    return true;
  }
}

/**
 * This contract defines the tokens for the SWARM platform.
 * It inherits from the MiniMeToken contract which allows sub-tokens to be created.
 * This token also implements a vesting schedule on any tokens that are minted during the pre-sale.
 * The MintableToken contract is adapted from the Open Zeppelin contract.
 */
contract MiniMeVestedToken is MiniMeMintableToken {
  using SafeMath for uint256;

  // This value will keep track of the time when the minting is finished after the crowd sale ends.
  // Vesting will start accruing at this point in time.
  uint256 public vestingStartTime = 0;

  // Default vesting period is 42 days, with a max of 8 periods
  uint256 public vestingPeriodTime = 42 days;
  uint256 public vestingTotalPeriods = 8;

  // Pass through consructor
  function MiniMeVestedToken(
    address _tokenFactory,
    address _parentToken,
    uint _parentSnapShotBlock,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol,
    bool _transfersEnabled
  ) 
  MiniMeMintableToken(
    _tokenFactory,
    _parentToken,
    _parentSnapShotBlock,
    _tokenName,
    _decimalUnits,
    _tokenSymbol,
    _transfersEnabled
  )
  {
  }

////////////////////
// Token Transfers
////////////////////

  /**
   * Modifier to functions to see if the vested balance is higher than requested transfer amount.
   * Also enforces that the minting phase of the sale is over.
   */
  modifier canTransfer(address _sender, uint _value) {
    require(mintingFinished);
    require(_value <= vestedBalanceOf(_sender));
    _;
  }

  /**
   * Override the base transfer class to enforce vesting requirement is met
   */
  function transfer(address _to, uint _value)
    canTransfer(msg.sender, _value)
    public
    returns (bool success)
  {
    return super.transfer(_to, _value);
  }

  /**
   * Override the base transferFrom class to enforce vesting requirement is met
   */
  function transferFrom(address _from, address _to, uint _value)
    canTransfer(_from, _value)
    public
    returns (bool success)
  {
    return super.transferFrom(_from, _to, _value);
  }

////////////////////
// Token Vesting
///////////////////

  /**
   * Allow vesting schedule params to be overridden.
   */
  function setVestingParams(uint256 _vestingStartTime, uint256 _vestingTotalPeriods, uint256 _vestingPeriodTime) onlyController {
    vestingStartTime = _vestingStartTime;
    vestingTotalPeriods = _vestingTotalPeriods;
    vestingPeriodTime = _vestingPeriodTime;
  }

  /**
    * Gets the number of vesting periods that have completed from the start time to the current time.
    */
  function getVestingPeriodsCompleted(uint256 _vestingStartTime, uint256 _currentTime) public constant returns (uint256) {
      return _currentTime.sub(_vestingStartTime).div(vestingPeriodTime);
  }

  /**
    * Gets the vested balance for an account.
    * initialBalance - The amount that was allocated at the start of vesting.
    * currentBalance - The amount that is currently in the account.
    * vestingStartTime - The time stamp (seconds since unix epoch) when vesting started.
    * currentTime - The current time stamp (seconds since unix epoch).
    */
  function getVestedBalance(uint256 _initialBalance, uint256 _currentBalance, uint256 _vestingStartTime, uint256 _currentTime)
      public constant returns (uint256)
  {
      // Short-cut if vesting hasn't started yet
      if (_currentTime < _vestingStartTime) {
        return 0;
      }
      
      // Short-cut the vesting calculations if the vesting periods are completed
      if (_currentTime >= _vestingStartTime.add(vestingPeriodTime.mul(vestingTotalPeriods))) {
          return _currentBalance;
      }

      // First, get the number of vesting periods completed
      uint256 vestedPeriodsCompleted = getVestingPeriodsCompleted(_vestingStartTime, _currentTime);

      // Calculate the amount that should be withheld.
      uint256 vestingPeriodsRemaining = vestingTotalPeriods.sub(vestedPeriodsCompleted);
      uint256 unvestedBalance = _initialBalance.mul(vestingPeriodsRemaining).div(vestingTotalPeriods);

      // Return the current balance minus any that is still unvested.
      return _currentBalance.sub(unvestedBalance);
  }

  /**
   * Convenience method - Get the vested balance of the address.
   */
  function vestedBalanceOf(address _owner) public constant returns (uint256 balance) {
    return getVestedBalance(issuedTokens[_owner], balanceOf(_owner), vestingStartTime, block.timestamp);
  }

  /**
   * At the end of the sale, this should be called to trigger the vesting to start.
   * Tokens cannot be transferred prior to this being called.
   */
  function finishMinting() onlyController canMint returns (bool) {
    // Set the time stamp for tokens to start vesting
    vestingStartTime = block.timestamp;

    return super.finishMinting();
  }
}

contract SwarmToken is MiniMeVestedToken {

  /**
   * Constructor to initialize Swarm Token.
   * Factory is pre-deployed and passed in.
   *
   * @author poole_party via tokensoft.io
   */
  function SwarmToken(address _tokenFactory)
    MiniMeVestedToken(
      _tokenFactory,
      0x0,
      0,
      "Swarm Fund Token",
      18,
      "SWM",
      true
    )
    {}    
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

/**
 * @title Crowdsale 
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end block, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet 
 * as they arrive.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  SwarmToken public token;

  // start and end time where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // Initial rate of how many tokens a buyer gets per ETH the send in.
  uint256 public rate;

  // amount of raised ETH in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */ 
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  /**
   * Constructor to save off args defining the sale.
   */
  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, address _token) {
    require(_startTime >= block.timestamp);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);


    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
    token = SwarmToken(_token);
  }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable;

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    uint256 current = block.timestamp;
    bool withinPeriod = current >= startTime && current <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return block.timestamp > endTime;
  }
}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowsdale where an owner can do extra work
 * after finishing. By default, it will end token minting.
 */
contract FinalizableCrowdsale is Crowdsale, Pausable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * Pass through constructor to parents.
   */
  function FinalizableCrowdsale (
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rate,
    address _wallet,
    address _token
  )
    Crowdsale(_startTime, _endTime, _rate, _wallet, _token)
    Ownable()
  {
  }

  // should be called after crowdsale ends, to do
  // some extra finalization work
  function finalize() onlyOwner {
    require(!isFinalized);
    require(hasEnded());

    // Set the flag to prevent another finalization
    isFinalized = true;

    // Call the finalization function in the implementing class.
    finalization();

    // Trigger the finalized event.
    Finalized();
  }

  // end token minting on finalization
  // override this with custom logic if needed
  function finalization() internal;

}

/**
 * @title SwarmCrowdsale
 * @dev SwarmCrowdsale is a contract for managing a token crowdsale.
 * Crowdsales have a start and end time stamp, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 * 
 * Time values are in seconds since unix epoch.
 *
 * Rate is initial value of ETH in USD.  Each token starts out costing approx 1 USD and increases
 * as tokens are sold.  rate = USD price of ETH (e.g. "300")
 *
 * Wallet is the address where all incoming funds will be forwarded.  Should be a multisig for security.
 *
 * @author poole_party via tokensoft.io
 */
contract SwarmCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;  

  // The amount of tokens sold during the crowdsale
  uint256 public baseTokensSold = 0;

  // Token base units are 18 decimals
  uint256 constant TOKEN_DECIMALS = 10**18;

  // Target tokens sold is 33 million
  uint256 constant TOKEN_TARGET_SOLD = 33333333 * TOKEN_DECIMALS;

  // Cap on the crowdsale for number of tokens - 33,333,333 tokens
  uint256 constant MAX_TOKEN_SALE_CAP = 33333333 * TOKEN_DECIMALS;

  bool public initialized = false;

  /**
   * Pass through constructor to parent.
   */
  function SwarmCrowdsale (
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rate,
    address _wallet,
    address _token,
    uint256 _baseTokensSold
  )
    FinalizableCrowdsale(_startTime, _endTime, _rate, _wallet, _token)
  {
    baseTokensSold = _baseTokensSold;
  }

  /**
  * Allows any pre-allocations to bet set for presale purchases or team member allocations.
  */
  function presaleMint(address _to, uint256 _amt) onlyOwner {
    require(!initialized);

    token.mint(_to, _amt);
  }

  /**
  * Allows a list of pre-allocations to bet set for presale purchases or team member allocations.
  */
  function multiPresaleMint(address[] _toArray, uint256[] _amtArray) onlyOwner {
    require(!initialized);

    // Ensure the array has items
    require(_toArray.length > 0);

    // Ensure the arrays are the same length
    require(_toArray.length == _amtArray.length);

    // Iterate over the 
    for (uint i = 0; i < _toArray.length; i++) {
      token.mint(_toArray[i], _amtArray[i]);
    }    
  }

  /**
  * Sets the intitialized flag to true so that the presale can start and minting is finished
  */
  function initializeToken() onlyOwner {
    // Allow this to only be called once by the owner.
    require(!initialized);
    initialized = true;
  }

  /**
  * Allows the owner to set the tokens sold, based on the number of presale purchases
  */
  function setBaseTokensSold(uint256 _baseTokensSold) onlyOwner {
    baseTokensSold = _baseTokensSold;
  }

  /**
   * Function to allow users to purchase tokens based on the calculated sale rate.
   */
  function buyTokens(address beneficiary) public payable whenNotPaused {
    require(beneficiary != 0x0);
    require(validPurchase());
    require(initialized);

    uint256 weiAmount = msg.value;

    // Calculate token amount to be created.
    // Uses dynamic price calculator based on current number of sold tokens.
    uint256 tokens = weiAmount.mul(getSaleRate(baseTokensSold));

    // update state
    weiRaised = weiRaised.add(weiAmount);
    baseTokensSold = baseTokensSold.add(tokens);

    // Enforce the cap on the crowd sale - do not allow a sale to go over the max
    require(baseTokensSold <= MAX_TOKEN_SALE_CAP);

    // Mint the tokens for the purchaser
    token.mint(beneficiary, tokens);    
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    
    forwardFunds();
  }

  /**
    * Overrides Base Function.
    * Take any finalization actions here
    * Ends token minting on finalization
    */
    function finalization() internal whenNotPaused {

      // Handle unsold token logic
      transferUnallocatedTokens();

      // Complete minting and start vesting of token
      token.finishMinting();

      // Transfer ownership to the wallet
      token.changeController(wallet);
    }

    /**
     * According to the terms of the sale, a minimum of 33 million tokens are to allocated for the crowd sale.
     * If the public does not buy 33 million tokens then the amount sold is subtracted from 33 million and allocated to the Swarm Foundation.
     * This function will mint any remaining tokens of the 33 minimum to the "wallet" account.
     */
    function transferUnallocatedTokens() internal {      

      // If the minimum amount sold was met, then take no action
      if (baseTokensSold > TOKEN_TARGET_SOLD) {
        return;
      }

      // Minimum tokens were not sold.  Get the amount to transfer and assign to wallet address.
      uint256 amountToTransfer = TOKEN_TARGET_SOLD.sub(baseTokensSold);
      token.mint(wallet, amountToTransfer);
    }

  /**
    * Gets the current price of the tokens based on the current sold amount (currentBaseTokensSold).
    * The variable "rate" from the base class is the initial purchase multiplier.
    * As new tokens get purchased, the price increases according the the algorithm outlined in the whitepaper.
    * Each generation you will get less tokens per ETH sent in.
    * param - uint256 currentTokensSold Amount of tokens already sold in "base units".
    * returns - uint256 Current number of tokens you get for each ETH sent in.
    */
  function getSaleRate(uint256 currentBaseTokensSold) public constant returns (uint256) {

    // Base units per token
    uint decimals = TOKEN_DECIMALS;

    // Get the whole units of tokens sold
    uint256 wholeTokensSold = currentBaseTokensSold.div(decimals);

    // Get the current generation of the token sale.  Each gen is 1 million whole tokens.
    uint256 generation = wholeTokensSold.div(10**6);

    // Init the price multiplier at 0.  It should always go through the loop below at least once.
    uint256 priceMultiplier = 0;

    // Each generation adds on a price premium that decreases with each generation.
    for (uint i = 0; i <= generation; i++) {

      // The multiplier is calculated at 10^18 units since uint256 can't handle decimals.
      priceMultiplier = priceMultiplier.add(decimals.div(1 + i));
    }

    // Return the initial rate divided by the multiplier.
    // To ensure int division doesn't truncate, using rate * 10^18 in numerator.      
    // If initial rate is 300 then the second generation should return => 300*10^18 / 1.5*10^18  => 200 (e.g less tokens per ETH the second gen)
    return rate.mul(decimals).div(priceMultiplier);
  }

  /**
   * Convenience method for users.
   */
  function getCurrentSaleRate() public constant returns (uint256) {
    return getSaleRate(baseTokensSold);
  }
}