pragma solidity ^0.4.18;

 
 
 
 
 
 
 
 
 


 
 
 

contract SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }

}



 
 
 
 

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

     
    event Burn(address indexed from, uint256 value);

     
    event Mint(address indexed from, uint256 value);
    
     
    event FrozenFunds(address target, bool frozen);
}

 
 
 
 
 
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

 
 
 
contract StopTrade is Owned {

    bool public stopped = false;

    event TradeStopped(bool stopped);

    modifier stoppable {
        assert (!stopped);
        _;
    }

    function stop() onlyOwner public {
        stopped = true;
        TradeStopped(true);
    }

    function start() onlyOwner public {
        stopped = false;
        TradeStopped(false);
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external ; }

 
 
 
 

contract AWMVoucher is ERC20Interface, SafeMath, StopTrade {

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping (address => bool) public frozenAccount;

     
     
     
    function AWMVoucher() public {

        symbol = "ATEST";
        name = "AWM Test Token";
        decimals = 6;

        _totalSupply = 100000000000 * 10**uint(decimals);

        balances[owner] = _totalSupply;
        Transfer(address(0), owner, _totalSupply);
    }

     
     
     
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

     
     
     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

     
    function _transfer(address _from, address _to, uint _value) internal {
         
        require(_to != 0x0);
         
        require(balances[_from] >= _value);
         
        require(balances[_to] + _value > balances[_to]);
        require(!frozenAccount[_from]);           
        require(!frozenAccount[_to]);             

         
        uint previousBalances = add(balances[_from], balances[_to]);

         
        balances[_from] -= _value;

         
        balances[_to] += _value;
        Transfer(_from, _to, _value);

         
        assert(balances[_from] + balances[_to] == previousBalances);
    }

      
    function transfer(address _to, uint256 _value) stoppable public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

     
    function transferFrom(address _from, address _to, uint256 _value) stoppable public returns (bool success) {
        require(_value <= allowed[_from][msg.sender]);      
        allowed[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

     
    function redeem(address _from, address _to, uint256 _value) stoppable public onlyOwner {
        _transfer(_from, _to, _value);
    }



     
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowed[msg.sender][_spender] = _value;
	    Approval(msg.sender, _spender, _value);
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


     
     
     
     
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

     
    function burn(uint256 _value) stoppable onlyOwner public returns (bool success) {
        require(balances[msg.sender] >= _value);    
        balances[msg.sender] = sub(balances[msg.sender], _value); 
        _totalSupply = sub(_totalSupply,_value);
        Burn(msg.sender, _value);
        return true;
    }

     
    function burnFrom(address _from, uint256 _value) stoppable onlyOwner public returns (bool success) {
        require(balances[_from] >= _value);                 
        require(_value <= allowed[_from][msg.sender]);     

         
        balances[_from] = sub(balances[_from], _value);

         
        allowed[_from][msg.sender] = sub(allowed[_from][msg.sender], _value);

         
        _totalSupply = sub(_totalSupply, _value);

        Burn(_from, _value);
        return true;
    }

     
     
     
    function mintToken(address _target, uint256 _mintedAmount) onlyOwner stoppable public {
        require(!frozenAccount[_target]);             

	balances[_target] = add(balances[_target], _mintedAmount);

        _totalSupply = add(_totalSupply, _mintedAmount);

        Mint(_target, _mintedAmount);
        Transfer(0, this, _mintedAmount);
        Transfer(this, _target, _mintedAmount);
    }

    

     
     
     
    function freezeAccount(address _target, bool _freeze) onlyOwner public {
        frozenAccount[_target] = _freeze;
        FrozenFunds(_target, _freeze);
    }

     
     
     
    function () public payable {
        revert();
    }

     
     
     
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }


    function transferToken(address _tokenContract, address _transferTo, uint256 _value) onlyOwner external {

          
          

         ERC20Interface(_tokenContract).transfer(_transferTo, _value);
    }

    function transferTokenFrom(address _tokenContract, address _transferTo, address _transferFrom, uint256 _value) onlyOwner external {

          
          

         ERC20Interface(_tokenContract).transferFrom(_transferTo, _transferFrom, _value);
    }

    function approveToken(address _tokenContract, address _spender, uint256 _value) onlyOwner external {
          
          

         ERC20Interface(_tokenContract).approve(_spender, _value);
    }

}