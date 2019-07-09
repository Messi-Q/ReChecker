pragma solidity ^0.4.23;
 


 
contract SafeMath {

   
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}
 
 
contract ERC20 {
    uint public totalSupply;
    function balanceOf(address who) public view returns (uint);
    function allowance(address owner, address spender) public view returns (uint);

    function transfer(address to, uint value) public returns (bool ok);
    function transferFrom(address from, address to, uint value) public returns (bool ok);
    function approve(address spender, uint value) public returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract ERC223 is ERC20 {
    function transfer(address to, uint value, bytes data) public returns (bool ok);
    function transferFrom(address from, address to, uint value, bytes data) public returns (bool ok);
}

 

contract ERC223Receiver {
    function tokenFallback(address _sender, address _origin, uint _value, bytes _data) public returns (bool ok);
}

contract Standard223Receiver is ERC223Receiver {
    function supportsToken(address token) public view returns (bool);
}


 
 

 
contract LiveBox223Token is ERC20, ERC223, Standard223Receiver, SafeMath {

    mapping(address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
  
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  

    address   contrInitiator;
    address   thisContract;
    bool   isTokenSupport;
  
    mapping(address => bool) isSendingLocked;
    bool isAllTransfersLocked;
  
    uint oneTransferLimit;
    uint oneDayTransferLimit;
 

    struct TransferInfo {
         
         
         
        uint256 value;
        uint time;
    }

    struct TransferInfos {
        mapping (uint => TransferInfo) ti;
        uint tc;
    }
  
    mapping (address => TransferInfos) transferInfo;

 
 

    constructor( ) public {
    
        decimals    = 6;                                 
 
 
        name        = "LiveBoxCoin";                      
        symbol      = 'LBC';                             

        uint initialBalance  = (10 ** uint256(decimals)) * 5000*1000*1000;
    
        balances[msg.sender] = initialBalance;
        totalSupply = initialBalance;
    
        contrInitiator = msg.sender;
        thisContract = this;
        isTokenSupport = false;
    
        isAllTransfersLocked = true;
    
        oneTransferLimit    = (10 ** uint256(decimals)) * 10*1000*1000;
        oneDayTransferLimit = (10 ** uint256(decimals)) * 50*1000*1000;

     
    }

 
 

    function super_transfer(address _to, uint _value)   internal returns (bool success) {

        require(!isSendingLocked[msg.sender]);
        require(_value <= oneTransferLimit);
        require(balances[msg.sender] >= _value);

        if(msg.sender == contrInitiator) {
             
        } else {
            require(!isAllTransfersLocked);  
            require(safeAdd(getLast24hSendingValue(msg.sender), _value) <= oneDayTransferLimit);
        }


        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
    
        uint tc=transferInfo[msg.sender].tc;
        transferInfo[msg.sender].ti[tc].value = _value;
        transferInfo[msg.sender].ti[tc].time = now;
        transferInfo[msg.sender].tc = safeAdd(transferInfo[msg.sender].tc, 1);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function super_transferFrom(address _from, address _to, uint _value)   internal returns (bool success) {
        
        require(!isSendingLocked[_from]);
        require(_value <= oneTransferLimit);
        require(balances[_from] >= _value);

        if(msg.sender == contrInitiator && _from == thisContract) {
             
        } else {
            require(!isAllTransfersLocked);  
            require(safeAdd(getLast24hSendingValue(_from), _value) <= oneDayTransferLimit);
            uint allowance = allowed[_from][msg.sender];
            require(allowance >= _value);
            allowed[_from][msg.sender] = safeSub(allowance, _value);
        }

        balances[_from] = safeSub(balances[_from], _value);
        balances[_to] = safeAdd(balances[_to], _value);
    
        uint tc=transferInfo[_from].tc;
        transferInfo[_from].ti[tc].value = _value;
        transferInfo[_from].ti[tc].time = now;
        transferInfo[_from].tc = safeAdd(transferInfo[_from].tc, 1);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }
  
 
 

     
    function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
         
        if (!super_transfer(_to, _value)) assert(false);  
        if (isContract(_to)) {
            if(!contractFallback(msg.sender, _to, _value, _data)) assert(false);
        }
        return true;
    }

    function transferFrom(address _from, address _to, uint _value, bytes _data) public returns (bool success) {
        if (!super_transferFrom(_from, _to, _value)) assert(false);  
        if (isContract(_to)) {
            if(!contractFallback(_from, _to, _value, _data)) assert(false);
        }
        return true;
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        return transfer(_to, _value, new bytes(0));
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        return transferFrom(_from, _to, _value, new bytes(0));
    }

     
    function contractFallback(address _origin, address _to, uint _value, bytes _data) private returns (bool success) {
        ERC223Receiver reciever = ERC223Receiver(_to);
        return reciever.tokenFallback(msg.sender, _origin, _value, _data);
    }

     
    function isContract(address _addr) private view returns (bool is_contract) {
         
        uint length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }

 
 

    Tkn tkn;

    struct Tkn {
        address addr;
        address sender;
        address origin;
        uint256 value;
        bytes data;
        bytes4 sig;
    }

    function tokenFallback(address _sender, address _origin, uint _value, bytes _data) public returns (bool ok) {
        if (!supportsToken(msg.sender)) return false;

         
        tkn = Tkn(msg.sender, _sender, _origin, _value, _data, getSig(_data));
        __isTokenFallback = true;
        if (!address(this).delegatecall(_data)) return false;

         
         
        __isTokenFallback = false;

        return true;
    }

    function getSig(bytes _data) private pure returns (bytes4 sig) {
        uint l = _data.length < 4 ? _data.length : 4;
        for (uint i = 0; i < l; i++) {
            sig = bytes4(uint(sig) + uint(_data[i]) * (2 ** (8 * (l - 1 - i))));
        }
    }

    bool __isTokenFallback;

    modifier tokenPayable {
        if (!__isTokenFallback) assert(false);
        _;                                                               
    }

     

 
 

 
    function () tokenPayable public {
        emit LogTokenPayable(0, tkn.addr, tkn.sender, tkn.value);
    }

      function supportsToken(address token) public view returns (bool) {
         
         
        if (token != thisContract) {  
            return false;
        }
        if(!isTokenSupport) {   
            return false;
        }
        return true;
    }

    event LogTokenPayable(uint i, address token, address sender, uint value);
  
 
 
 
    function setIsAllTransfersLocked(bool _lock) public {
        require(msg.sender == contrInitiator);
        isAllTransfersLocked = _lock;
    }

    function setIsSendingLocked(address _from, bool _lock) public {
        require(msg.sender == contrInitiator);
        isSendingLocked[_from] = _lock;
    }

    function getIsAllTransfersLocked() public view returns (bool ok) {
        return isAllTransfersLocked;
    }

    function getIsSendingLocked(address _from ) public view returns (bool ok) {
        return isSendingLocked[_from];
    }
 
     
  
 
 
    function getLast24hSendingValue(address _from) public view returns (uint totVal) {
      
        totVal = 0;   
        uint tc = transferInfo[_from].tc;
      
        if(tc > 0) {
            for(uint i = tc-1 ; i >= 0 ; i--) {
 
 
                if(now - transferInfo[_from].ti[i].time < 1 days) {
                    totVal = safeAdd(totVal, transferInfo[_from].ti[i].value );
                } else {
                    break;
                }
            }
        }
    }

    
    function airdropIndividual(address[] _recipients, uint256[] _values, uint256 _elemCount, uint _totalValue)  public returns (bool success) {
        
        require(_recipients.length == _elemCount);
        require(_values.length == _elemCount); 
        
        uint256 totalValue = 0;
        for(uint i = 0; i< _recipients.length; i++) {
            totalValue = safeAdd(totalValue, _values[i]);
        }
        
        require(totalValue == _totalValue);
        
        for(i = 0; i< _recipients.length; i++) {
            transfer(_recipients[i], _values[i]);
        }
        return true;
    }


}