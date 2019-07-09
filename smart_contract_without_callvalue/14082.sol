pragma solidity ^0.4.24;

 
 
 
 
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

 
 
 
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
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
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

 
contract TokenController {
     
     
     
     
     
     
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

     
     
     
     
     
     
     
    function onApprove(address _owner, address _spender, uint _amount_old, uint _amount_new) public returns(bool);
}

 
 
 
contract DividendsDistributor {
    function totalDividends() public constant returns (uint);
    function totalUndistributedDividends() public constant returns (uint);
    function totalDistributedDividends() public constant returns (uint);
    function totalPaidDividends() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function distributeDividendsOnTransferFrom(address from, address to, uint tokens) public returns (bool success);
    function withdrawDividends() public returns(bool success);

    event DividendsDistributed(address indexed tokenOwner, uint dividends);
    event DividendsPaid(address indexed tokenOwner, uint dividends);
}

 
 
 
 
 
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
}

 
 
 
 
contract AHF_Token is ERC20Interface, Owned {
    string public constant symbol = "AHF";
    string public constant name = "Ahedgefund Sagl Token";
    uint8 public constant decimals = 18;
    uint private constant _totalSupply = 130000000 * 10**uint(decimals);

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    address public dividendsDistributor;
    address public controller;
    
     
    bool public transfersEnabled;
     
     
     
    constructor() public {
        balances[owner] = _totalSupply;
        transfersEnabled = true;
        emit Transfer(address(0), owner, _totalSupply);
    }


    function setDividendsDistributor(address _newDividendsDistributor) public onlyOwner {
        dividendsDistributor = _newDividendsDistributor;
    }

     
     
    function setController(address _newController) public onlyOwner {
        controller = _newController;
    }
    
     
     
     
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


     
     
     
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


     
     
     
     
     
     
     
     
    function approve(address _spender, uint _amount) public returns (bool success) {
        require(transfersEnabled);

         
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, allowed[msg.sender][_spender], _amount));
        }

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }


     
     
     
     
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


     
     
     
     
     
    function transfer(address _to, uint _amount) public returns (bool success) {
        require(transfersEnabled);
        doTransfer(msg.sender, _to, _amount);
        return true;
    }


     
     
     
     
     
     
     
     
     
    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
        require(transfersEnabled);

         
        require(allowed[_from][msg.sender] >= _amount);
        allowed[_from][msg.sender] -= _amount;
        doTransfer(_from, _to, _amount);
        return true;
    }


     
     
     
     
     
     
     
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) public returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

     
     
     
    function () public payable {
        revert();
    }


     
     
     
     
     
     
    function doTransfer(address _from, address _to, uint _amount) internal {
           if (_amount == 0) {
               emit Transfer(_from, _to, _amount);     
               return;
           }

            
           require((_to != 0) && (_to != address(this)));

            
            
           uint previousBalanceFrom = balanceOf(_from);

           require(previousBalanceFrom >= _amount);

            
           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

            
            
           balances[_from] = previousBalanceFrom - _amount;

            
            
           uint previousBalanceTo = balanceOf(_to);
           require(previousBalanceTo + _amount >= previousBalanceTo);  
           balances[_to] = previousBalanceTo + _amount;

            
           emit Transfer(_from, _to, _amount);
           
           if (isContract(dividendsDistributor)) {
                require(DividendsDistributor(dividendsDistributor).distributeDividendsOnTransferFrom(_from, _to, _amount));
            }
    }

     
     
    function enableTransfers(bool _transfersEnabled) public onlyOwner {
        transfersEnabled = _transfersEnabled;
    }

     
     
     
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

     
     
     
     
    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }

        ERC20Interface token = ERC20Interface(_token);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);
        emit ClaimedTokens(_token, owner, balance);
    }
    
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
}