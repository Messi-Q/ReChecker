pragma solidity ^0.4.13;

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

 
contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}


contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) public balances;

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

 

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}

 

library SafeERC20 {

    function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

        assert(token.transfer(to, value));

    }

 

    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {

        assert(token.transferFrom(from, to, value));

    }

 

    function safeApprove(ERC20 token, address spender, uint256 value) internal {

        assert(token.approve(spender, value));

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

 
}

 
contract WMCToken is StandardToken, BurnableToken, Ownable {

    using SafeMath for uint;

 

    string constant public symbol = "WMC";
    string constant public name = "World Masonic Coin";
    uint8 constant public decimals = 18;
    
    uint public totalSoldTokens = 0;

    uint public constant TOTAL_SUPPLY = 33000000 * (1 ether / 1 wei);

    uint public constant DEVELOPER_supply = 1650000 * (1 ether / 1 wei);

    uint public constant MARKETING_supply =  1650000 * (1 ether / 1 wei);

    uint public constant PROVISIONING_supply =  3300000 * (1 ether / 1 wei);

    uint constant PSMTime = 1529798401;  

    uint public constant PSM_PRICE = 29;   

    uint constant PSTime = 1532476801;  

    uint public constant PS_PRICE = 27;     

    uint constant PINTime = 1535241601;  

    uint public constant PIN_PRICE = 25;     

    uint constant ICOTime = 1574640001;  

    uint public constant ICO_PRICE = 23;     

    uint public constant TOTAL_TOKENs_SUPPLY = 26400000 * (1 ether / 1 wei);  

 
    address beneficiary = 0xef18F44049b0685AbaA63fe3Db43A0bE262453CE;
    address developer = 0x311F0e3Ec7876679A2C4F4BaC6102fCB03536984;
    address marketing = 0xba48AD5BBFA3C66743C269550e468479710084Dd;
    address provisioning = 0xa1905B711D31B0646359Cd6393D7293dC0a5DFDf;

 bool public enableTransfers = true;
 
     
    
    function WMCToken() public {

    balances[provisioning] = balances[provisioning].add(PROVISIONING_supply);
    balances[developer] = balances[developer].add(DEVELOPER_supply);
    balances[marketing] = balances[marketing].add(MARKETING_supply);
    
    }


    function transfer(address _to, uint256 _value) public returns (bool) {

        require(enableTransfers);
        super.transfer(_to, _value);

    }

 
   function approve(address _spender, uint256 _value) public returns (bool) {

        require(enableTransfers);
        return super.approve(_spender,_value);

    }

 

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(enableTransfers);
        super.transferFrom(_from, _to, _value);

    }


     
    
    function () public payable {

        require(enableTransfers);
        uint256 amount = msg.value * getPrice();
        require(totalSoldTokens + amount <= TOTAL_TOKENs_SUPPLY);
        require(msg.value >= ((1 ether / 1 wei) / 100));  
        uint256 amount_marketing = msg.value * 5 /100;
        uint256 amount_development = msg.value * 5 /100 ;
        uint256 amount_masonic_project = msg.value * 90 /100;
        beneficiary.transfer(amount_masonic_project);
        developer.transfer(amount_development);
        marketing.transfer(amount_marketing);
        balances[msg.sender] = balances[msg.sender].add(amount);
        totalSoldTokens+= amount;
        emit Transfer(this, msg.sender, amount);                         

    }

     
     function getPrice()constant public returns(uint)

    {

        if (now < PSMTime) return PSM_PRICE;
        else if (now < PSTime) return PS_PRICE;
        else if (now < PINTime) return PIN_PRICE;
        else if (now < ICOTime) return ICO_PRICE;
        else return ICO_PRICE;  

    }
    
      
    
    function DisableTransfer() public onlyOwner
    {
        enableTransfers = false;
    }
    
         
    
    function EnableTransfer() public onlyOwner
    {
        enableTransfers = true;
    }
    
         
    
        function UpdateBeneficiary(address _beneficiary) public onlyOwner returns(bool)
    {
        beneficiary = _beneficiary;
    }

}