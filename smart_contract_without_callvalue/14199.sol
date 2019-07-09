pragma solidity ^0.4.20;

contract FiatContract {
  function USD(uint _id) constant returns (uint256);
}

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; 
}

contract TokenERC20 {
     
    string public name;
    string public symbol;
    uint8 public decimals = 18;
     
    uint256 public totalSupply;

     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Burn(address indexed from, uint256 value);

     
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);   
        balanceOf[msg.sender] = totalSupply;                 
        name = tokenName;                                    
        symbol = tokenSymbol;                                
    }

     
    function _transfer(address _from, address _to, uint _value) internal {
         
        require(_to != 0x0);
         
        require(balanceOf[_from] >= _value);
         
        require(balanceOf[_to] + _value > balanceOf[_to]);
         
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
         
        balanceOf[_from] -= _value;
         
        balanceOf[_to] += _value;
        
        emit Transfer(_from, _to, _value);
         
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

     
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);      
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

}

 
 
 

contract BimCoinToken is owned, TokenERC20 {

    FiatContract private fiatService;
    uint256 public buyPrice;
    bool private useFiatService;
    bool private onSale;
    uint256 private buyPriceInCent;
    uint256 private etherPerCent;
    uint256 constant TOKENS_PER_DOLLAR = 100000;
    uint256 storageAmount;
    address store;

    mapping (address => bool) public frozenAccount;

     
    event FrozenFunds(address target, bool frozen);

     
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        bool _useFiatContract
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {
        fiatService = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591);
        useFiatService = _useFiatContract;
        buyPriceInCent = 100;
        onSale = true;
        storageAmount = (2 * (initialSupply * 10 ** uint256(decimals)))/10;
        store = msg.sender;
    }

     
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                                
        require (balanceOf[_from] >= _value);                
        require (balanceOf[_to] + _value >= balanceOf[_to]);  
        require(!frozenAccount[_from]);                      
        require(!frozenAccount[_to]);                        
        balanceOf[_from] -= _value;                          
        balanceOf[_to] += _value;                            
        emit Transfer(_from, _to, _value);
    }

     
     
     
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

     
     
    function setPrice(uint256 newBuyPrice) onlyOwner public {
        buyPrice = newBuyPrice;
    }
    
     
     
    function setPriceInCents(uint256 newBuyPrice) onlyOwner public {
        buyPriceInCent = newBuyPrice;
    }
    
     
    function () payable public {
        buy();
    }

     
    function buy() payable public {
        require(onSale);
        
        uint256 price = getPrice();
        
        uint amount = msg.value * TOKENS_PER_DOLLAR * 10 ** uint256(decimals) / price;                
        
        require(balanceOf[owner] - amount >= storageAmount);
        
        store.transfer(msg.value);
        
        _transfer(owner, msg.sender, amount);               
    }
    
    function getPrice() private view returns (uint256){
        if(useFiatService){
            return fiatService.USD(0) * buyPriceInCent;
        }else{
            return etherPerCent * buyPriceInCent;
        }
    }
    
    function setUseService(bool status) external onlyOwner{
        useFiatService = status;
    }
    
    function setEtherCentPrice(uint256 _newValue) external onlyOwner {
        etherPerCent = (10 ** uint256(decimals))/(_newValue);
    }
    
    function setStore(address _newValue) external onlyOwner {
        store = _newValue;
    }
    
    function toggleSale(bool _value) external onlyOwner {
        onSale = _value;
    }
    
    function withdraw() external onlyOwner {
        uint balance = address(this).balance;
        if(balance > 0){
            store.transfer(balance);
        }
    }
}