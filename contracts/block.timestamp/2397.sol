pragma solidity ^0.4.24;

// copyright vFloorplan Ltd 2018

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
*/
 
library SafeMath 
{
  function mul(uint256 a, uint256 b) internal pure returns (uint256) 
  {
      if (a==0)
      {
          return 0;
      }
      
    uint256 c = a * b;
    assert(c / a == b); // assert on overflow
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) 
  {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) 
  {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256)
  {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic
{
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic
{
    // founder details
    address public constant FOUNDER_ADDRESS1 = 0xcb8Fb8Bf927e748c0679375B26fb9f2F12f3D5eE;
    address public constant FOUNDER_ADDRESS2 = 0x1Ebfe7c17a22E223965f7B80c02D3d2805DFbE5F;
    address public constant FOUNDER_ADDRESS3 = 0x9C5076C3e95C0421699A6D9d66a219BF5Ba5D826;
    
    address public constant FOUNDER_FUND_1 = 9000000000;
    address public constant FOUNDER_FUND_2 = 9000000000;
    address public constant FOUNDER_FUND_3 = 7000000000;
    
    // deposit address for reserve / crowdsale
    address public constant MEW_RESERVE_FUND = 0xD11ffBea1cE043a8d8dDDb85F258b1b164AF3da4; // multisig
    address public constant MEW_CROWDSALE_FUND = 0x842C4EA879050742b42c8b2E43f1C558AD0d1741; // multisig
    
    uint256 public constant decimals = 18;
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  
  // all initialised to false - do we want multi-state? maybe... 
  mapping(address => uint256) public mCanSpend;
  mapping(address => uint256) public mEtherSpent;
  
  int256 public mEtherValid;
  int256 public mEtherInvalid;
  
  // real
  // standard unlocked tokens will vest immediately on the prime vesting date
  // founder tokens will vest at a rate per day
  uint256 public constant TOTAL_RESERVE_FUND =  40 * (10**9) * 10**decimals;  // 40B reserve created before sale
  uint256 public constant TOTAL_CROWDSALE_FUND =  60 * (10**9) * 10**decimals;  // 40B reserve created before sale
  uint256 public PRIME_VESTING_DATE = 0xffffffffffffffff; // will set to rough dates then fix at end of sale
  uint256 public FINAL_AML_DATE = 0xffffffffffffffff; // will set to rough date + 3 months then fix at end of sale
  uint256 public constant FINAL_AML_DAYS = 90;
  uint256 public constant DAYSECONDS = 24*60*60;//86400; // 1 day in seconds // 1 minute vesting
  
  mapping(address => uint256) public mVestingDays;  // number of days to fully vest
  mapping(address => uint256) public mVestingBalance; // total balance which will vest
  mapping(address => uint256) public mVestingSpent; // total spent
  mapping(address => uint256) public mVestingBegins; // total spent
  
  mapping(address => uint256) public mVestingAllowed; // really just for checking
  
  // used to enquire about the ether spent to buy the tokens
  function GetEtherSpent(address from) view public returns (uint256)
  {
      return mEtherSpent[from];
  }
  
  // removes tokens and returns them to the main pool
  // this is called if 
  function RevokeTokens(address target) internal
  {
      //require(mCanSpend[from]==0),"Can only call this if AML hasn't been completed correctly");
      // block this address from further spending
      require(mCanSpend[target]!=9);
      mCanSpend[target]=9;
      
      uint256 _value = balances[target];
      
      balances[target] = 0;//just wipe the balance
      
      balances[MEW_RESERVE_FUND] = balances[MEW_RESERVE_FUND].add(_value);
      
      // let the blockchain know its been revoked
      emit Transfer(target, MEW_RESERVE_FUND, _value);
  }
  
  function LockedCrowdSale(address target) view internal returns (bool)
  {
      if (mCanSpend[target]==0 && mEtherSpent[target]>0)
      {
          return true;
      }
      return false;
  }
  
  function CheckRevoke(address target) internal returns (bool)
  {
      // roll vesting / dates and AML in to a single function
      // this will stop coins being spent on new addresses until after 
      // we know if they took part in the crowdsale by checking if they spent ether
      if (LockedCrowdSale(target))
      {
         if (block.timestamp>FINAL_AML_DATE)
         {
             RevokeTokens(target);
             return true;
         }
      }
      
      return false;
  }
  
  function ComputeVestSpend(address target) public returns (uint256)
  {
      require(mCanSpend[target]==2); // only compute for vestable accounts
      int256 vestingDays = int256(mVestingDays[target]);
      int256 vestingProgress = (int256(block.timestamp)-int256(mVestingBegins[target]))/(int256(DAYSECONDS));
      
      // cap the vesting
      if (vestingProgress>vestingDays)
      {
          vestingProgress=vestingDays;
      }
          
      // whole day vesting e.g. day 0 nothing vested, day 1 = 1 day vested    
      if (vestingProgress>0)
      {
              
        int256 allowedVest = ((int256(mVestingBalance[target])*vestingProgress))/vestingDays;
                  
        int256 combined = allowedVest-int256(mVestingSpent[target]);
        
        // store the combined value so people can see their vesting (useful for debug too)
        mVestingAllowed[target] = uint256(combined);
        
        return uint256(combined);
      }
      
      // no vesting allowed
      mVestingAllowed[target]=0;
      
      // cannot spend anything
      return 0;
  }
  
  // 0 locked 
  // 1 unlocked
  // 2 vestable
  function canSpend(address from, uint256 amount) internal returns (bool permitted)
  {
      uint256 currentTime = block.timestamp;
      
      // refunded / blocked
      if (mCanSpend[from]==8)
      {
          return false;
      }
      
      // revoked / blocked
      if (mCanSpend[from]==9)
      {
          return false;
      }
      
      // roll vesting / dates and AML in to a single function
      // this will stop coins being spent on new addresses until after 
      if (LockedCrowdSale(from))
      {
          return false;
      }
      
      if (mCanSpend[from]==1)
      {
          // tokens can only move when sale is finished
          if (currentTime>PRIME_VESTING_DATE)
          {
             return true;
          }
          return false;
      }
      
      // special vestable tokens
      if (mCanSpend[from]==2)
      {
              
        if (ComputeVestSpend(from)>=amount)
            {
              return true;
            }
            else
            {
              return false;   
            }
      }
      
      return false;
  }
  
   // 0 locked 
  // 1 unlocked
  // 2 vestable
  function canTake(address from) view public returns (bool permitted)
  {
      uint256 currentTime = block.timestamp;
      
      // refunded / blocked
      if (mCanSpend[from]==8)
      {
          return false;
      }
      
      // revoked / blocked
      if (mCanSpend[from]==9)
      {
          return false;
      }
      
      // roll vesting / dates and AML in to a single function
      // this will stop coins being spent on new addresses until after 
      if (LockedCrowdSale(from))
      {
          return false;
      }
      
      if (mCanSpend[from]==1)
      {
          // tokens can only move when sale is finished
          if (currentTime>PRIME_VESTING_DATE)
          {
             return true;
          }
          return false;
      }
      
      // special vestable tokens
      if (mCanSpend[from]==2)
      {
          return false;
      }
      
      return true;
  }
  

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool success) 
  {
       // check to see if we should revoke (and revoke if so)
      if (CheckRevoke(msg.sender)||CheckRevoke(_to))
      {
          return false;
      }
     
    require(canSpend(msg.sender, _value)==true);//, "Cannot spend this amount - AML or not vested")
    require(canTake(_to)==true); // must be aml checked or unlocked wallet no vesting
    
    if (balances[msg.sender] >= _value) 
    {
      // deduct the spend first (this is unlikely attack vector as only a few people will have vesting tokens)
      // special tracker for vestable funds - if have a date up
      if (mCanSpend[msg.sender]==2)
      {
        mVestingSpent[msg.sender] = mVestingSpent[msg.sender].add(_value);
      }
      
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      emit Transfer(msg.sender, _to, _value);
      
      
      // set can spend on destination as it will be transferred from approved wallet
      mCanSpend[_to]=1;
      
      return true;
    } 
    else
    {
      return false;
    }
  }
  
  // in the light of our sanity allow a utility to whole number of tokens and 1/10000 token transfer
  function simpletransfer(address _to, uint256 _whole, uint256 _fraction) public returns (bool success) 
  {
    require(_fraction<10000);//, "Fractional part must be less than 10000");
    
    uint256 main = _whole.mul(10**decimals); // works fine now i've removed the retarded divide by 0 assert in safemath
    uint256 part = _fraction.mul(10**14);
    uint256 value = main + part;
    
    // just call the transfer
    return transfer(_to, value);
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 returnbalance) 
  {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic 
{
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken 
{
  // need to add
  // also need
  // invalidate - used to drop all unauthorised buyers, return their tokens to reserve
  // freespend - all transactions now allowed - this could be used to vest tokens?
  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
   function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) 
   {
      // check to see if we should revoke (and revoke if so)
      if (CheckRevoke(msg.sender)||CheckRevoke(_to))
      {
          return false;
      }
      
      require(canSpend(_from, _value)== true);//, "Cannot spend this amount - AML or not vested")
      require(canTake(_to)==true); // must be aml checked or unlocked wallet no vesting
     
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) 
    {
      balances[_to] = balances[_to].add(_value);
      balances[_from] = balances[_from].sub(_value);
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
      emit Transfer(_from, _to, _value);
      
      
      // set can spend on destination as it will be transferred from approved wallet
      mCanSpend[_to]=1;
      
      // special tracker for vestable funds - if have a date set
      if (mCanSpend[msg.sender]==2)
      {
        mVestingSpent[msg.sender] = mVestingSpent[msg.sender].add(_value);
      }
      return true;
    } 
    else 
    {
     //   endsigning();
      return false;
    }
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
  function approve(address _spender, uint256 _value) public returns (bool)
  {
      // check to see if we should revoke (and revoke if so)
      if (CheckRevoke(msg.sender))
      {
          return false;
      }
      
      require(canSpend(msg.sender, _value)==true);//, "Cannot spend this amount - AML or not vested");
      
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining)
  {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) 
  {
      // check to see if we should revoke (and revoke if so)
      if (CheckRevoke(msg.sender))
      {
          return false;
      }
      require(canSpend(msg.sender, _addedValue)==true);//, "Cannot spend this amount - AML or not vested");
      
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success)
  {
      // check to see if we should revoke (and revoke if so)
      if (CheckRevoke(msg.sender))
      {
          return false;
      }
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


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of 'user permissions'.
 */
contract Ownable
{
  address public owner;
  address internal auxOwner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public
  {
      
        address newOwner = msg.sender;
        owner = 0;
        owner = newOwner;
    
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() 
  {
    require(msg.sender == owner || msg.sender==auxOwner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public 
  {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable
{
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;
  uint256 internal mCanPurchase = 1;
  uint256 internal mSetupReserve = 0;
  uint256 internal mSetupCrowd = 0;
  
  //test
  uint256 public constant MINIMUM_ETHER_SPEND = (250 * 10**(decimals-3));
  uint256 public constant MAXIMUM_ETHER_SPEND = 300 * 10**decimals;

  //real
  //uint256 public constant MINIMUM_ETHER_SPEND = (250 * 10**(decimals-3));
  //uint256 public constant MAXIMUM_ETHER_SPEND = 300 * 10**decimals;


  modifier canMint() 
  {
    require(!mintingFinished);
    _;
  }
  
  function allocateVestable(address target, uint256 amount, uint256 vestdays, uint256 vestingdate) public onlyOwner
  {
      //require(msg.sender==CONTRACT_CREATOR, "You are not authorised to create vestable token users");
      // check if we have permission to get in here
      //checksigning();
      
      // prevent anyone except contract signatories from creating their own vestable
      
      // essentially set up a final vesting date
      uint256 vestingAmount = amount * 10**decimals;
    
      // set up the vesting params
      mCanSpend[target]=2;
      mVestingBalance[target] = vestingAmount;
      mVestingDays[target] = vestdays;
      mVestingBegins[target] = vestingdate;
      mVestingSpent[target] = 0;
      
      // load the balance of the actual token fund
      balances[target] = vestingAmount;
      
      // if the tokensale is finalised then use the crowdsale fund which SHOULD be empty.
      // this means we can create new vesting tokens if necessary but only if crowdsale fund has been preload with MEW using multisig wallet
      if (mCanPurchase==0)
      {
        require(vestingAmount <= balances[MEW_CROWDSALE_FUND]);//, "Not enough MEW to allocate vesting post crowdsale");
        balances[MEW_CROWDSALE_FUND] = balances[MEW_CROWDSALE_FUND].sub(vestingAmount); 
        // log transfer
        emit Transfer(MEW_CROWDSALE_FUND, target, vestingAmount);
      }
      else
      {
        // deduct tokens from reserve before crowdsale
        require(vestingAmount <= balances[MEW_RESERVE_FUND]);//, "Not enough MEW to allocate vesting during setup");
        balances[MEW_RESERVE_FUND] = balances[MEW_RESERVE_FUND].sub(vestingAmount);
        // log transfer
        emit Transfer(MEW_RESERVE_FUND, target, vestingAmount);
      }
  }
  
  function SetAuxOwner(address aux) onlyOwner public
  {
      require(auxOwner == 0);//, "Cannot replace aux owner once it has been set");
      // sets the auxilliary owner as the contract owns this address not the creator
      auxOwner = aux;
  }
 
  function Purchase(address _to, uint256 _ether, uint256 _amount, uint256 exchange) onlyOwner public returns (bool) 
  {
    require(mCanSpend[_to]==0); // cannot purchase to a validated or vesting wallet (probably works but more debug checks)
    require(mSetupCrowd==1);//, "Only purchase during crowdsale");
    require(mCanPurchase==1);//,"Can only purchase during a sale");
      
    require( _amount >= MINIMUM_ETHER_SPEND * exchange);//, "Must spend at least minimum ether");
    require( (_amount+balances[_to]) <= MAXIMUM_ETHER_SPEND * exchange);//, "Must not spend more than maximum ether");
   
    // bail if we're out of tokens (will be amazing if this happens but hey!)
    if (balances[MEW_CROWDSALE_FUND]<_amount)
    {
         return false;
    }

    // lock the tokens for AML - early to prevent transact hack
    mCanSpend[_to] = 0;
    
    // add these ether to the invalid count unless checked
    if (mCanSpend[_to]==0)
    {
        mEtherInvalid = mEtherInvalid + int256(_ether);
    }
    else
    {
        // valid AML checked ether
        mEtherValid = mEtherValid + int256(_ether);
    }
    
    // store how much ether was spent
    mEtherSpent[_to] = _ether;
      
    // broken up to prevent recursive spend hacks (safemath probably does but just in case)
    uint256 newBalance = balances[_to].add(_amount);
    uint256 newCrowdBalance = balances[MEW_CROWDSALE_FUND].sub(_amount);
    
    balances[_to]=0;
    balances[MEW_CROWDSALE_FUND] = 0;
      
    // add in to personal fund
    balances[_to] = newBalance;
    balances[MEW_CROWDSALE_FUND] = newCrowdBalance;
   
    emit Transfer(MEW_CROWDSALE_FUND, _to, _amount);
    
    return true;
  }
  
  function Unlock_Tokens(address target) public onlyOwner
  {
      
      require(mCanSpend[target]==0);//,"Unlocking would fail");
      
      // unlocks locked tokens - must be called on every token wallet after AML check
      //unlocktokens(target);
      
      mCanSpend[target]=1;
      
      
    // get how much ether this person spent on their tokens
    uint256 etherToken = mEtherSpent[target];
    
    // if this is called the ether are now valid and can be spent
    mEtherInvalid = mEtherInvalid - int256(etherToken);
    mEtherValid = mEtherValid + int256(etherToken);
    
  }
  
  
  function Revoke(address target) public onlyOwner
  {
      // revokes tokens and returns to the reserve
      // designed to be used for refunds or to try to reverse theft via phishing etc
      RevokeTokens(target);
  }
  
  function BlockRefunded(address target) public onlyOwner
  {
      require(mCanSpend[target]!=8);
      // clear the spent ether
      //mEtherSpent[target]=0;
      
      // refund marker
      mCanSpend[target]=8;
      
      // does not refund just blocks account from being used for tokens ever again
      mEtherInvalid = mEtherInvalid-int256(mEtherSpent[target]);
  }
  
  function SetupReserve(address multiSig) public onlyOwner
  {
      require(mSetupReserve==0);//, "Reserve has already been initialised");
      require(multiSig>0);//, "Wallet is not valid");
      
      // address the mew reserve fund as the multisig wallet
      //MEW_RESERVE_FUND = multiSig;
      
      // create the reserve
      mint(MEW_RESERVE_FUND, TOTAL_RESERVE_FUND);
     
       // vesting allocates from the reserve fund
      allocateVestable(FOUNDER_ADDRESS1, 9000000000, 365, PRIME_VESTING_DATE);
      allocateVestable(FOUNDER_ADDRESS2, 9000000000, 365, PRIME_VESTING_DATE);
      allocateVestable(FOUNDER_ADDRESS3, 7000000000, 365, PRIME_VESTING_DATE);
  }
  
  function SetupCrowdSale() public onlyOwner
  {
      require(mSetupCrowd==0);//, "Crowdsale has already been initalised");
      // create the reserve
      mint(MEW_CROWDSALE_FUND, TOTAL_CROWDSALE_FUND);
      
      // crowd initialised
      mSetupCrowd=1;
  }
  
  function CloseSaleFund() public onlyOwner
  {
      uint256 remainingFund;
      
      remainingFund = balances[MEW_CROWDSALE_FUND];
      
      balances[MEW_CROWDSALE_FUND] = 0;
      
      balances[MEW_RESERVE_FUND] = balances[MEW_RESERVE_FUND].add(remainingFund);
      
      // notify the network
      emit Transfer(MEW_CROWDSALE_FUND, MEW_RESERVE_FUND, remainingFund);
      
      // set up the prime vesting date - ie immediate
      // set up the aml date
      PRIME_VESTING_DATE = block.timestamp;
      FINAL_AML_DATE = PRIME_VESTING_DATE + FINAL_AML_DAYS*DAYSECONDS;
      
      // update vesting date (sale end)
      mVestingBegins[FOUNDER_ADDRESS1]=PRIME_VESTING_DATE;
      mVestingBegins[FOUNDER_ADDRESS2]=PRIME_VESTING_DATE;
      mVestingBegins[FOUNDER_ADDRESS3]=PRIME_VESTING_DATE;
      
      // block further token purchasing (forever)
      mCanPurchase = 0;
  }
  
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) 
  {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    
    // allow this minted money to be spent immediately
    mCanSpend[_to] = 1;
    
    emit Mint(_to, _amount);
    emit Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) 
  {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}


contract MEWcoin is MintableToken 
{
    string public constant name = "MEWcoin (Official vFloorplan Ltd 30/07/18)";
    string public constant symbol = "MEW";
    string public version = "1.0";
}


contract Crowdsale 
{
    function buyTokens(address _recipient) public payable;
}

contract MultiSig
{
    function () public payable 
    {
       
    }
}

// i get the abstraction of crowdsale vs token but tbh I'd rather have most of this rolled up in a single contract
// kind of makes sense that one function of a token is a crowdsale too but hey
// - guess it could make the transactions lighter but then so does inheritance in the token... 
// tbd whether to do it or not.
contract MEWCrowdsale is Crowdsale 
{
    using SafeMath for uint256;

    // metadata
    uint256 public constant decimals = 18;
    uint256 public constant tenthousandths = 14;
    
    // crowdsale parameters
    //bool public isFinalized;  // switched to true in operational state
    
    // stages of the sale - will not go backwards
    uint8 internal constant STATE_UNINITIALISED       = 0xff;
    uint8 internal constant STATE_FUND_INITIALISED    = 0;
    uint8 internal constant STATE_PRESALE             = 1;
    uint8 internal constant STATE_PHASEFIRST          = 2;
    uint8 internal constant STATE_PHASESECOND         = 3;
    uint8 internal constant STATE_PHASEFINAL          = 4;
    uint8 internal constant STATE_EXTENSION           = 5;
    uint8 internal constant STATE_SALE_PAUSE          = 99;
    uint8 internal constant STATE_FINISHED            = 10;
    
    // initial state of state machine*/
    uint8 public mCURRENT_STATE = STATE_UNINITIALISED;
    
    uint256 public mFUNDING_SALE_TIMESTAMP = 0;                                          // initialised to zero
    uint256 public mFUNDING_CURRENT_DURATION = 0;                                        // used to change sale type
    uint256 public mFUNDING_BONUS = 0;
    
    uint256 private constant CONST_DAY_SECONDS=60*60*24;
    
    uint256[6] public FUNDING_SALE_DURATION = [0,42,14,14,28,7];  // length of time of each stage in days
    uint256[6] public FUNDING_SALE_BONUS = [0,150,125,110,100,100]; // in percent - exchange rate is divided by 100 to cancel it out
    
    uint256 private mTOKEN_EXCHANGE_RATE = 0;                                    // 0 before sale, after start we expect 500,000 MEW tokens per 1 ETH 
    uint256 public constant TOTAL_RESERVE_FUND = 40 * 1000000000 * 10**decimals; // 40B total in reserve/founder
    uint256 public constant TOTAL_TOKEN_SUPPLY = 100 * (10**9) * 10**decimals;   // 100B total in the crowdsale
    uint256 public constant GAS_PRICE_LIMIT = 200 * 10**9;                       // Gas limit 200 gwei
    
    // paused state
    uint256 public mPausedTime = 0;
    
    address internal mOwner = 0;
    
    // wallet deposits and changing/signing code
    uint256 internal constant SIGNING_TIME=900;
    uint256[2] internal signatures;
    address internal newAddress;
    address public mDepositWallet;

    // events
    event CreateMEW(address indexed _to, uint256 _value);

    MEWcoin public mToken; // expose the public ERC20 contract address
    MultiSig public mMultiSigWallet; // expose the public multisig wallet address

    // constructor
    constructor() public 
    {
        require(mCURRENT_STATE == STATE_UNINITIALISED);//, "State machine is not in uninitialised state");
        // check we're the owner when calling the crowdsale (wouldn't really matter as eth goes in to our fund but would look weird having multiple crowdsales!)
        if (mOwner!=0)
        {
            require (msg.sender == mOwner);//, "Cannot create a crowdsale unless you own the contract");
        }
        
      // create the token
      mToken = new MEWcoin();
      mMultiSigWallet = MultiSig(mToken.MEW_RESERVE_FUND());
      mDepositWallet = address(mMultiSigWallet);

      // sanity checks
      require(mOwner == 0);//, "Already seems to be an owner");
      require(address(mToken.MEW_RESERVE_FUND) != 0x0);//, "Invalid address for mew deposit");
      require(uint256(mToken.decimals()) == decimals);//, "Mismatch between token and mew contract decimals");
      
      // set up the sender as the owner
      mOwner = msg.sender;
      
      // set the aux owner of the token - otherwise the contract owns it and we can't access owner functions
      mToken.SetAuxOwner(mOwner);
      
      // create the reserve and allocate found tokens
      mToken.SetupReserve(mMultiSigWallet);
      mToken.SetupCrowdSale();
      emit CreateMEW(address(mToken.MEW_RESERVE_FUND), mToken.TOTAL_RESERVE_FUND());
      emit CreateMEW(address(mToken.MEW_CROWDSALE_FUND), mToken.TOTAL_CROWDSALE_FUND());
      
      // state machine has been initialised
      mCURRENT_STATE = STATE_FUND_INITIALISED;
      
      // no more tokens
      mToken.finishMinting();
      
    }

    // utility
    function startPRESALE() public 
    {
        require (msg.sender == mOwner);//, "Cannot call startPRESALE unless you own the contract");
        require (mCURRENT_STATE == STATE_FUND_INITIALISED); // can only be called initially
        incSALESTATE();
        
        // deprecated
        //require (mCURRENT_STATE==STATE_FUND_INITIALISED, "Incorrect state to begin presale");
        
        // set the sale params
        //mCURRENT_STATE=STATE_PRESALE;
        //mFUNDING_SALE_TIMESTAMP = block.timestamp;
        //mFUNDING_CURRENT_DURATION = block.timestamp + FUNDING_SALE_DURATION[mCURRENT_STATE]*CONST_DAY_SECONDS;
        
        //mFUNDING_BONUS = FUNDING_SALE_BONUS[STATE_PRESALE];
        //mTOKEN_EXCHANGE_RATE = 5000*mFUNDING_BONUS;                                          // set the rate as the sale begins - this will be multiplied up by bonus
    }
    
    function incSALESTATE() public
    {
        require (msg.sender == mOwner);//, "Cannot call incSALESTATE unless you own the contract");
        require (mCURRENT_STATE!=STATE_FINISHED);//, "Cannot call on finalised sale"); 
        require (mCURRENT_STATE!=STATE_EXTENSION);//, "Cannot call on finalised sale");  // emergency sale extention if required
        
        // increment state 
        if (mCURRENT_STATE >= STATE_FUND_INITIALISED)
        {
            // move to next sale state
            mCURRENT_STATE++;
            // set up the bonus
            mFUNDING_BONUS = FUNDING_SALE_BONUS[mCURRENT_STATE];
            
            // set the start and end of sale (timestamp + duration)
            mFUNDING_SALE_TIMESTAMP = block.timestamp;
            mFUNDING_CURRENT_DURATION = block.timestamp + FUNDING_SALE_DURATION[mCURRENT_STATE]*CONST_DAY_SECONDS;
            
            // add the token <> eth exchange rate
            mTOKEN_EXCHANGE_RATE = 5000*mFUNDING_BONUS;
        }
    }
    
    // utility
    function pauseSALE() public 
    {
        require (msg.sender == mOwner);//, "Cannot call pauseSALE unless you own the contract");
        require (mPausedTime == 0);//, "Cannot pause a paused sale");
        mPausedTime = mFUNDING_CURRENT_DURATION.sub(block.timestamp);
        mFUNDING_CURRENT_DURATION = 0;
    }
    
    function unpauseSALE() public
    {
        require (mPausedTime !=0);//, "Cannot unpause a sale which isn't paused");
        require (msg.sender == mOwner);//, "Cannot call unpauseSALE unless you own the contract");
        mFUNDING_CURRENT_DURATION = block.timestamp.add(mPausedTime);
        mPausedTime=0;
    }
    
    function () public payable 
    {
      require( mCURRENT_STATE>=STATE_PRESALE);//, "Trying to buy tokens but sale has not yet started");
      buyTokens(msg.sender);
     
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable
    {
        // a lot of stuff wouldn't work without optimisation on - out of gas - someone fix remix please   
          require (mCURRENT_STATE>=STATE_PRESALE);//, "STATE: Sale has not been started");
          //require (mCURRENT_STATE!=STATE_SALE_PAUSE, "STATE: Sale is paused");
          require (block.timestamp >= mFUNDING_SALE_TIMESTAMP);//, "STATE: Timestamp has not been initialised, did you start the sale?");
          require (block.timestamp <= mFUNDING_CURRENT_DURATION);
          
          require (beneficiary != 0x0);// "No beneficiary address given with message"
          require (tx.gasprice <= GAS_PRICE_LIMIT);// "tx.gas price exceeds limit"
    
          uint256 tokens = msg.value.mul(mTOKEN_EXCHANGE_RATE);
          
          // take the eth and hand back tokens
          forwardFunds();
          
          // assign the tokens from the crowdsale fund
          require(mToken.Purchase(beneficiary, msg.value, tokens, mTOKEN_EXCHANGE_RATE) == true);//, "Token purchase failed - is the crowdsale fund empty?!?");
    }

    function finalize() public 
    {
      require (msg.sender == mOwner);//, "Calling finalize but not the owner");
      require (mCURRENT_STATE!=STATE_FINISHED);
      
      // force finalise
      mCURRENT_STATE = STATE_FINISHED;
      
      mToken.CloseSaleFund();
    }
    
    function changeWallet(address newWallet) public
    {
        address SIGN_ADDRESS1 = address(0xa5a5f62BfA22b1E42A98Ce00131eA658D5E29B37);
        address SIGN_ADDRESS2 = address(0x9115a6162D6bC3663dC7f4Ea46ad87db6B9CB926);
        
        require (msg.sender == SIGN_ADDRESS1 || msg.sender == SIGN_ADDRESS2);//, "Must be founders signing this - can't sign anyway but this will bomb");
        
        // store the current block time
        uint256 blocktime = block.timestamp;
        
        // sign with the current founder signature
        if (msg.sender == SIGN_ADDRESS1)
        {
            signatures[0] = blocktime;
        }
        
        if (msg.sender == SIGN_ADDRESS2)
        {
            signatures[1] = blocktime;
            
        }
        
        // if we're the first person with the address then set it and bail
        if (newAddress==0)
        {
            newAddress = newWallet;
            return;
        }
        
        uint256 time1=blocktime - signatures[0];
        uint256 time2=blocktime - signatures[1];
        
        // check both times are within signing time
        if ((time1<SIGNING_TIME) && (time2<SIGNING_TIME))
        {
            require(newAddress==newWallet);//,"Addresses do no match");
            {
                // set new wallet and clear signatures
                mDepositWallet = newWallet;
                signatures[0]=0;
                signatures[1]=0;
                newAddress=0;
            }
        }
    }

    // send ether to the fund collection wallet
    function forwardFunds() internal
    {
        require(mDepositWallet!=0);//,"Wallet is unset");
        
        mDepositWallet.transfer(msg.value);
    }
}