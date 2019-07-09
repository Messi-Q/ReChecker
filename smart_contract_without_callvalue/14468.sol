pragma solidity ^0.4.18;

 
contract ERC20Basic {
    mapping(address => uint256) public balances;

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

 
contract Freezing is Ownable, ERC20Basic {
    using SafeMath for uint256;

    address tokenManager;

    bool freezingActive = true;

    event Freeze(address _holder, uint256 _amount);
    event Unfreeze(address _holder, uint256 _amount);

     
    mapping(address => uint256) public freezeBalances;

    modifier onlyTokenManager() {
        assert(msg.sender == tokenManager);
        _;
    }

     
    modifier checkFreezing(address _holder, uint _value) {
        if (freezingActive) {
            require(balances[_holder].sub(_value) >= freezeBalances[_holder]);
        }
        _;
    }


    function setTokenManager(address _newManager) onlyOwner public {
        tokenManager = _newManager;
    }

     
    function onFreezing() onlyTokenManager public {
        freezingActive = true;
    }

     
    function offFreezing() onlyTokenManager public {
        freezingActive = false;
    }

    function Freezing() public {
        tokenManager = owner;
    }

     
    function freezingBalanceOf(address _holder) public view returns (uint256) {
        return freezeBalances[_holder];
    }

     
    function freeze(address _holder, uint _amount) public onlyTokenManager {
        assert(balances[_holder].sub(_amount.add(freezeBalances[_holder])) >= 0);

        freezeBalances[_holder] = freezeBalances[_holder].add(_amount);
        emit Freeze(_holder, _amount);
    }

     
    function unfreeze(address _holder, uint _amount) public onlyTokenManager {
        assert(freezeBalances[_holder].sub(_amount) >= 0);

        freezeBalances[_holder] = freezeBalances[_holder].sub(_amount);
        emit Unfreeze(_holder, _amount);
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

 
contract VerificationStatus {
    enum Statuses {None, Self, Video, Agent, Service}
    Statuses constant defaultStatus = Statuses.None;

    event StatusChange(bytes32 _property, address _user, Statuses _status, address _caller);
}


 
contract Roles is Ownable {

     
    enum RoleItems {Person, Agent, Administrator}
    RoleItems constant defaultRole = RoleItems.Person;

    mapping (address => RoleItems) private roleList;

     
    event RoleChange(address _user, RoleItems _role, address _caller);

     
    modifier onlyAgent() {
        assert(roleList[msg.sender] == RoleItems.Agent);
        _;
    }

     
    modifier onlyAdministrator() {
        assert(roleList[msg.sender] == RoleItems.Administrator || msg.sender == owner);
        _;
    }

     
    function _setRole(address _user, RoleItems _role) internal {
        emit RoleChange(_user, _role, msg.sender);
        roleList[_user] = _role;
    }

     
    function resetRole(address _user) onlyAdministrator public {
        _setRole(_user, RoleItems.Person);
    }

     
    function appointAgent(address _user) onlyAdministrator public {
        _setRole(_user, RoleItems.Agent);
    }

     
    function appointAdministrator(address _user) onlyOwner public returns (bool) {
        _setRole(_user, RoleItems.Administrator);
        return true;
    }

    function getRole(address _user) public view returns (RoleItems) {
        return roleList[_user];
    }

}

 
contract PropertyStorage is Roles, VerificationStatus {

    struct Property {
    Statuses status;
    bool exist;
    uint16 code;
    }

    mapping(address => mapping(bytes32 => Property)) private propertyStorage;

     
    mapping(address => mapping(bytes32 => bool)) agentSign;

    event NewProperty(bytes32 _property, address _user, address _caller);

    modifier propertyExist(bytes32 _property, address _user) {
        assert(propertyStorage[_user][_property].exist);
        _;
    }

     
    function computePropertyHash(string _name, string _data) pure public returns (bytes32) {
        return sha256(_name, _data);
    }

    function _addPropertyValue(bytes32 _property, address _user) internal {
        propertyStorage[_user][_property] = Property(
        Statuses.None,
        true,
        0
        );
        emit NewProperty(_property, _user, msg.sender);
    }

     
    function addPropertyForUser(bytes32 _property, address _user) public onlyAdministrator returns (bool) {
        _addPropertyValue(_property, _user);
        return true;
    }

     
    function addProperty(bytes32 _property) public returns (bool) {
        _addPropertyValue(_property, msg.sender);
        return true;
    }

     
    function getPropertyStatus(bytes32 _property, address _user) public view propertyExist(_property, _user) returns (Statuses) {
        return propertyStorage[_user][_property].status;
    }

     
    function setPropertyStatus(bytes32 _property, address _user, Statuses _status) public onlyAdministrator returns (bool){
        _setPropertyStatus(_property, _user, _status);
        return true;
    }

     
    function setAgentVerificationByAgent(bytes32 _property, address _user) public onlyAgent {
        _setPropertyStatus(_property, _user, Statuses.Agent);
        _signPropertyByAgent(msg.sender, _user, _property);
    }

     
    function setAgentVerificationByAdmin(address _agent, address _user, bytes32 _property) public onlyOwner {
        _setPropertyStatus(_property, _user, Statuses.Agent);
        _signPropertyByAgent(_agent, _user, _property);
    }

     
    function _setPropertyStatus(bytes32 _property, address _user, Statuses _status) internal propertyExist(_property, _user) {
        propertyStorage[_user][_property].status = _status;
        emit StatusChange(_property, _user, _status, msg.sender);
    }

     
    function _signPropertyByAgent(address _agent, address _user, bytes32 _property) internal {
        bytes32 _hash = _getHash(_user, _property);
        agentSign[_agent][_hash] = true;
    }

     
    function checkAgentSign(address _agent, address _user, bytes32 _property) public view returns (bool) {
        bytes32 _hash = _getHash(_user, _property);
        return agentSign[_agent][_hash];
    }

     
    function _getHash(address _user, bytes32 _property) public pure returns (bytes32) {
        return sha256(_user, _property);
    }

}

 
contract ERC20BasicToken is ERC20Basic, Freezing {
    using SafeMath for uint256;

    uint256 totalSupply_;

     
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

     
    function transfer(address _to, uint256 _value) checkFreezing(msg.sender, _value) public returns (bool) {
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

 
contract KYCToken is ERC20BasicToken, ERC20, PropertyStorage {

    mapping(address => mapping(address => uint256)) internal allowed;

    uint256 public totalSupply = 42000000000000000000000000;
    string public name = "KYC.Legal token";
    uint8 public decimals = 18;
    string public symbol = "KYC";

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    function KYCToken() public {
        balances[msg.sender] = totalSupply;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) checkFreezing(_from, _value) public returns (bool) {
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

     
    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return allowed[_owner][_spender];
    }

}