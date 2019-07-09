pragma solidity ^0.4.24;



 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
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


 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

   
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
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

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
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


contract EscobarcoinToken is StandardToken {
    using SafeMath for uint256;

    string public name = "EscobarcoinToken";
    string public symbol = "ESCO";
    uint256 public decimals = 18;

    uint256 public totalSupply = 250000000 * (uint256(10) ** decimals);
     
    uint256 public totalRaised;  

    uint256 public startTimestamp;  
    uint256 public durationSeconds = 4 * 7 * 24 * 60 * 60;  

    uint256 public minCap;  
    uint256 public maxCap;  

     
    address public fundsWallet;

    function EscobarcoinToken() {
        fundsWallet = 0x1EC478936a49278c8754021927a2ab0018594D40;
        startTimestamp = 1526817600;
        minCap = 1667 * (uint256(10) ** decimals);
        maxCap = 16667 * (uint256(10) ** decimals);

         
        balances[fundsWallet] = totalSupply;
        Transfer(0x0, fundsWallet, totalSupply);
    }

    function() isIcoOpen payable {
        totalRaised = totalRaised.add(msg.value);

        uint256 tokenAmount = calculateTokenAmount(msg.value);
        balances[fundsWallet] = balances[fundsWallet].sub(tokenAmount);
        balances[msg.sender] = balances[msg.sender].add(tokenAmount);
        Transfer(fundsWallet, msg.sender, tokenAmount);

         
        fundsWallet.transfer(msg.value);
    }

    function calculateTokenAmount(uint256 weiAmount) constant returns(uint256) {
         
        uint256 tokenAmount = weiAmount.mul(9000);
        
        if (now <= startTimestamp + 7 days) {
             
            return tokenAmount.mul(150).div(100);
        } else if (now <= startTimestamp + 14 days) {
             
            return tokenAmount.mul(120).div(100);
        } else if (now <= startTimestamp + 21 days) {
             
            return tokenAmount.mul(115).div(100);
        } else if (now <= startTimestamp + 28 days) {
             
            return tokenAmount.mul(110).div(100);
        } else {
             
            return tokenAmount.mul(110).div(100);
        }
    }

    function transfer(address _to, uint _value) isIcoFinished returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) isIcoFinished returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    modifier isIcoOpen() {
        require(now >= startTimestamp);
        require(now <= (startTimestamp + durationSeconds) || totalRaised < minCap);
        require(totalRaised <= maxCap);
        _;
    }

    modifier isIcoFinished() {
        require(now >= startTimestamp);
        require(totalRaised >= maxCap || (now >= (startTimestamp + durationSeconds) && totalRaised >= minCap));
        _;
    }
}