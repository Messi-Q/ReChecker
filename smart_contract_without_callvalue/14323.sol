pragma solidity ^0.4.18;

contract Token {

     
    function totalSupply() constant returns (uint256 supply) {}

     
     
    function balanceOf(address _owner) constant returns (uint256 balance) {}

     
     
     
     
    function transfer(address _to, uint256 _value) returns (bool success) {}

     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

     
     
     
     
    function approve(address _spender, uint256 _value) returns (bool success) {}

     
     
     
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


 

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
         
         
         
         
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
         
         
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

 

contract HumanStandardToken is StandardToken {

    function () {
         
        throw;
    }

     

     
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H0.1';        

    function HumanStandardToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount;                
        totalSupply = _initialAmount;                         
        name = _tokenName;                                    
        decimals = _decimalUnits;                             
        symbol = _tokenSymbol;                                
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
         
         
         
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        
        return true;
    }

}

 
contract ERC20Basic {
  uint256 public totalSupply;
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

 
 
contract TokenSwap is Ownable {

     
    HumanStandardToken public ndc;
     
    HumanStandardToken public tpt;
     
    address public neverdieSigner;
     
    uint256 public minSwapAmount = 40;

    event Swap(
        address indexed to,
        address indexed PTaddress,
        uint256 rate,
        uint256 amount,
        uint256 ptAmount
    );

    event BuyNDC(
        address indexed to,
        uint256 NDCprice,
        uint256 value,
        uint256 amount
    );

    event BuyTPT(
        address indexed to,
        uint256 TPTprice,
        uint256 value,
        uint256 amount
    );

     
     
     
     
     
    function TokenSwap(address _teleportContractAddress, address _neverdieContractAddress, address _signer) public {
        tpt = HumanStandardToken(_teleportContractAddress);
        ndc = HumanStandardToken(_neverdieContractAddress);
        neverdieSigner = _signer;
    }

    function setTeleportContractAddress(address _to) external onlyOwner {
        tpt = HumanStandardToken(_to);
    }

    function setNeverdieContractAddress(address _to) external onlyOwner {
        ndc = HumanStandardToken(_to);
    }

    function setNeverdieSignerAddress(address _to) external onlyOwner {
        neverdieSigner = _to;
    }

    function setMinSwapAmount(uint256 _amount) external onlyOwner {
        minSwapAmount = _amount;
    }

     
     
     
     
     
    function receiveApproval(address _sender, uint256 _value, address _tokenContract, bytes _extraData) external {
        require(_tokenContract == address(ndc));
        assert(this.call(_extraData));
    }

    

     
     
     
     
     
     
     
     
     
     
    function swapFor(address _spender,
                     uint256 _rate,
                     address _PTaddress,
                     uint256 _amount,
                     uint256 _expiration,
                     uint8 _v,
                     bytes32 _r,
                     bytes32 _s) public {

         
        require(_expiration >= block.timestamp);

         
        address signer = ecrecover(keccak256(_spender, _rate, _PTaddress, _amount, _expiration), _v, _r, _s);
        require(signer == neverdieSigner);

         
        require(_amount >= minSwapAmount);
       
         
        HumanStandardToken ptoken = HumanStandardToken(_PTaddress);
        uint256 ptAmount;
        uint8 decimals = ptoken.decimals();
        if (decimals <= 18) {
          ptAmount = SafeMath.div(SafeMath.div(SafeMath.mul(_amount, _rate), 1000), 10**(uint256(18 - decimals)));
        } else {
          ptAmount = SafeMath.div(SafeMath.mul(SafeMath.mul(_amount, _rate), 10**(uint256(decimals - 18))), 1000);
        }

        assert(ndc.transferFrom(_spender, this, _amount) && ptoken.transfer(_spender, ptAmount));

         
        Swap(_spender, _PTaddress, _rate, _amount, ptAmount);
    }

     
     
     
     
     
     
     
     
    function swap(uint256 _rate,
                  address _PTaddress,
                  uint256 _amount,
                  uint256 _expiration,
                  uint8 _v,
                  bytes32 _r,
                  bytes32 _s) external {
        swapFor(msg.sender, _rate, _PTaddress, _amount, _expiration, _v, _r, _s);
    }

     
     
     
     
     
     
    function buyNDC(uint256 _NDCprice,
                    uint256 _expiration,
                    uint8 _v,
                    bytes32 _r,
                    bytes32 _s
                   ) payable external {
         
        require(_expiration >= block.timestamp);

         
        address signer = ecrecover(keccak256(_NDCprice, _expiration), _v, _r, _s);
        require(signer == neverdieSigner);

        uint256 a = SafeMath.div(SafeMath.mul(msg.value, 10**18), _NDCprice);
        assert(ndc.transfer(msg.sender, a));

         
        BuyNDC(msg.sender, _NDCprice, msg.value, a);
    }

     
     
     
     
     
     
    function buyTPT(uint256 _TPTprice,
                    uint256 _expiration,
                    uint8 _v,
                    bytes32 _r,
                    bytes32 _s
                   ) payable external {
         
        require(_expiration >= block.timestamp);

         
        address signer = ecrecover(keccak256(_TPTprice, _expiration), _v, _r, _s);
        require(signer == neverdieSigner);

        uint256 a = SafeMath.div(SafeMath.mul(msg.value, 10**18), _TPTprice);
        assert(tpt.transfer(msg.sender, a));

         
        BuyTPT(msg.sender, _TPTprice, msg.value, a);
    }

     
    function () payable public { 
        revert(); 
    }

     
    function withdrawEther() external onlyOwner {
        owner.transfer(this.balance);
    }

     
     
    function withdraw(address _tokenContract) external onlyOwner {
        ERC20 token = ERC20(_tokenContract);
        uint256 balance = token.balanceOf(this);
        assert(token.transfer(owner, balance));
    }

     
    function kill() onlyOwner public {
        uint256 allNDC = ndc.balanceOf(this);
        uint256 allTPT = tpt.balanceOf(this);
        assert(ndc.transfer(owner, allNDC) && tpt.transfer(owner, allTPT));
        selfdestruct(owner);
    }

}