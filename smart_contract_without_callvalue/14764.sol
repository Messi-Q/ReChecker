pragma solidity ^0.4.18;

 
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

   
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

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


 

contract IHF is StandardToken {
  using SafeMath for uint256;

  string public name = "Invictus Hyperion";
  string public symbol = "IHF";
  uint8 public decimals = 18;
  string public version = "1.0";

  uint256 public fundingEndBlock;

   
  address public vestingContract;
  bool private vestingSet = false;

  address public fundWallet1;
  address public fundWallet2;

  bool public tradeable = false;

   

  modifier isTradeable {  
      require(tradeable || msg.sender == fundWallet1 || msg.sender == vestingContract);
      _;
  }

  modifier onlyFundWallets {
      require(msg.sender == fundWallet1 || msg.sender == fundWallet2);
      _;
  }

   
  function IHF(address backupFundWallet, uint256 endBlockInput) public {
      require(backupFundWallet != address(0));
      require(block.number < endBlockInput);
      fundWallet1 = msg.sender;
      fundWallet2 = backupFundWallet;
      fundingEndBlock = endBlockInput;
  }

  function setVestingContract(address vestingContractInput) external onlyFundWallets {
      require(!vestingSet);  
      require(vestingContractInput != address(0));
      vestingContract = vestingContractInput;
      vestingSet = true;
  }

  function allocateTokens(address participant, uint256 amountTokens) private {
      require(vestingSet);
       
      uint256 developmentAllocation = amountTokens.mul(25641025641025641).div(1000000000000000000);
      uint256 newTokens = amountTokens.add(developmentAllocation);
       
      totalSupply_ = totalSupply_.add(newTokens);
      balances[participant] = balances[participant].add(amountTokens);
      balances[vestingContract] = balances[vestingContract].add(developmentAllocation);
      emit Transfer(address(0), participant, amountTokens);
      emit Transfer(address(0), vestingContract, developmentAllocation);
  }

  function batchAllocate(address[] participants, uint256[] values) external onlyFundWallets returns(uint256) {
      require(block.number < fundingEndBlock);
      uint256 i = 0;
      while (i < participants.length) {
        allocateTokens(participants[i], values[i]);
        i++;
      }
      return(i);
  }

   
  function adjustBalance(address participant) external onlyFundWallets {
      require(vestingSet);
      require(block.number < fundingEndBlock);
      uint256 amountTokens = balances[participant];
      uint256 developmentAllocation = amountTokens.mul(25641025641025641).div(1000000000000000000);
      uint256 removeTokens = amountTokens.add(developmentAllocation);
      totalSupply_ = totalSupply_.sub(removeTokens);
      balances[participant] = 0;
      balances[vestingContract] = balances[vestingContract].sub(developmentAllocation);
      emit Transfer(participant, address(0), amountTokens);
      emit Transfer(vestingContract, address(0), developmentAllocation);
  }

  function changeFundWallet1(address newFundWallet) external onlyFundWallets {
      require(newFundWallet != address(0));
      fundWallet1 = newFundWallet;
  }
  function changeFundWallet2(address newFundWallet) external onlyFundWallets {
      require(newFundWallet != address(0));
      fundWallet2 = newFundWallet;
  }

  function updateFundingEndBlock(uint256 newFundingEndBlock) external onlyFundWallets {
      require(block.number < fundingEndBlock);
      require(block.number < newFundingEndBlock);
      fundingEndBlock = newFundingEndBlock;
  }

  function enableTrading() external onlyFundWallets {
      require(block.number > fundingEndBlock);
      tradeable = true;
  }

  function() payable public {
      require(false);  
  }

  function claimTokens(address _token) external onlyFundWallets {
      require(_token != address(0));
      ERC20Basic token = ERC20Basic(_token);
      uint256 balance = token.balanceOf(this);
      token.transfer(fundWallet1, balance);
   }

   function removeEth() external onlyFundWallets {
      fundWallet1.transfer(address(this).balance);
    }

    function burn(uint256 _value) external onlyFundWallets {
      require(balances[msg.sender] >= _value);
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[0x0] = balances[0x0].add(_value);
      totalSupply_ = totalSupply_.sub(_value);
      emit Transfer(msg.sender, 0x0, _value);
    }

    
   function transfer(address _to, uint256 _value) isTradeable public returns (bool success) {
       return super.transfer(_to, _value);
   }
   function transferFrom(address _from, address _to, uint256 _value) isTradeable public returns (bool success) {
       return super.transferFrom(_from, _to, _value);
   }

}