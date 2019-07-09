pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
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

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TokenERC20 {
     
    string public name;
    string public symbol;
    uint8 public decimals = 18;
     
    uint256 public totalSupply;

     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    function TokenERC20(
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

 
 
 
contract VAToken is owned, TokenERC20 {

     
    uint256 public buyPrice;
    address public beneficiary;
    bool public canBuy;
    uint256 public totalAmount;

    event Withdrawal(address beneficiary, uint256 amount);

     
    function VAToken() TokenERC20(5000000000, "REEX", "REEX") public {
        beneficiary = msg.sender;
    }

     
     
    function setPrices(uint256 newBuyPrice) onlyOwner public {
         
        buyPrice = newBuyPrice;
    }

    function setCanBuy(bool newCanBuy) onlyOwner public {
        canBuy = newCanBuy;
    }

    function setBeneficiary(address newBeneficiary) onlyOwner public {
        beneficiary = newBeneficiary;
    }

     
    function () payable public {
        require(canBuy);
        require(buyPrice > 0);
        
        require(totalAmount + msg.value > totalAmount);
        totalAmount += msg.value;

        uint amount = msg.value / buyPrice;                
        _transfer(owner, msg.sender, amount);               
    }

    function withdrawal(uint amount) onlyOwner public {
        require(amount > 0);
        require(totalAmount >= amount);

        totalAmount -= amount;
        beneficiary.transfer(amount);

        emit Withdrawal(beneficiary, amount);
    }
}