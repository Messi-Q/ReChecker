pragma solidity ^0.4.23;

contract ERC20TokenInterface {

     
    function totalSupply() public constant returns (uint256 supply);

     
     
    function balanceOf(address _owner) constant public returns (uint256 balance);

     
     
     
     
    function transfer(address _to, uint256 _value) public returns (bool success);

     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

     
     
     
     
    function approve(address _spender, uint256 _value) public returns (bool success);

     
     
     
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BitCar is ERC20TokenInterface {
	
  function () public {
     
    revert();
  }

   
  string public constant name = 'BitCar';
  uint256 public constant decimals = 8;
  string public constant symbol = 'BITCAR';
  string public constant version = '1.0';
  string public constant note = 'If you can dream it, you can do it. Enzo Ferrari';

   
  uint256 private constant totalTokens = 500000000 * (10 ** decimals);

  mapping (address => uint256) public balances;  
   
   
  mapping (address => mapping (address => uint256)) public allowed;  

   
  event MigrationInfoSet(string newMigrationInfo);

   
   
   
  string public migrationInfo = "";

   
  address public migrationInfoSetter;

   
  modifier onlyFromMigrationInfoSetter {
    if (msg.sender != migrationInfoSetter) {
      revert();
    }
    _;
  }

   
  constructor(address _migrationInfoSetter) public {
    if (_migrationInfoSetter == 0) revert();
    migrationInfoSetter = _migrationInfoSetter;
     
    balances[msg.sender] = totalTokens;
  }

   
  function totalSupply() public constant returns (uint256) {
    return totalTokens;
  }

   
   
   
   
   
   
  function transfer(address _to, uint256 _value) public returns (bool) {
    if (balances[msg.sender] >= _value) {
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      emit Transfer(msg.sender, _to, _value);
      return true;
    }
    return false;
  }

   
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
      balances[_from] -= _value;
      allowed[_from][msg.sender] -= _value;
      balances[_to] += _value;
      emit Transfer(_from, _to, _value);
      return true;
    }
    return false;
  }

   
  function balanceOf(address _owner) constant public returns (uint256) {
    return balances[_owner];
  }

   
   
   
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

   
   
   
   
   
   
   
   
  function compareAndApprove(address _spender, uint256 _currentValue, uint256 _newValue) public returns(bool) {
    if (allowed[msg.sender][_spender] != _currentValue) {
      return false;
    }
    return approve(_spender, _newValue);
  }

   
  function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

   
   
   
   
  function setMigrationInfo(string _migrationInfo) onlyFromMigrationInfoSetter public {
    migrationInfo = _migrationInfo;
    emit MigrationInfoSet(_migrationInfo);
  }

   
   
   
   
  function changeMigrationInfoSetter(address _newMigrationInfoSetter) onlyFromMigrationInfoSetter public {
    migrationInfoSetter = _newMigrationInfoSetter;
  }
}