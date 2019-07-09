pragma solidity ^0.4.23;


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


contract RBACWithAdmin is RBAC {
   
  string public constant ROLE_ADMIN = "admin";
  string public constant ROLE_PAUSE_ADMIN = "pauseAdmin";

   
  modifier onlyAdmin()
  {
    checkRole(msg.sender, ROLE_ADMIN);
    _;
  }
  modifier onlyPauseAdmin()
  {
    checkRole(msg.sender, ROLE_PAUSE_ADMIN);
    _;
  }
   
  constructor()
    public
  {
    addRole(msg.sender, ROLE_ADMIN);
    addRole(msg.sender, ROLE_PAUSE_ADMIN);
  }

   
  function adminAddRole(address addr, string roleName)
    onlyAdmin
    public
  {
    addRole(addr, roleName);
  }

   
  function adminRemoveRole(address addr, string roleName)
    onlyAdmin
    public
  {
    removeRole(addr, roleName);
  }
}


contract Necropolis is RBACWithAdmin {
    struct Dragon {
        address lastDragonOwner;
        uint256 dragonID;
        uint256 deathReason;  
    }
    
    Dragon[] public dragons;
    mapping(uint256 => uint256) public dragonIndex;
    
    constructor() public {
        Dragon memory _dragon = Dragon({
            lastDragonOwner: 0,
            dragonID: 0,
            deathReason: 0
        });
        dragons.push(_dragon);
    }
    
    function addDragon(
        address _lastDragonOwner, 
        uint256 _dragonID, 
        uint256 _deathReason
    ) 
        external 
        onlyRole("MainContract") 
    {
        Dragon memory _dragon = Dragon({
            lastDragonOwner: _lastDragonOwner,
            dragonID: _dragonID,
            deathReason: _deathReason
        });
        dragonIndex[_dragonID] = dragons.length;
        dragons.push(_dragon);
    }
    
    function deadDragons() external view returns (uint256){
        return dragons.length - 1;
    }
}