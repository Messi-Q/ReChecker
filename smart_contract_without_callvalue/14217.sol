pragma solidity 0.4.21;


 
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


 
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

   
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
     
     

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value);
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


 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
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
    emit Pause();
  }

   
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
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



contract DistributableAndPausableToken is PausableToken {
    uint256 public distributedToken;
    address public vraWallet;

    event Distribute(address indexed to, uint256 amount);
    event Mint(address indexed to, uint256 amount);

    function distributeTokens(address _to, uint256 _amount) 
        external
        onlyOwner
        returns (bool)
    {
        require(_to != address(0));
        require(_amount > 0);
        require(balances[vraWallet].sub(_amount) >= 0);
        balances[vraWallet] = balances[vraWallet].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        distributedToken = distributedToken.add(_amount);
        emit Distribute(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function getDistributedToken() public constant returns (uint256) {
        return distributedToken;
    }

}


 
contract TokenUpgrader {
    uint public originalSupply;

     
    function isTokenUpgrader() external pure returns (bool) {
        return true;
    }

    function upgradeFrom(address _from, uint256 _value) public {}
}


 

contract UpgradeableToken is DistributableAndPausableToken {
     
    address public upgradeMaster;
    
     
    bool private upgradesAllowed;

     
    TokenUpgrader public tokenUpgrader;

     
    uint public totalUpgraded;

     
    enum UpgradeState { NotAllowed, Waiting, ReadyToUpgrade, Upgrading }

     
    event Upgrade(address indexed _from, address indexed _to, uint256 _value);

     
    event TokenUpgraderIsSet(address _newToken);

    modifier onlyUpgradeMaster {
         
        require(msg.sender == upgradeMaster);
        _;
    }

    modifier notInUpgradingState {
         
        require(getUpgradeState() != UpgradeState.Upgrading);
        _;
    }

     
    function UpgradeableToken(address _upgradeMaster) public {
        upgradeMaster = _upgradeMaster;
    }

     
    function setTokenUpgrader(address _newToken)
        external
        onlyUpgradeMaster
        notInUpgradingState
    {
        require(canUpgrade());
        require(_newToken != address(0));

        tokenUpgrader = TokenUpgrader(_newToken);

         
        require(tokenUpgrader.isTokenUpgrader());

         
        require(tokenUpgrader.originalSupply() == totalSupply_);

        emit TokenUpgraderIsSet(tokenUpgrader);
    }

     
    function upgrade(uint _value) external {
        UpgradeState state = getUpgradeState();
        
         
        require(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading);
         
        require(_value != 0);

        balances[msg.sender] = balances[msg.sender].sub(_value);

         
        totalSupply_ = totalSupply_.sub(_value);
        totalUpgraded = totalUpgraded.add(_value);

         
        tokenUpgrader.upgradeFrom(msg.sender, _value);
        emit Upgrade(msg.sender, tokenUpgrader, _value);
    }

     
    function setUpgradeMaster(address _newMaster) external onlyUpgradeMaster {
        require(_newMaster != address(0));
        upgradeMaster = _newMaster;
    }

     
    function allowUpgrades() external onlyUpgradeMaster () {
        upgradesAllowed = true;
    }

     
    function rejectUpgrades() external onlyUpgradeMaster () {
        require(!(totalUpgraded > 0));
        upgradesAllowed = false;
    }

     
    function getUpgradeState() public view returns(UpgradeState) {
        if (!canUpgrade()) return UpgradeState.NotAllowed;
        else if (address(tokenUpgrader) == address(0)) return UpgradeState.Waiting;
        else if (totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
        else return UpgradeState.Upgrading;
    }

     
    function canUpgrade() public view returns(bool) {
        return upgradesAllowed;
    }
}


contract Token is UpgradeableToken, BurnableToken {
    using SafeMath for uint256;
    
    string public name = "VERA";
    string public symbol = "VRA";
    uint256 public maxTokenSupply;
    string public constant TERMS_AND_CONDITION =  "THE DIGITAL TOKENS REPRESENTED BY THIS BLOCKCHAIN LEDGER RECORD HAVE BEEN ACQUIRED FOR INVESTMENT UNDER CERTAIN SECURITIES EXEMPTIONS AND HAVE NOT BEEN REGISTERED UNDER THE U.S. SECURITIES ACT OF 1933, AS AMENDED (THE 'ACT'). UNTIL THE EXPIRATION OF THIS RESTRICTIVE LEGEND, SUCH TOKENS MAY NOT BE OFFERED, SOLD, ASSIGNED, TRANSFERRED, PLEDGED, ENCUMBERED OR OTHERWISE DISPOSED OF TO ANOTHER U.S. PERSON IN THE ABSENCE OF A REGISTRATION OR AN EXEMPTION THEREFROM UNDER THE ACT AND ANY APPLICABLE U.S. STATE SECURITIES LAWS. THE APPLICABLE RESTRICTED PERIOD (PER RULE 144 PROMULGATED UNDER THE ACT) IS ONE YEAR FROM THE ISSUANCE OF THE TOKENS. ANY PARTIES, INCLUDING EXCHANGES AND THE ORIGINAL ACQUIRERS OF THESE TOKENS, MAY BE HELD LIABLE FOR ANY UNAUTHORIZED TRANSFERS OR SALES OF THESE TOKENS DURING THE RESTRICTIVE PERIOD, AND ANY HOLDER OR ACQUIRER OF THESE TOKENS AGREES, AS A CONDITION OF SUCH HOLDING, THAT THE TOKEN GENERATOR/ISSUER (THE 'COMPANY') SHALL BE FREE OF ANY LIABILITY IN CONNECTION WITH SUCH UNAUTHORIZED TRANSACTIONS. REQUESTS TO TRANSFER THESE TOKENS DURING THE RESTRICTIVE PERIOD WITH LEGAL JUSTIFICATION MAY BE MADE BY WRITTEN REQUEST OF THE HOLDER OF THESE TOKENS TO THE COMPANY, WITH NO GUARANTEE OF APPROVAL.";
    uint8 public constant decimals = 18;

    event UpdatedTokenInformation(string newName, string newSymbol);

    function Token(address _vraWallet, address _upgradeMaster, uint256 _maxTokenSupply)
        public
        UpgradeableToken(_upgradeMaster)
    {
        maxTokenSupply = _maxTokenSupply.mul(10 ** uint256(decimals));
        vraWallet = _vraWallet;
        totalSupply_ = maxTokenSupply;
        balances[vraWallet] = totalSupply_;
        pause();
        emit Mint(vraWallet, totalSupply_);
        emit Transfer(address(0), vraWallet, totalSupply_);
    }

     
    function setTokenInformation(string _name, string _symbol) external onlyOwner {
        name = _name;
        symbol = _symbol;

        emit UpdatedTokenInformation(name, symbol);
    }

     
    function burn(uint256 _value) public onlyOwner {
        super.burn(_value);
    }

}