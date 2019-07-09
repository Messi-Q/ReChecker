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

 
interface Token {

     

     
    function balanceOf(address _owner) external constant returns (uint256 balance);

     
    function transfer(address _to, uint256 _value) external returns (bool success);

     
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

     
    function approve(address _spender, uint256 _value) external returns (bool success);

     
    function allowance(address _owner, address _spender) external constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}


 

contract Coinweb is Token {

    using SafeMath for uint256;

    string public constant name = "Coinweb";
    string public constant symbol = "XCOe";
    uint256 public constant decimals = 8;
    uint256 public constant totalSupply = 2400000000 * 10**decimals;
    address public founder = 0x51Db57ABe0Fc0393C0a81c0656C7291aB7Dc0fDe;  
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

     
    bool public transfersAreLocked = true;

     
    constructor() public {
        balances[founder] = totalSupply;
        emit Transfer(address(0), founder, totalSupply);
    }

     
    modifier canTransfer() {
        require(msg.sender == founder || !transfersAreLocked);
        _;
    }

     
    modifier onlyFounder() {
        require(msg.sender == founder);
        _;
    }

    function transfer(address _to, uint256 _value) public canTransfer returns (bool) {
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public canTransfer returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

     
    function setTransferLock(bool _transfersAreLocked) public onlyFounder returns (bool) {
        transfersAreLocked = _transfersAreLocked;
        return true;
    }

     
    function() public {
        revert();
    }
}