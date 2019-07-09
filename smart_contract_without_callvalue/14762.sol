pragma solidity ^0.4.21;


 
library SafeMath {

     
    function mul(uint256 a, uint256 b) internal pure returns(uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
         
         
         
        return a / b;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

     
    function add(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a + b;
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

 
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


     
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

     
    modifier whenPaused() {
        require(paused);
        _;
    }

     
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

     
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract SKToken is Pausable {
    using SafeMath for uint256;

    string public version = "1.0.0";
    string public name;
    string public symbol;

    uint8 public decimals = 18;
    uint256 public totalSupply;
    bool public mintingFinished = false;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    event FrozenFunds(address indexed target, bool frozen);

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

     
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }

     
    function SKToken(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        name = tokenName;
        symbol = tokenSymbol;
         
        totalSupply = initialSupply.mul(10 ** uint256(decimals));
         
        balanceOf[msg.sender] = totalSupply;
    }

     
    function _transfer(address _from, address _to, uint256 _value) internal {
         
        require(_to != 0x0);
         
        require(!frozenAccount[_from]);
         
        require(!frozenAccount[_to]);
         
        require(balanceOf[_from] >= _value);
         
        require(balanceOf[_to] + _value >= balanceOf[_to]);
         
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
         
        balanceOf[_from] = balanceOf[_from].sub(_value);
         
        balanceOf[_to] = balanceOf[_to].add(_value);
         
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        emit Transfer(_from, _to, _value);
    }

     
    function transfer(address _to, uint256 _value) whenNotPaused onlyPayloadSize(2*32) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused onlyPayloadSize(3*32) public returns (bool success) {
        require(!frozenAccount[msg.sender]);
        require(_value <= allowance[_from][msg.sender]);  
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) whenNotPaused onlyPayloadSize(2*32) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function increaseApproval(address _spender, uint _addedValue) whenNotPaused onlyPayloadSize(2*32) public returns (bool) {
        allowance[msg.sender][_spender] = allowance[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }

     
    function decreaseApproval(address _spender, uint _subtractedValue) whenNotPaused onlyPayloadSize(2*32) public returns (bool) {
        uint oldValue = allowance[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowance[msg.sender][_spender] = 0;
        } else {
            allowance[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }

     
    function burn(uint256 _value) whenNotPaused onlyPayloadSize(32) public returns (bool success) {
        require(!frozenAccount[msg.sender]);
        require(balanceOf[msg.sender] >= _value);       
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);  
        totalSupply = totalSupply.sub(_value);    
        emit Burn(msg.sender, _value);
        return true;
    }

     
    function burnFrom(address _from, uint256 _value) whenNotPaused onlyPayloadSize(2*32) public returns (bool success) {
        require(!frozenAccount[msg.sender]);
        require(!frozenAccount[_from]);
        require(balanceOf[_from] >= _value);               
        require(_value <= allowance[_from][msg.sender]);   
        balanceOf[_from] = balanceOf[_from].sub(_value);   
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);  
        totalSupply = totalSupply.sub(_value);         
        emit Burn(_from, _value);
        return true;
    }

     
    function mint(address target, uint256 mintedAmount) onlyOwner canMint onlyPayloadSize(2*32) public returns (bool) {
        balanceOf[target] = balanceOf[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        emit Transfer(address(0), target, mintedAmount);
        return true;
    }

     
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }

     
    function freezeAccount(address target, bool freeze) onlyOwner public returns (bool) {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
        return true;
    }
}