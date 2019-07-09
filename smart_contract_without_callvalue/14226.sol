pragma solidity 0.4.23;


 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


 
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  constructor() public {
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

   
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}


 
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

   
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

   
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

   
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

   
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}


 
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);

   
  function checkRole(address addr, string roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }

   
  function hasRole(address addr, string roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }

   
  function addRole(address addr, string roleName)
    internal
  {
    roles[roleName].add(addr);
    emit RoleAdded(addr, roleName);
  }

   
  function removeRole(address addr, string roleName)
    internal
  {
    roles[roleName].remove(addr);
    emit RoleRemoved(addr, roleName);
  }

   
  modifier onlyRole(string roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }

   
   
   
   
   
   
   
   
   

   

   
   
}


 
contract Whitelist is Ownable, RBAC {
  event WhitelistedAddressAdded(address addr);
  event WhitelistedAddressRemoved(address addr);

  string public constant ROLE_WHITELISTED = "whitelist";

   
  modifier onlyWhitelisted() {
    checkRole(msg.sender, ROLE_WHITELISTED);
    _;
  }

   
  function addAddressToWhitelist(address addr)
    onlyOwner
    public
  {
    addRole(addr, ROLE_WHITELISTED);
    emit WhitelistedAddressAdded(addr);
  }

   
  function whitelist(address addr)
    public
    view
    returns (bool)
  {
    return hasRole(addr, ROLE_WHITELISTED);
  }

   
  function addAddressesToWhitelist(address[] addrs)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < addrs.length; i++) {
      addAddressToWhitelist(addrs[i]);
    }
  }

   
  function removeAddressFromWhitelist(address addr)
    onlyOwner
    public
  {
    removeRole(addr, ROLE_WHITELISTED);
    emit WhitelistedAddressRemoved(addr);
  }

   
  function removeAddressesFromWhitelist(address[] addrs)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < addrs.length; i++) {
      removeAddressFromWhitelist(addrs[i]);
    }
  }

}


 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}


contract PresaleSecond is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    uint256 public maxcap;       
    uint256 public exceed;       
    uint256 public minimum;      
    uint256 public rate;         

    bool public paused = false;    
    bool public ignited = false;   
    uint256 public weiRaised = 0;  

    address public wallet;       
    address public distributor;  
    Whitelist public List;       
    ERC20 public Token;          

    constructor (
        uint256 _maxcap,
        uint256 _exceed,
        uint256 _minimum,
        uint256 _rate,
        address _wallet,
        address _distributor,
        address _whitelist,
        address _token
    )
        public
    {
        require(_wallet != address(0));
        require(_whitelist != address(0));
        require(_distributor != address(0));
        require(_token != address(0));

        maxcap = _maxcap;
        exceed = _exceed;
        minimum = _minimum;
        rate = _rate;

        wallet = _wallet;
        distributor = _distributor;

        Token = ERC20(_token);
        List = Whitelist(_whitelist);
    }

     
    function () external payable {
        collect();
    }

 
    event Change(address _addr, string _name);

    function setWhitelist(address _whitelist) external onlyOwner {
        require(_whitelist != address(0));

        List = Whitelist(_whitelist);
        emit Change(_whitelist, "whitelist");
    }

    function setDistributor(address _distributor) external onlyOwner {
        require(_distributor != address(0));

        distributor = _distributor;
        emit Change(_distributor, "distributor");

    }

    function setWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0));

        wallet = _wallet;
        emit Change(_wallet, "wallet");
    }

 
    event Pause();
    event Resume();
    event Ignite();
    event Extinguish();

    function pause() external onlyOwner {
        paused = true;
        emit Pause();
    }

    function resume() external onlyOwner {
        paused = false;
        emit Resume();
    }

    function ignite() external onlyOwner {
        ignited = true;
        emit Ignite();
    }

    function extinguish() external onlyOwner {
        ignited = false;
        emit Extinguish();
    }

 
    event Purchase(address indexed _buyer, uint256 _purchased, uint256 _refund, uint256 _tokens);

    mapping (address => uint256) public buyers;

    function collect() public payable {
        address buyer = msg.sender;
        uint256 amount = msg.value;

        require(ignited && !paused);
        require(List.whitelist(buyer));
        require(buyer != address(0));
        require(buyers[buyer].add(amount) >= minimum);
        require(buyers[buyer] < exceed);
        require(weiRaised < maxcap);

        uint256 purchase;
        uint256 refund;

        (purchase, refund) = getPurchaseAmount(buyer, amount);

        weiRaised = weiRaised.add(purchase);

        if(weiRaised >= maxcap) ignited = false;

        buyers[buyer] = buyers[buyer].add(purchase);
        emit Purchase(buyer, purchase, refund, purchase.mul(rate));

        buyer.transfer(refund);
    }

 
    function getPurchaseAmount(address _buyer, uint256 _amount)
        private
        view
        returns (uint256, uint256)
    {
        uint256 d1 = maxcap.sub(weiRaised);
        uint256 d2 = exceed.sub(buyers[_buyer]);

        uint256 d = (d1 > d2) ? d2 : d1;

        return (_amount > d) ? (d, _amount.sub(d)) : (_amount, 0);
    }

 
    bool public finalized = false;

    function finalize() external onlyOwner {
        require(!ignited && !finalized);

        withdrawEther();
        withdrawToken();

        finalized = true;
    }

 
    event Release(address indexed _to, uint256 _amount);
    event Refund(address indexed _to, uint256 _amount);

    function release(address _addr)
        external
        returns (bool)
    {
        require(!ignited && !finalized);
        require(msg.sender == distributor);  
        require(_addr != address(0));

        if(buyers[_addr] == 0) return false;

        uint256 releaseAmount = buyers[_addr].mul(rate);
        buyers[_addr] = 0;

        Token.safeTransfer(_addr, releaseAmount);
        emit Release(_addr, releaseAmount);

        return true;
    }

     
     
    function refund(address _addr)
        external
        returns (bool)
    {
        require(!ignited && !finalized);
        require(msg.sender == distributor);  
        require(_addr != address(0));

        if(buyers[_addr] == 0) return false;

        uint256 refundAmount = buyers[_addr];
        buyers[_addr] = 0;

        _addr.transfer(refundAmount);
        emit Refund(_addr, refundAmount);

        return true;
    }

 
    event WithdrawToken(address indexed _from, uint256 _amount);
    event WithdrawEther(address indexed _from, uint256 _amount);

    function withdrawToken() public onlyOwner {
        require(!ignited);
        Token.safeTransfer(wallet, Token.balanceOf(address(this)));
        emit WithdrawToken(wallet, Token.balanceOf(address(this)));
    }

    function withdrawEther() public onlyOwner {
        require(!ignited);
        wallet.transfer(address(this).balance);
        emit WithdrawEther(wallet, address(this).balance);
    }
}