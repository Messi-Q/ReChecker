pragma solidity ^0.4.18;


 
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
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


 
contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) balances;

     
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

         
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

     
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
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


 
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

     
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

     
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        }
        else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}


 
contract Pausable is Ownable {

    bool public paused = false;

    event Pause();
    event Unpause();

     
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

     
    modifier whenPaused() {
        require(paused);
        _;
    }

     
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

     
    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }

}


 
contract PausableToken is StandardToken, Pausable {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

}


 
contract CappedMintableToken is PausableToken {

    uint256 public hard_cap;
     
    mapping (address => bool) mintAgents;

    event MintingAgentChanged(address addr, bool state);
    event Mint(address indexed to, uint256 amount);

     
    modifier onlyMintAgent() {
        require(mintAgents[msg.sender]);
        _;
    }

     
    function setMintAgent(address addr, bool state) onlyOwner whenNotPaused  public {
        mintAgents[addr] = state;
        MintingAgentChanged(addr, state);
    }

     
    function mint(address _to, uint256 _amount) onlyMintAgent whenNotPaused public returns (bool) {
        require (totalSupply.add(_amount) <= hard_cap);
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

     
    function isMintAgent(address _user) public view returns (bool state) {
        return mintAgents[_user];
    }

}


 
contract PlatformToken is CappedMintableToken {

    mapping (address => bool) trustedContract;

    event TrustedContract(address addr, bool state);

     
    modifier onlyTrustedContract() {
        require(trustedContract[msg.sender]);
        _;
    }

     
    function setTrustedContract(address addr, bool state) onlyOwner whenNotPaused public {
        trustedContract[addr] = state;
        TrustedContract(addr, state);
    }

     
    function buy(address who, uint256 amount) onlyTrustedContract whenNotPaused public {
        require (balances[who] >= amount);
        balances[who] = balances[who].sub(amount);
        totalSupply = totalSupply.sub(amount);
    }

     
    function isATrustedContract(address _contract) public view returns (bool state) {
        return trustedContract[_contract];
    }

}


 
contract UpgradeAgent {

    function upgradeBalance(address who, uint256 amount) public;
    function upgradeAllowance(address _owner, address _spender, uint256 amount) public;
    function upgradePendingExchange(address _owner, uint256 amount) public;

}


 
contract UpgradableToken is PlatformToken {

     
    UpgradeAgent public upgradeAgent;
    uint256 public totalSupplyUpgraded;
    bool public upgrading = false;

    event UpgradeBalance(address who, uint256 amount);
    event UpgradeAllowance(address owner, address spender, uint256 amount);
    event UpgradePendingExchange(address owner, uint256 value);
    event UpgradeStateChange(bool state);


     
    modifier whenUpgrading() {
        require(upgrading);
        _;
    }

     
    function setUpgradeAgent(address addr) onlyOwner public {
        upgradeAgent = UpgradeAgent(addr);
    }

     
    function startUpgrading() onlyOwner whenPaused public {
        upgrading = true;
        UpgradeStateChange(true);
    }

     
    function stopUpgrading() onlyOwner whenPaused whenUpgrading public {
        upgrading = false;
        UpgradeStateChange(false);
    }

     
    function upgradeBalanceOf(address who) whenUpgrading public {
        uint256 value = balances[who];
        require (value != 0);
        balances[who] = 0;
        totalSupply = totalSupply.sub(value);
        totalSupplyUpgraded = totalSupplyUpgraded.add(value);
        upgradeAgent.upgradeBalance(who, value);
        UpgradeBalance(who, value);
    }

     
    function upgradeAllowance(address _owner, address _spender) whenUpgrading public {
        uint256 value = allowed[_owner][_spender];
        require (value != 0);
        allowed[_owner][_spender] = 0;
        upgradeAgent.upgradeAllowance(_owner, _spender, value);
        UpgradeAllowance(_owner, _spender, value);
    }

}

 
contract GenbbyToken is UpgradableToken {

    string public contactInformation;
    string public name = "Genbby Token";
    string public symbol = "GG";
    uint256 public constant decimals = 18;
    uint256 public constant factor = 10 ** decimals;

    event UpgradeTokenInformation(string newName, string newSymbol);

    function GenbbyToken() public {
        hard_cap = (10 ** 9) * factor;
        contactInformation = 'https: 
    }

    function setTokenInformation(string _name, string _symbol) onlyOwner public {
        name = _name;
        symbol = _symbol;
        UpgradeTokenInformation(name, symbol);
    }

    function setContactInformation(string info) onlyOwner public {
         contactInformation = info;
    }

     
    function () public payable {
        revert();
    }

}

 
contract Airdrop is Pausable {

    using SafeMath for uint256;

    GenbbyToken public token;

    uint256 public tokens_sold;
    uint256 public constant decimals = 18;
    uint256 public constant factor = 10 ** decimals;
    uint256 public constant total_tokens = 500000 * factor;  

    event Drop(address to, uint256 amount);

     
    function setToken(address tokenAddress) onlyOwner public {
        token = GenbbyToken(tokenAddress);
    }

     
    function drop(address _to, uint256 _amount) onlyOwner whenNotPaused public returns (bool) {
        require (tokens_sold.add(_amount) <= total_tokens);
        token.mint(_to, _amount);
        tokens_sold = tokens_sold.add(_amount);
        Drop(_to, _amount);
        return true;
    }

     
    function () public payable {
        revert();
    }

}