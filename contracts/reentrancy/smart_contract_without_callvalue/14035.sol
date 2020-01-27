pragma solidity 0.4.23;

 
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b > 0);  
        uint256 c = a / b;
        assert(a == b * c + a % b);  
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20
{
    function totalSupply()public view returns(uint total_Supply);
    function balanceOf(address who)public view returns(uint256);
    function allowance(address owner, address spender)public view returns(uint);
    function transferFrom(address from, address to, uint value)public returns(bool ok);
    function approve(address spender, uint value)public returns(bool ok);
    function transfer(address to, uint value)public returns(bool ok);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}




contract YettaToken is ERC20
{
    using SafeMath for uint256;

   
    uint256 constant public TOKEN_DECIMALS = 10 ** 8;
    uint256 constant public ETH_DECIMALS = 10 ** 18;
    uint256 public TotalCrowdsaleSupply = 25000000;  
    uint256 public TotalOwnerSupply = 60000000;      
    uint256 public BonusPoolSupply = 15000000;   
   

     
    string public constant name = "Yetta Token";

     
    string public constant symbol = "YET";

    uint8 public constant decimals = 8;

     
    uint public TotalTokenSupply = 100000000 * TOKEN_DECIMALS;   

     
    address public owner;
    
    address public bonusPool = 0xf6148aD4C8b2138B9029301310074F391ea4529D;
    address public YettaCrowdSale;
    bool public mintedCrowdsale;
    
     bool public lockstatus; 
 
     uint public Currenttask;
     string public Currentproposal;
 
    mapping(address => mapping(address => uint)) allowed;
    mapping(uint =>mapping(address => bool)) Task;
    mapping(uint =>bool) public acceptProp;
    mapping(uint =>uint256) public agreed;
    mapping(uint =>uint256) public disagreed;
  
    mapping(address => uint) balances;
 
    enum VotingStages {
        VOTING_NOTSTARTED,
        VOTING_OPEN,
        VOTING_CLOSED
    }

    VotingStages public votingstage;

    modifier atStage(VotingStages _stage) {
        require(votingstage == _stage);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public
    {
       
        owner = msg.sender;
        lockstatus = true;
        votingstage = VotingStages.VOTING_NOTSTARTED;
        balances[owner] = TotalOwnerSupply.mul(TOKEN_DECIMALS);
         balances[bonusPool] = BonusPoolSupply.mul(TOKEN_DECIMALS);
        emit Transfer(0, owner, balances[owner]);
        emit Transfer(0, bonusPool, balances[bonusPool]);
    }
    
    function Bonus_PoolTransfer(address receiver, uint256 tokenQuantity) external onlyOwner {
      
             require( receiver != 0x0);
             require(balances[bonusPool] >= tokenQuantity && tokenQuantity >= 0);
             balances[bonusPool] = (balances[bonusPool]).sub(tokenQuantity);
             balances[receiver] = balances[receiver].add(tokenQuantity);
            
             emit Transfer(0, receiver, tokenQuantity);
    }
    
    function mint_Crowdsale(address _YettaCrowdSale) public onlyOwner{
        require(!mintedCrowdsale);
        YettaCrowdSale = _YettaCrowdSale;
        balances[YettaCrowdSale] = balances[YettaCrowdSale].add(TotalCrowdsaleSupply.mul(TOKEN_DECIMALS));
        mintedCrowdsale = true;
        emit Transfer(0,YettaCrowdSale,  balances[YettaCrowdSale]);
    }

   function startVoting(uint newtask, string _currentproposal) external onlyOwner
    {
        votingstage = VotingStages.VOTING_OPEN;
        Currenttask = newtask;
        Currentproposal = _currentproposal;
    }
    
     
     
     function VotedForProposal(uint _task, address spender) public constant returns(bool)
    {
        require(spender != 0x0);
        return Task[_task][spender];
    }

     function submitVote(uint _task, bool proposal) public atStage(VotingStages.VOTING_OPEN){
        require(Currenttask == _task);
        require(balanceOf(msg.sender)>0); 
        require(Task[_task][msg.sender] ==false);  
         if(proposal == true){
            agreed[_task] = agreed[_task].add(balanceOf(msg.sender));
            Task[_task][msg.sender] = true;
        }
        else{
            disagreed[_task] = disagreed[_task].add(balanceOf(msg.sender));
            Task[_task][msg.sender] = true;
        }
       
            }
            
    function finaliseVoting(uint _currenttask) external onlyOwner atStage(VotingStages.VOTING_OPEN){
            require(Currenttask == _currenttask);
                if(agreed[_currenttask] <  disagreed[_currenttask]){
                    
                    acceptProp[_currenttask]=false;
                    
                }
                
                else{
                   
                     acceptProp[_currenttask]=true;
                }
                votingstage = VotingStages.VOTING_CLOSED;
            }


 
    function removeLocking(bool RunningStatusLock) external onlyOwner
    {
        lockstatus = RunningStatusLock;
    }

     
    function totalSupply() public view returns(uint256 total_Supply) {
        total_Supply = TotalTokenSupply;
    }

     
    function balanceOf(address token_Owner)public constant returns(uint256 balance) {
        return balances[token_Owner];
    }

     
     
     
     
     
     
    function transferFrom(address from_address, address to_address, uint256 tokens)public returns(bool success)
    {
        require(to_address != 0x0);
        require(balances[from_address] >= tokens && allowed[from_address][msg.sender] >= tokens && tokens >= 0);
        balances[from_address] = (balances[from_address]).sub(tokens);
        allowed[from_address][msg.sender] = (allowed[from_address][msg.sender]).sub(tokens);
        balances[to_address] = (balances[to_address]).add(tokens);
        emit Transfer(from_address, to_address, tokens);
        return true;
    }

     
     
    function approve(address spender, uint256 tokens)public returns(bool success)
    {
        require(spender != 0x0);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function allowance(address token_Owner, address spender) public constant returns(uint256 remaining)
    {
        require(token_Owner != 0x0 && spender != 0x0);
        return allowed[token_Owner][spender];
    }

     
    function transfer(address to_address, uint256 tokens)public returns(bool success)
    {
        if ( msg.sender == owner) {
            require( to_address != 0x0);
            require(balances[owner] >= tokens && tokens >= 0);
            balances[owner] = balances[owner].sub(tokens);
            balances[to_address] = (balances[to_address]).add(tokens);
            emit Transfer(msg.sender, to_address, tokens);
            return true;
        }
        else
        if (!lockstatus && msg.sender != owner) {
        require( to_address != 0x0);
        require(balances[msg.sender] >= tokens && tokens >= 0);
        balances[msg.sender] = (balances[msg.sender]).sub(tokens);
        balances[to_address] = (balances[to_address]).add(tokens);
        emit Transfer(msg.sender, to_address, tokens);
        return true;
        }
        else{
            revert();
        } 
    }
    
     function transferby(address _to,uint256 _amount) external onlyOwner returns(bool success) {
        require( _to != 0x0); 
        require( balances[YettaCrowdSale] >= _amount && _amount > 0);
        balances[YettaCrowdSale] = ( balances[YettaCrowdSale]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        emit Transfer(address(this), _to, _amount);
        return true;
    }
}