pragma solidity ^0.4.20;

contract owned {
    address public owner;
    function owned() public {owner = msg.sender;}
    modifier onlyOwner { require(msg.sender == owner); _;}
    function transferOwnership(address newOwner) onlyOwner public {owner = newOwner;}
}

contract EmtCrowdfund is owned {
    string public name;
    string public symbol;
    uint8 public decimals = 8;
    uint256 public totalSupply;
    uint256 public tokenPrice;
    uint public minBuyAmount = 700000000000000000;        
    uint public maxBuyAmount = 13000000000000000000;      
    uint public bonusPercent = 20;

    mapping (address => uint256) public balanceOf;
    mapping (address => bool) public frozenAccount;
    mapping (address => uint[]) public paymentHistory;
    mapping (address => mapping (uint => uint)) public paymentDetail;

    event Transfer(address indexed from, address indexed to, uint value);
    event Burn(address indexed from, uint value);
    event FrozenFunds(address target, bool frozen);

    function EmtCrowdfund(
        uint256 initialSupply,
        uint256 _tokenPrice,
        string tokenName,
        string tokenSymbol
    ) public {
        tokenPrice = _tokenPrice / 10 ** uint256(decimals);
        totalSupply = initialSupply * 10 ** uint256(decimals);
        name = tokenName;
        symbol = tokenSymbol;
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

     
    function transfer(address _to, uint _value) public {
        _transfer(msg.sender, _to, _value);
    }

     
    function burnFrom(address _from, uint _value) public onlyOwner returns (bool success) {
        require(balanceOf[_from] >= _value);
        balanceOf[_from] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }

     
    function setPrices(uint256 _tokenPrice) onlyOwner public {
        tokenPrice = _tokenPrice;
    }

    function setBuyLimits(uint _min, uint _max) onlyOwner public {
        minBuyAmount = _min;
        maxBuyAmount = _max;
    }

    function setBonus(uint _percent) onlyOwner public {
        bonusPercent = _percent;
    }

    function() payable public{
        buy();
    }

     
    function buy() payable public {

        uint now_ = now;

        if(minBuyAmount > 0){
            require(msg.value >= minBuyAmount);
        }

        if(maxBuyAmount > 0){
            require(msg.value <= maxBuyAmount);

            if(paymentHistory[msg.sender].length > 0){
                uint lastTotal = 0;
                uint thisDay = now_ - 86400;

                for (uint i = 0; i < paymentHistory[msg.sender].length; i++) {
                    if(paymentHistory[msg.sender][i] >= thisDay){
                        lastTotal += paymentDetail[msg.sender][paymentHistory[msg.sender][i]];
                    }
                }

                require(lastTotal <= maxBuyAmount);
            }
        }

        uint amount = msg.value / tokenPrice;

        if(bonusPercent > 0){
            uint bonusAmount = amount / 100 * bonusPercent;
            amount += bonusAmount;
        }

        require (totalSupply >= amount);
        require(!frozenAccount[msg.sender]);
        totalSupply -= amount;
        balanceOf[msg.sender] += amount;

        paymentHistory[msg.sender].push(now_);
        paymentDetail[msg.sender][now_] = amount;

        emit Transfer(address(0), msg.sender, amount);
    }

     
    function manualTransfer(address _to, uint _value) public onlyOwner returns (bool success) {
        require (totalSupply >= _value);
        require(!frozenAccount[_to]);
        totalSupply -= _value;
        balanceOf[_to] += _value;
        emit Transfer(address(0), _to, _value);
        return true;
    }

     
    function withdrawAll() onlyOwner public {
        owner.transfer(address(this).balance);
    }
}