pragma solidity ^0.4.11;



 



contract ERC20 {

     

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    event Transfer(address indexed _from, address indexed _to, uint _value);



    function allowance(address _owner, address _spender) constant returns (uint remaining);

    function approve(address _spender, uint _value) returns (bool success);

    function balanceOf(address _owner) constant returns (uint balance);

    function transfer(address _to, uint _value) returns (bool success);

    function transferFrom(address _from, address _to, uint _value) returns (bool success);

}





contract Owned {

     

    address public owner;



     

    function Owned() {

        owner = msg.sender;

    }



     

    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



     

    function transferOwnership(address newOwner) onlyOwner {

        owner = newOwner;

    }

}





library SafeMath {

    function add(uint256 a, uint256 b) internal returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }



    function div(uint256 a, uint256 b) internal returns (uint256) {

         

        uint256 c = a / b;

         

        return c;

    }



    function max64(uint64 a, uint64 b) internal constant returns (uint64) {

        return a >= b ? a : b;

    }



    function max256(uint256 a, uint256 b) internal constant returns (uint256) {

        return a >= b ? a : b;

    }



    function min64(uint64 a, uint64 b) internal constant returns (uint64) {

        return a < b ? a : b;

    }



    function min256(uint256 a, uint256 b) internal constant returns (uint256) {

        return a < b ? a : b;

    }



    function mul(uint256 a, uint256 b) internal returns (uint256) {

        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;

    }



    function sub(uint256 a, uint256 b) internal returns (uint256) {

        assert(b <= a);

        return a - b;

    }

}





contract privlocatum is ERC20, Owned {

     

    using SafeMath for uint256;



     

    string public name;

    string public symbol;

    uint256 public decimals;

    uint256 public totalSupply;



     

    uint256 multiplier;



     

    mapping (address => uint256) balance;

    mapping (address => mapping (address => uint256)) allowed;



     

    modifier onlyPayloadSize(uint size) {

        if(msg.data.length < size + 4) revert();

        _;

    }



     

    function privlocatum(string tokenName, string tokenSymbol, uint8 decimalUnits, uint256 decimalMultiplier) {

        name = tokenName;

        symbol = tokenSymbol;

        decimals = decimalUnits;

        multiplier = decimalMultiplier;

    }



     

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

      return allowed[_owner][_spender];

    }



     

    function approve(address _spender, uint256 _value) returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }



     

    function balanceOf(address _owner) constant returns (uint256 remainingBalance) {

        return balance[_owner];

    }



     

    function mintToken(address target, uint256 mintedAmount) onlyOwner returns (bool success) {

        require(mintedAmount > 0);

        uint256 addTokens = mintedAmount;

        balance[target] += addTokens;

        totalSupply += addTokens;

        Transfer(0, target, addTokens);

        return true;

    }



     

    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) returns (bool success) {

        if ((balance[msg.sender] >= _value) && (balance[_to] + _value > balance[_to])) {

            balance[msg.sender] -= _value;

            balance[_to] += _value;

            Transfer(msg.sender, _to, _value);

            return true;

        } else {

            return false;

        }

    }


     

    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) returns (bool success) {

        if ((balance[_from] >= _value) && (allowed[_from][msg.sender] >= _value) && (balance[_to] + _value > balance[_to])) {

            balance[_to] += _value;

            balance[_from] -= _value;

            allowed[_from][msg.sender] -= _value;

            Transfer(_from, _to, _value);

            return true;

        } else {

            return false;

        }

    }

}





contract privlocatumICO is Owned, privlocatum {

     

    using SafeMath for uint256;



     

    address public multiSigWallet;

    uint256 public amountRaised;

    uint256 public startTime;

    uint256 public stopTime;

    uint256 public hardcap;

    uint256 public price;



     

    bool crowdsaleClosed = true;

    string tokenName = "Privlocatum";

    string tokenSymbol = "PLT";

    uint256 multiplier = 100000000;

    uint8 decimalUnits = 8;







     

    function privlocatumICO()

        privlocatum(tokenName, tokenSymbol, decimalUnits, multiplier) {

            multiSigWallet = msg.sender;

            hardcap = 70000000;

            hardcap = hardcap.mul(multiplier);

    }



     

    function () payable {

        require(!crowdsaleClosed

            && (now < stopTime)

            && (totalSupply.add(msg.value.mul(getPrice()).mul(multiplier).div(1 ether)) <= hardcap));

        address recipient = msg.sender;

        amountRaised = amountRaised.add(msg.value.div(1 ether));

        uint256 tokens = msg.value.mul(getPrice()).mul(multiplier).div(1 ether);

        totalSupply = totalSupply.add(tokens);

        balance[recipient] = balance[recipient].add(tokens);

        require(multiSigWallet.send(msg.value));

        Transfer(0, recipient, tokens);

    }



     

    function getPrice() returns (uint256 result) {

        return price;

    }



     

    function getRemainingTime() constant returns (uint256) {

        return stopTime;

    }



     

    function setHardCapValue(uint256 newHardcap) onlyOwner returns (bool success) {

        hardcap = newHardcap.mul(multiplier);

        return true;

    }



     

    function setMultiSigWallet(address wallet) onlyOwner returns (bool success) {

        multiSigWallet = wallet;

        return true;

    }



     

    function setPrice(uint256 newPriceperEther) onlyOwner returns (uint256) {

        require(newPriceperEther > 0);

        price = newPriceperEther;

        return price;

    }



     

    function startSale(uint256 saleStart, uint256 saleStop, uint256 salePrice, address setBeneficiary) onlyOwner returns (bool success) {

        require(saleStop > now);

        startTime = saleStart;

        stopTime = saleStop;

        crowdsaleClosed = false;

        setPrice(salePrice);

        setMultiSigWallet(setBeneficiary);

        return true;

    }



     

    function stopSale() onlyOwner returns (bool success) {

        stopTime = now;

        crowdsaleClosed = true;

        return true;

    }

}