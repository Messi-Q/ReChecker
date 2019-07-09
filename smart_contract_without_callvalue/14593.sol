pragma solidity ^0.4.13;

contract Crowdsale {
  using SafeMath for uint256;

   
  ERC20 public token;

   
  address public wallet;

   
  uint256 public rate;

   
  uint256 public weiRaised;

   
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

   
  function Crowdsale(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

   
   
   

   
  function () external payable {
    buyTokens(msg.sender);
  }

   
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

     
    uint256 tokens = _getTokenAmount(weiAmount);

     
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

   
   
   

   
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

   
  function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
     
  }

   
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.transfer(_beneficiary, _tokenAmount);
  }

   
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

   
  function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
     
  }

   
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(rate);
  }

   
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

contract AllowanceCrowdsale is Crowdsale {
  using SafeMath for uint256;

  address public tokenWallet;

   
  function AllowanceCrowdsale(address _tokenWallet) public {
    require(_tokenWallet != address(0));
    tokenWallet = _tokenWallet;
  }

   
  function remainingTokens() public view returns (uint256) {
    return token.allowance(tokenWallet, this);
  }

   
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.transferFrom(tokenWallet, _beneficiary, _tokenAmount);
  }
}

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

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TVCrowdsale is AllowanceCrowdsale, Ownable {
  uint256 public currentRate;
  
  function TVCrowdsale(uint256 _rate, address _wallet, ERC20 _token, address _tokenWallet)
    Crowdsale(_rate, _wallet, _token)
    AllowanceCrowdsale(_tokenWallet) public {
    currentRate = _rate;
  }
  
  function setRate(uint256 _rate) public onlyOwner returns (bool) {
    currentRate = _rate;
    return true;
  }
  
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(currentRate);
  }

}