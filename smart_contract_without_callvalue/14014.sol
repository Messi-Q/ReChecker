pragma solidity ^0.4.23;


 
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   
  constructor() public {
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

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

 
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

contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

contract BasicMultiToken is StandardToken, DetailedERC20 {
    
    ERC20[] public tokens;

    event Mint(address indexed minter, uint256 value);
    event Burn(address indexed burner, uint256 value);
    
    constructor(ERC20[] _tokens, string _name, string _symbol, uint8 _decimals) public
        DetailedERC20(_name, _symbol, _decimals)
    {
        require(_tokens.length >= 2, "Contract do not support less than 2 inner tokens");
        tokens = _tokens;
    }

    function mint(address _to, uint256 _amount) public {
        require(totalSupply_ != 0, "This method can be used with non zero total supply only");
        uint256[] memory tokenAmounts = new uint256[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            tokenAmounts[i] = _amount.mul(tokens[i].balanceOf(this)).div(totalSupply_);
        }
        _mint(_to, _amount, tokenAmounts);
    }

    function mintFirstTokens(address _to, uint256 _amount, uint256[] _tokenAmounts) public {
        require(totalSupply_ == 0, "This method can be used with zero total supply only");
        _mint(_to, _amount, _tokenAmounts);
    }

    function _mint(address _to, uint256 _amount, uint256[] _tokenAmounts) internal {
        require(tokens.length == _tokenAmounts.length, "Lenghts of tokens and _tokenAmounts array should be equal");
        for (uint i = 0; i < tokens.length; i++) {
            tokens[i].transferFrom(msg.sender, this, _tokenAmounts[i]);
        }

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
    }

    function burn(uint256 _value) public {
        burnSome(_value, tokens);
    }

    function burnSome(uint256 _value, ERC20[] someTokens) public {
        require(_value <= balances[msg.sender]);

        for (uint i = 0; i < someTokens.length; i++) {
            uint256 tokenAmount = _value.mul(someTokens[i].balanceOf(this)).div(totalSupply_);
            someTokens[i].transfer(msg.sender, tokenAmount);
        }
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
    }

}


interface ERC228 {
    function changeableTokenCount() external view returns (uint16 count);
    function changeableToken(uint16 _tokenIndex) external view returns (address tokenAddress);
    function getReturn(address _fromToken, address _toToken, uint256 _amount) external view returns (uint256 amount);
    function change(address _fromToken, address _toToken, uint256 _amount, uint256 _minReturn) external returns (uint256 amount);

    event Update();
    event Change(address indexed _fromToken, address indexed _toToken, address indexed _changer, uint256 _amount, uint256 _return);
}


contract MultiToken is BasicMultiToken, ERC228 {

    mapping(address => uint256) public weights;
    
    constructor(ERC20[] _tokens, uint256[] _weights, string _name, string _symbol, uint8 _decimals) public
        BasicMultiToken(_tokens, _name, _symbol, _decimals)
    {
        _setWeights(_weights);
    }

    function _setWeights(uint256[] _weights) internal {
        require(_weights.length == tokens.length, "Lenghts of _tokens and _weights array should be equal");
        for (uint i = 0; i < tokens.length; i++) {
            require(_weights[i] != 0, "The _weights array should not contains zeros");
            weights[tokens[i]] = _weights[i];
        }
    }

    function changeableTokenCount() public view returns (uint16 count) {
        count = uint16(tokens.length);
    }

    function changeableToken(uint16 _tokenIndex) public view returns (address tokenAddress) {
        tokenAddress = tokens[_tokenIndex];
    }

    function getReturn(address _fromToken, address _toToken, uint256 _amount) public view returns(uint256 returnAmount) {
        uint256 fromBalance = ERC20(_fromToken).balanceOf(this);
        uint256 toBalance = ERC20(_toToken).balanceOf(this);
        returnAmount = toBalance.mul(_amount).mul(weights[_toToken]).div(weights[_fromToken]).div(fromBalance.add(_amount));
    }

    function change(address _fromToken, address _toToken, uint256 _amount, uint256 _minReturn) public returns(uint256 returnAmount) {
        returnAmount = getReturn(_fromToken, _toToken, _amount);
        require(returnAmount >= _minReturn, "The return amount is less than _minReturn value");
        ERC20(_fromToken).transferFrom(msg.sender, this, _amount);
        ERC20(_toToken).transfer(msg.sender, returnAmount);
        emit Change(_fromToken, _toToken, msg.sender, _amount, returnAmount);
    }

}

contract ManageableMultiToken is Ownable, MultiToken {

    constructor(ERC20[] _tokens, uint256[] _weights, string _name, string _symbol, uint8 _decimals) public 
        MultiToken(_tokens, _weights, _name, _symbol, _decimals)
    {
    }

    function setWeights(uint256[] _weights) public onlyOwner {
        _setWeights(_weights);
    }

}