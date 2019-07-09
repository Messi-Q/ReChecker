pragma solidity ^0.4.23;


 
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

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


   
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

   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

   
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

   
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

 
contract FIN is StandardToken {
  string public constant name = "Financial Incentive Network Points";
  string public constant symbol = "FIN";
  uint8 public constant decimals = 18;  

  uint256 private constant OFFSET = 10 ** uint256(decimals);
  uint256 private constant BILLION = (10 ** 9) * OFFSET;  
  
  uint256 private TOTAL_SUPPLY;

  constructor(address _holderA, address _holderB, address _holderC) public {
    balances[_holderA] = BILLION;
    emit Transfer(0x0, _holderA, BILLION);

    balances[_holderB] = BILLION;
    emit Transfer(0x0, _holderB, BILLION);

    balances[_holderC] = BILLION / 2;
    emit Transfer(0x0, _holderC, BILLION / 2);
    
    TOTAL_SUPPLY = balances[_holderA] + balances[_holderB] + balances[_holderC];
  }
  
  function totalSupply() public view returns (uint256) {
      return TOTAL_SUPPLY;
  }
}


interface TokenValidator {
  function check(
    address _token,
    address _user
  ) external returns(byte result);

  function check(
    address _token,
    address _from,
    address _to,
    uint256 _amount
  ) external returns (byte result);
}


interface ValidatedToken {
  event Validation(
    byte    indexed result,
    address indexed user
  );

  event Validation(
    byte    indexed result,
    address indexed from,
    address indexed to,
    uint256         value
  );
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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract ReferenceToken is Ownable, ERC20, ValidatedToken {
    using SafeMath for uint256;

    string internal mName;
    string internal mSymbol;

    uint256 internal mGranularity;
    uint256 internal mTotalSupply;

    mapping(address => uint) internal mBalances;
    mapping(address => mapping(address => bool)) internal mAuthorized;
    mapping(address => mapping(address => uint256)) internal mAllowed;

    uint8 public decimals = 18;

     
    TokenValidator internal validator;

    constructor(
        string         _name,
        string         _symbol,
        uint256        _granularity,
        TokenValidator _validator
    ) public {
        require(_granularity >= 1);

        mName = _name;
        mSymbol = _symbol;
        mTotalSupply = 0;
        mGranularity = _granularity;
        validator = TokenValidator(_validator);
    }

     

    function validate(address _user) internal returns (byte) {
        byte checkResult = validator.check(this, _user);
        emit Validation(checkResult, _user);
        return checkResult;
    }

    function validate(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (byte) {
        byte checkResult = validator.check(this, _from, _to, _amount);
        emit Validation(checkResult, _from, _to, _amount);
        return checkResult;
    }

     

    function isOk(byte _statusCode) internal pure returns (bool) {
        return (_statusCode & hex"0F") == 1;
    }

    function requireOk(byte _statusCode) internal pure {
        require(isOk(_statusCode));
    }

    function name() public constant returns (string) {
        return mName;
    }

    function symbol() public constant returns(string) {
        return mSymbol;
    }

    function granularity() public constant returns(uint256) {
        return mGranularity;
    }

    function totalSupply() public constant returns(uint256) {
        return mTotalSupply;
    }

    function balanceOf(address _tokenHolder) public constant returns (uint256) {
        return mBalances[_tokenHolder];
    }

    function isMultiple(uint256 _amount) internal view returns (bool) {
      return _amount.div(mGranularity).mul(mGranularity) == _amount;
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        if(validate(msg.sender, _spender, _amount) != 1) { return false; }

        mAllowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return mAllowed[_owner][_spender];
    }

    function mint(address _tokenHolder, uint256 _amount) public onlyOwner {
        requireOk(validate(_tokenHolder));
        require(isMultiple(_amount));

        mTotalSupply = mTotalSupply.add(_amount);
        mBalances[_tokenHolder] = mBalances[_tokenHolder].add(_amount);

        emit Transfer(0x0, _tokenHolder, _amount);
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        doSend(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        require(_amount <= mAllowed[_from][msg.sender]);

        mAllowed[_from][msg.sender] = mAllowed[_from][msg.sender].sub(_amount);
        doSend(_from, _to, _amount);
        return true;
    }

    function doSend(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        require(canTransfer(_from, _to, _amount));

        mBalances[_from] = mBalances[_from].sub(_amount);
        mBalances[_to] = mBalances[_to].add(_amount);

        emit Transfer(_from, _to, _amount);
    }

    function canTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        return (
            (_to != address(0))  
            && isMultiple(_amount)
            && (mBalances[_from] >= _amount)  
            && isOk(validate(_from, _to, _amount))  
        );
    }
}


contract Lunar is ReferenceToken {
    uint256 constant DECIMAL_SHIFT = 10 ** 18;
    
    constructor(TokenValidator _validator)
      ReferenceToken("Lunar Token - SAMPLE NO VALUE", "LNRX", 1, _validator)
      public {
          uint256 supply = 5000000 * DECIMAL_SHIFT;

          mTotalSupply = supply;
          mBalances[msg.sender] = supply;

          emit Transfer(0x0, msg.sender, supply);
      }
}


contract SimpleAuthorization is TokenValidator, Ownable {
    mapping(address => bool) private auths;

    constructor() public {}

    function check(
        address  ,
        address _address
    ) external returns (byte resultCode) {
        if (auths[_address]) {
            return hex"11";
        } else {
            return hex"10";
        }
    }

    function check(
        address  ,
        address _from,
        address _to,
        uint256  
    ) external returns (byte resultCode) {
        if (auths[_from] && auths[_to]) {
            return hex"11";
        } else {
            return hex"10";
        }
    }

    function setAuthorized(address _address, bool _status) public onlyOwner {
        auths[_address] = _status;
    }
}