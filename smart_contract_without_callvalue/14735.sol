pragma solidity ^0.4.16;

 
 
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

 
contract IERC20Token {
    function name() public constant returns (string) { name; }
    function symbol() public constant returns (string) { symbol; }
    function decimals() public constant returns (uint8) { decimals; }
    function totalSupply() public constant returns (uint256) { totalSupply; }
    function balanceOf(address _owner) public constant returns (uint256 balance) { _owner; balance; }
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { _owner; _spender; remaining; }

    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
}

 
contract ERC20Token is IERC20Token {
    using SafeMath for uint256;

    string public standard = 'Token 0.1';
    string public name = '';
    string public symbol = '';
    uint8 public decimals = 0;
    uint256 public totalSupply = 0;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function ERC20Token(string _name, string _symbol, uint8 _decimals) {
        require(bytes(_name).length > 0 && bytes(_symbol).length > 0);
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

    function transfer(address _to, uint256 _value) public validAddress(_to) returns (bool) {
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public validAddress(_to) returns (bool) {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public validAddress(_spender) returns (bool) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
}

contract IOwned {
    function owner() public constant returns (address) { owner; }
    function transferOwnership(address _newOwner) public;
}

contract Owned is IOwned {
    address public owner;
    function Owned() {
        owner = msg.sender;
    }
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }
    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) validAddress(_newOwner) onlyOwner {
        require(_newOwner != owner);
        
        owner = _newOwner;
    }
}

 
contract ISmartToken {
    function initialSupply() public constant returns (uint256) { initialSupply; }

    function totalSoldTokens() public constant returns (uint256) { totalSoldTokens; }
    function totalProjectToken() public constant returns (uint256) { totalProjectToken; }

    function fundingEnabled() public constant returns (bool) { fundingEnabled; }
    function transfersEnabled() public constant returns (bool) { transfersEnabled; }
}

 
contract SmartToken is ISmartToken, ERC20Token, Owned {
    using SafeMath for uint256;
 
     
    uint256 public initialSupply = 80000000 ether;

     
    address public fundingWallet;

     
    bool public fundingEnabled = true;

     
    uint256 public maxSaleToken;

     
    uint256 public totalSoldTokens;
     
    uint256 public totalProjectToken;
    uint256 private totalLockToken;

     
    bool public transfersEnabled = true; 

     
    mapping (address => bool) private fundingWallets;
     
    mapping (address => allocationLock) public allocations;

    struct allocationLock {
        uint256 value;
        uint256 end;
        bool locked;
    }

    event Finalize(address indexed _from, uint256 _value);
    event Lock(address indexed _from, address indexed _to, uint256 _value, uint256 _end);
    event Unlock(address indexed _from, address indexed _to, uint256 _value);
    event DisableTransfers(address indexed _from);

     
     
    function SmartToken() ERC20Token("BITTXN", "BXN", 18) {
         
        fundingWallet = msg.sender; 

        maxSaleToken = initialSupply.mul(100).div(100);

        balanceOf[fundingWallet] = maxSaleToken;
        totalSupply = initialSupply;

        fundingWallets[fundingWallet] = true;
        fundingWallets[0x39ee193486cC7A1A24bBaF84a301e8DD1265c11D] = true;
        fundingWallets[0xBc5814406436173aCc1BD17398110b4F405C124A] = true;
        fundingWallets[0xFc3aCeB2e8Bf624F0A924a6106fBC9e5FfBccD45] = true;
        fundingWallets[0x6da56D0c21F7B2D32a1b411E806A6b4Ce4b51034] = true;
        fundingWallets[0xc55c8D13CD5DA748c30918f899447983B53d896b] = true;
    }

     
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

    modifier transfersAllowed(address _address) {
        if (fundingEnabled) {
            require(fundingWallets[_address]);
        }

        require(transfersEnabled);
        _;
    }

     
     
     
     
    function transfer(address _to, uint256 _value) public validAddress(_to) transfersAllowed(msg.sender) returns (bool) {
        return super.transfer(_to, _value);
    }

     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) public validAddress(_to) transfersAllowed(_from) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

     
     
     
     
     
    function lock(address _to, uint256 _value, uint256 _end) internal validAddress(_to) onlyOwner returns (bool) {
        require(_value > 0);

        assert(totalProjectToken > 0);

         
        totalLockToken = totalLockToken.add(_value);
        assert(totalProjectToken >= totalLockToken);

         
        require(allocations[_to].value == 0);

         
        allocations[_to] = allocationLock({
            value: _value,
            end: _end,
            locked: true
        });

        Lock(this, _to, _value, _end);

        return true;
    }

     
     
    function unlock() external {
        require(allocations[msg.sender].locked);
        require(now >= allocations[msg.sender].end);
        
        balanceOf[msg.sender] = balanceOf[msg.sender].add(allocations[msg.sender].value);

        allocations[msg.sender].locked = false;

        Transfer(this, msg.sender, allocations[msg.sender].value);
        Unlock(this, msg.sender, allocations[msg.sender].value);
    }

     
     
    function finalize() external onlyOwner {
        require(fundingEnabled);

         
         
        totalSoldTokens = maxSaleToken.sub(balanceOf[fundingWallet]);

         
         
         
         
         
        totalProjectToken = totalSoldTokens.mul(50).div(50);

         
         
        lock(0xf03eb5eD89Da5ccAC43498A2C56434e30505AB09, totalProjectToken.mul(90).div(100), now);
         
        lock(0xCAF7149Ef61E54F72ACdC7f44a05E5d7D1Db134B, totalProjectToken.mul(10).div(100), now);
        
         
        balanceOf[fundingWallet] = 0;

         
        fundingEnabled = false;

         
        Transfer(this, fundingWallet, 0);
        Finalize(msg.sender, totalSupply);
    }
     
     
    function disableTransfers() external onlyOwner {
        require(transfersEnabled);

        transfersEnabled = false;

        DisableTransfers(msg.sender);
    }

    function enableTransfers() external onlyOwner {
        require(!transfersEnabled);

        transfersEnabled = !false;

        DisableTransfers(msg.sender);
    }
     
     
    function disableFundingWallets(address _address) external onlyOwner {
        require(fundingEnabled);
        require(fundingWallet != _address);
        require(fundingWallets[_address]);

        fundingWallets[_address] = false;
    }

}