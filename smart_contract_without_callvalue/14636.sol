pragma solidity ^0.4.23;

contract EthereumOneToken {
     
    string public constant version = 'DU30 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


     
    mapping (address => withdrawalRequest) public withdrawalRequests;
    struct withdrawalRequest {
    uint sinceTime;
    uint256 amount;
    }

    uint256 public constant initialSupply = 1000000000;

     
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Deposited(address indexed by, uint256 amount);

     
    function EthereumOneToken(
    string tokenName,
    uint8 decimalUnits,
    string tokenSymbol
    ) {

        balanceOf[msg.sender] = initialSupply;               
        totalSupply = initialSupply * 1000000000000000000;   
        name = tokenName;                                    
        symbol = tokenSymbol;                                
        decimals = decimalUnits;                             
    }

  
    modifier notPendingWithdrawal {
        if (withdrawalRequests[msg.sender].sinceTime > 0) throw;
        _;
    }


    function transfer(address _to, uint256 _value) notPendingWithdrawal {
        if (balanceOf[msg.sender] < _value) throw;           
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; 
        if (withdrawalRequests[_to].sinceTime > 0) throw;   
        balanceOf[msg.sender] -= _value;                     
        balanceOf[_to] += _value;                          
        Transfer(msg.sender, _to, _value);               
    }

 
    function approve(address _spender, uint256 _value) notPendingWithdrawal
    returns (bool success) {
        if ((_value != 0) && (allowance[msg.sender][_spender] != 0)) throw;
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;                                       
    }


     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) notPendingWithdrawal
    returns (bool success) {

        if (!approve(_spender, _value)) return false;

        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) {
            throw;
        }
        return true;
    }

  
    function transferFrom(address _from, address _to, uint256 _value)
    returns (bool success) {
         
        if (withdrawalRequests[_from].sinceTime > 0) throw;   
        if (withdrawalRequests[_to].sinceTime > 0) throw;     
        if (balanceOf[_from] < _value) throw;                 
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; 
        if (_value > allowance[_from][msg.sender]) throw;     
        balanceOf[_from] -= _value;                           
        balanceOf[_to] += _value;                            
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

     
    function () payable notPendingWithdrawal {
        uint256 amount = msg.value;          
        if (amount == 0) throw;              
        balanceOf[msg.sender] += amount;     
        totalSupply += amount;               
        Transfer(0, msg.sender, amount);     
        Deposited(msg.sender, amount);
    }
}