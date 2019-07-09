pragma solidity ^0.4.23;

 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

}

 
 
 
library SafeMath {
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
}

contract BLTCoin is ERC20Interface, Owned{
    using SafeMath for uint;
    
    string public symbol;
    string public name;
    uint8 public decimals;
    uint _totalSupply;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    uint256 public rate;  
    uint256 public weiRaised;   
    uint value;
    uint _ICOTokensLimit;
    uint _ownerTokensLimit;
    uint public bonusPercentage;
    bool public icoOpen;
    bool public bonusCompaignOpen;
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
     
    modifier onlyWhileOpen {
        require(icoOpen);
        _;
    }
     
     
     
    function BLTCoin(address _owner) public{
        icoOpen = false;
        bonusCompaignOpen = false;
        symbol = "BLT";
        name = "BrotherlyLend";
        decimals = 18;
        rate = 142857;  
        owner = _owner;
        _totalSupply = totalSupply();
        _ICOTokensLimit = _icoTokens();
        _ownerTokensLimit = _ownersTokens();
        balances[owner] = _ownerTokensLimit;
        balances[this] = _ICOTokensLimit;
        emit Transfer(address(0),owner,_ownerTokensLimit);
        emit Transfer(address(0),this,_ICOTokensLimit);
    }
    
    function _icoTokens() internal constant returns(uint){
        return 9019800000 * 10**uint(decimals);
    }
    
    function _ownersTokens() internal constant returns(uint){
        return 11024200000 * 10**uint(decimals);
    }
    
    function totalSupply() public constant returns (uint){
       return 20044000000 * 10**uint(decimals);
    }
    
    function startICO() public onlyOwner{
        require(!icoOpen);
        icoOpen = true;
    }
    
    function stopICO() public onlyOwner{
        require(icoOpen);
        icoOpen = false;
    }

    function startBonusCompaign(uint _percentage) public onlyOwner{
        bonusCompaignOpen = true;
        bonusPercentage = _percentage;
    }
    
    function stopBonusCompaign() public onlyOwner{
        bonusCompaignOpen = false;
    }
     
     
     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

     
     
     
     
     
    function transfer(address to, uint tokens) public returns (bool success) {
         
        require(to != 0x0);
        require(balances[msg.sender] >= tokens );
        require(balances[to] + tokens >= balances[to]);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender,to,tokens);
        return true;
    }
    
    function _transfer(address _to, uint _tokens) internal returns (bool success){
         
        require(_to != 0x0);
        require(balances[this] >= _tokens );
        require(balances[_to] + _tokens >= balances[_to]);
        balances[this] = balances[this].sub(_tokens);
        balances[_to] = balances[_to].add(_tokens);
        emit Transfer(this,_to,_tokens);
        return true;
    }
    
     
     
     
     
    function approve(address spender, uint tokens) public returns (bool success){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

     
     
     
     
     
     
     
     
     
    function transferFrom(address from, address to, uint tokens) public returns (bool success){
        require(tokens <= allowed[from][msg.sender]);  
        require(balances[from] >= tokens);
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        emit Transfer(from,to,tokens);
        return true;
    }
     
     
     
     
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    function () external payable{
        buyTokens(msg.sender);
    }
    
    function buyTokens(address _beneficiary) public payable onlyWhileOpen{
        
        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

         
        uint256 tokens = _getTokenAmount(weiAmount);
        
        if(bonusCompaignOpen){
            uint p = tokens.mul(bonusPercentage.mul(100));
            p = p.div(10000);
            tokens = tokens.add(p);
        }
        
         
        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(_beneficiary, tokens);
        TokenPurchase(this, _beneficiary, weiAmount, tokens);

        _forwardFunds();
    }
  
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        require(_beneficiary != address(0x0));
        require(_weiAmount != 0);
    }
  
    function _getTokenAmount(uint256 _weiAmount) internal returns (uint256) {
        return _weiAmount.mul(rate);
    }
  
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        _transfer(_beneficiary,_tokenAmount);
    }

    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }
  
    function _forwardFunds() internal {
        owner.transfer(msg.value);
    }
}