pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 {
     
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    
    struct locked_balances_info{
        uint amount;
        uint time;
    }
    mapping(address => locked_balances_info[]) public lockedBalanceOf;

     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event TransferAndLock(address indexed from, address indexed to, uint256 value, uint256 time);

     
    event Burn(address indexed from, uint256 value);


     
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) public {
        balanceOf[msg.sender] = initialSupply;               
        totalSupply = initialSupply;                         
        name = tokenName;                                    
        symbol = tokenSymbol;                                
        decimals = decimalUnits; 
        owner = msg.sender;                                  
    }
    
     
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                                
        
    if(balanceOf[_from] < _value) {
            uint length = lockedBalanceOf[_from].length;
            uint index = 0;
            if(length > 0){
                    for (uint i = 0; i < length; i++) {
                        if(now > lockedBalanceOf[_from][i].time){
                                balanceOf[_from] += lockedBalanceOf[_from][i].amount;
                                index++;
                        }else{
                                break;
                        }
                    }
                    if(index == length){
                        delete lockedBalanceOf[_from];
                    } else {
                        for (uint j = 0; j < length - index; j++) {
                                lockedBalanceOf[_from][j] = lockedBalanceOf[_from][j + index];
                        }
                        lockedBalanceOf[_from].length = length - index;
                        index = lockedBalanceOf[_from].length;
                    }
            }
    }

        require (balanceOf[_from] >= _value);                 
        require (balanceOf[_to] + _value > balanceOf[_to]);   
        balanceOf[_from] -= _value;                           
        balanceOf[_to] += _value;                             
        Transfer(_from, _to, _value);
    }
    
    function balanceOf(address _owner) constant public returns (uint256 balance){
        balance = balanceOf[_owner];
        uint length = lockedBalanceOf[_owner].length;
        for (uint i = 0; i < length; i++) {
            balance += lockedBalanceOf[_owner][i].amount;
        }
    }
    
     function balanceOfOld(address _owner) constant public returns (uint256 balance) {
        balance = balanceOf[_owner];
    }
    
    function _transferAndLock(address _from, address _to, uint _value, uint _time) internal {
        require (_to != 0x0);                                 
        require (balanceOf[_from] >= _value);                 
        require (balanceOf[_to] + _value > balanceOf[_to]);   
        balanceOf[_from] -= _value;                           
     
        lockedBalanceOf[_to].push(locked_balances_info(_value, _time));
        TransferAndLock(_from, _to, _value, _time);
    }

     
     
     
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    
    function transferAndLock(address _to, uint256 _value, uint _time) public {
        _transferAndLock(msg.sender, _to, _value, _time + now);
    }

     
     
     
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require (_value < allowance[_from][msg.sender]);      
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

     
     
     
    function approve(address _spender, uint256 _value)
        public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

     
     
     
     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }        

}