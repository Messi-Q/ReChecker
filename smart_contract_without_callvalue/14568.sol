 
contract ERC20 {
    uint256 public totalSupply;

    function transfer(address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function mul(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x * y;
        assert((x == 0) || (z / x == y));
        return z;
    }

    function div(uint256 x, uint256 y) internal pure returns(uint256) {
        assert(y != 0);
        uint256 z = x / y;
        assert(x == y * z + x % y);
        return z;
    }
}


 
contract ERC223ReceivingContract { 
     
    function tokenFallback(address _from, uint _value, bytes _data) external;
}


 
contract Ownable {
    address public owner;

     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier validAddress(address _address) {
        require(_address != address(0));
        _;
    }

     
    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

     
    constructor(address _owner) public validAddress(_owner) {
        owner = _owner;
    }

     
     
    function transferOwnership(address _newOwner) public onlyOwner validAddress(_newOwner) {
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}










contract ERC223 is ERC20 {
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);
}




contract StandardToken is ERC223 {
    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

     
    modifier validAddress(address _address) {
        require(_address != address(0));
        _;
    }

     
    function transfer(address _to, uint256 _value) public returns (bool) {
        bytes memory empty;
        transfer(_to, _value, empty);
    }

     
    function transfer(address _to, uint256 _value, bytes _data) public validAddress(_to) returns (bool success) {
        uint codeLength;

        assembly {
             
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

         
        if (codeLength > 0) {
            ERC223ReceivingContract(_to).tokenFallback(msg.sender, _value, _data);
        }

        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool) {
         
         
         
         
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public validAddress(_to) returns (bool) {
        uint256 _allowance = allowed[_from][msg.sender];

         
         

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

     
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

     
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}



contract MintableToken is StandardToken, Ownable {
     
    event Mint(uint256 supply, address indexed to, uint256 amount);

    function tokenTotalSupply() public pure returns (uint256);

     
     
     
     
    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        require(totalSupply.add(_amount) <= tokenTotalSupply());

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        emit Mint(totalSupply, _to, _amount);
        emit Transfer(address(0), _to, _amount);

        return true;
    }
}


contract BodhiEthereum is MintableToken {
     
    string public constant name = "Bodhi Ethereum";
    string public constant symbol = "BOE";
    uint256 public constant decimals = 8;

    constructor() Ownable(msg.sender) public {
    }

     
    function tokenTotalSupply() public pure returns (uint256) {
        return 100 * (10**6) * (10**decimals);
    }
}