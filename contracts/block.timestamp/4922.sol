pragma solidity ^0.4.23;

library SafeMath {
    
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
  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

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
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
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
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract Eurufly is StandardToken, Ownable{
    string  public  constant name = "Eurufly";
    string  public  constant symbol = "EUR";
    uint8   public  constant decimals = 18;
    uint256 public priceOfToken = 2500; // 1 ether = 2500 EUR
  uint256 public icoStartAt ;
  uint256 public icoEndAt ;
  uint256 public preIcoStartAt ;
  uint256 public preIcoEndAt ;
  uint256 public prePreIcoStartAt;
  uint256 public prePreIcoEndAt;
  STATE public state = STATE.UNKNOWN;
  address wallet ; // Where all ether is transfered
  // Amount of wei raised
  uint256 public weiRaised;
  address public owner ;
  enum STATE{UNKNOWN, PREPREICO, PREICO, POSTICO}

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  
  function transfer(address _to, uint _value)  public returns (bool success) {
    // Call StandardToken.transfer()
   return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value)  public returns (bool success) {
    // Call StandardToken.transferForm()
    return super.transferFrom(_from, _to, _value);
  }

    // Start Pre Pre ICO
    function startPrePreIco(uint256 x) public onlyOwner{
        require(state == STATE.UNKNOWN);
        prePreIcoStartAt = block.timestamp ;
        prePreIcoEndAt = block.timestamp + x * 1 days ; // pre pre
        state = STATE.PREPREICO;
        
    }
    
    // Start Pre ICO
    function startPreIco(uint256 x) public onlyOwner{
        require(state == STATE.PREPREICO);
        preIcoStartAt = block.timestamp ;
        preIcoEndAt = block.timestamp + x * 1 days ; // pre 
        state = STATE.PREICO;
        
    }
    
    // Start POSTICO
    function startPostIco(uint256 x) public onlyOwner{
         require(state == STATE.PREICO);
         icoStartAt = block.timestamp ;
         icoEndAt = block.timestamp + x * 1 days;
         state = STATE.POSTICO;
          
     }
    
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(priceOfToken);
  }

 
  function _forwardFunds() internal {
     wallet.transfer(msg.value);
  }
  
  function () external payable {
    require(totalSupply_<= 10 ** 26);
    require(state != STATE.UNKNOWN);
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {
    
     require(_beneficiary != address(0x0));
     if(state == STATE.PREPREICO){
        require(now >= prePreIcoStartAt && now <= prePreIcoEndAt);
        require(msg.value <= 10 ether);
      }else if(state == STATE.PREICO){
       require(now >= preIcoStartAt && now <= preIcoEndAt);
       require(msg.value <= 15 ether);
      }else if(state == STATE.POSTICO){
        require(now >= icoStartAt && now <= icoEndAt);
        require(msg.value <= 20 ether);
      }
      
      uint256 weiAmount = msg.value;
      uint256 tokens = _getTokenAmount(weiAmount);
      
      if(state == STATE.PREPREICO){                 // bonuses
         tokens = tokens.add(tokens.mul(30).div(100));
      }else if(state == STATE.PREICO){
        tokens = tokens.add(tokens.mul(25).div(100));
      }else if(state == STATE.POSTICO){
        tokens = tokens.add(tokens.mul(20).div(100));
      }
     totalSupply_ = totalSupply_.add(tokens);
     balances[msg.sender] = balances[msg.sender].add(tokens);
     emit Transfer(address(0), msg.sender, tokens);
    // update state
     weiRaised = weiRaised.add(weiAmount);
     emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
     _forwardFunds();
   }
    
    constructor(address ethWallet) public{
        wallet = ethWallet;
        owner = msg.sender;
    }
    
    function emergencyERC20Drain(ERC20 token, uint amount) public onlyOwner {
        // owner can drain tokens that are sent here by mistake
        token.transfer( owner, amount );
    }
    
    function allocate(address user, uint256 amount) public onlyOwner{
       
        require(totalSupply_.add(amount) <= 10 ** 26 );
        uint256 tokens = amount * (10 ** 18);
        totalSupply_ = totalSupply_.add(tokens);
        balances[user] = balances[user].add(tokens);
        emit Transfer(address(0), user , tokens);
   
    }
}