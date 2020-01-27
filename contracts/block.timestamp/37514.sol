pragma solidity ^0.4.14;


// https://github.com/ethereum/wiki/wiki/Standardized_Contract_APIs#transferable-fungibles-see-erc-20-for-the-latest


contract ERC20Token {
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    // Get the total token supply
    function totalSupply() constant returns (uint256 supply);
    
    // Get the account `balance` of another account with address `_owner`
    function balanceOf(address _owner) constant returns (uint256 balance);

    // Send `_value` amount of tokens to address `_to`
    function transfer(address _to, uint256 _value) returns (bool success);
    
    // Send `_value` amount of tokens from address `_from` to address `_to`
    // The `transferFrom` method is used for a withdraw workflow, allowing contracts to send tokens on your behalf, 
    // for example to "deposit" to a contract address and/or to charge fees in sub-currencies; 
    // the command should fail unless the `_from` account has deliberately authorized the sender of the message 
    // via some mechanism; we propose these standardized APIs for `approval`:
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value) returns (bool success);
    
    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
}

contract PrimasToken is ERC20Token {
    address public initialOwner;
    uint256 public supply   = 100000000 * 10 ** 18;  // 100, 000, 000
    string  public name     = 'Primas';
    uint8   public decimals = 18;
    string  public symbol   = 'PST';
    string  public version  = 'v0.1';
    bool    public transfersEnabled = true;
    uint    public creationBlock;
    uint    public creationTime;
    
    mapping (address => uint256) balance;
    mapping (address => mapping (address => uint256)) m_allowance;
    mapping (address => uint) jail;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function PrimasToken() {
        initialOwner        = msg.sender;
        balance[msg.sender] = supply;
        creationBlock       = block.number;
        creationTime        = block.timestamp;
    }

    function balanceOf(address _account) constant returns (uint) {
        return balance[_account];
    }

    function totalSupply() constant returns (uint) {
        return supply;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        // `revert()` | `throw`
        //      http://solidity.readthedocs.io/en/develop/control-structures.html#error-handling-assert-require-revert-and-exceptions
        //      https://ethereum.stackexchange.com/questions/20978/why-do-throw-and-revert-create-different-bytecodes/20981
        if (!transfersEnabled) revert();
        if ( jail[msg.sender] >= block.timestamp ) revert();
        
        return doTransfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        if (!transfersEnabled) revert();
        if ( jail[msg.sender] >= block.timestamp || jail[_to] >= block.timestamp || jail[_from] >= block.timestamp ) revert();
            
        if (allowance(_from, msg.sender) < _value) return false;
        
        m_allowance[_from][msg.sender] -= _value;
        
        if ( !(doTransfer(_from, _to, _value)) ) {
            m_allowance[_from][msg.sender] += _value;
            return false;
        } else {
            return true;
        }
    }

    function doTransfer(address _from, address _to, uint _value) internal returns (bool success) {
        if (balance[_from] >= _value && balance[_to] + _value >= balance[_to]) {
            balance[_from] -= _value;
            balance[_to] += _value;
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }
    
    function approve(address _spender, uint256 _value) returns (bool success) {
        if (!transfersEnabled) revert();
        if ( jail[msg.sender] >= block.timestamp || jail[_spender] >= block.timestamp ) revert();

        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ( (_value != 0) && (allowance(msg.sender, _spender) != 0) ) revert();
        
        m_allowance[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }
    
    function allowance(address _owner, address _spender) constant returns (uint256) {
        if (!transfersEnabled) revert();

        return m_allowance[_owner][_spender];
    }
    
    function enableTransfers(bool _transfersEnabled) returns (bool) {
        if (msg.sender != initialOwner) revert();
        transfersEnabled = _transfersEnabled;
        return transfersEnabled;
    }

    function catchYou(address _target, uint _timestamp) returns (uint) {
        if (msg.sender != initialOwner) revert();
        if (!transfersEnabled) revert();

        jail[_target] = _timestamp;

        return jail[_target];
    }

}