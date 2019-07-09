pragma solidity ^0.4.18;

 
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
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
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

 
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

     
    function add(Role storage role, address addr)
    internal
    {
        role.bearer[addr] = true;
    }

     
    function remove(Role storage role, address addr)
    internal
    {
        role.bearer[addr] = false;
    }

     
    function check(Role storage role, address addr)
    view
    internal
    {
        require(has(role, addr));
    }

     
    function has(Role storage role, address addr)
    view
    internal
    returns (bool)
    {
        return role.bearer[addr];
    }
}

 
contract RBAC {
    using Roles for Roles.Role;

    mapping (string => Roles.Role) private roles;

    event RoleAdded(address addr, string roleName);
    event RoleRemoved(address addr, string roleName);

     
    function checkRole(address addr, string roleName)
    view
    public
    {
        roles[roleName].check(addr);
    }

     
    function hasRole(address addr, string roleName)
    view
    public
    returns (bool)
    {
        return roles[roleName].has(addr);
    }

     
    function addRole(address addr, string roleName)
    internal
    {
        roles[roleName].add(addr);
        emit RoleAdded(addr, roleName);
    }

     
    function removeRole(address addr, string roleName)
    internal
    {
        roles[roleName].remove(addr);
        emit RoleRemoved(addr, roleName);
    }

     
    modifier onlyRole(string roleName)
    {
        checkRole(msg.sender, roleName);
        _;
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

 
contract TitanToken is Ownable, StandardToken, RBAC {

    string public name = 'Titan Coin';
    string public symbol = 'TC';
    uint256 public decimals = 8;

    string public constant ROLE_EXCHANGER = "exchanger";

    uint256 public constant INITIAL_SUPPLY = 100000000 * 10 ** 8;
    uint256 public MAXIMUM_ICO_TOKENS = 87000000 * 10 ** 8;

    uint256 public MAX_BOUNTY_ALLOCATED_TOKENS = 3000000;
    uint256 public OWNERS_ALLOCATED_TOKENS = 100000000;

    modifier hasExchangePermission() {
        checkRole(msg.sender, ROLE_EXCHANGER);
        _;
    }

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[this] = INITIAL_SUPPLY;
    }

     
    function addExchanger(address exchanger) onlyOwner public {
        addRole(exchanger, ROLE_EXCHANGER);
    }

     
    function removeExchanger(address exchanger) onlyOwner public {
        removeRole(exchanger, ROLE_EXCHANGER);
    }

    function exchangeTokens(address _to, uint256 _amount) hasExchangePermission public returns (bool) {
        this.transfer(_to, _amount);
        return true;
    }
}