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


contract DragonStats is RBACWithAdmin {
    uint256 constant UINT128_MAX = 340282366920938463463374607431768211455;
    uint256 constant UINT248_MAX = 452312848583266388373324160190187140051835877600158453279131187530910662655;
    struct parent {
        uint128 parentOne;
        uint128 parentTwo;
    }
    
    struct lastAction {
        uint8  lastActionID;
        uint248 lastActionDragonID;
    }
    
    struct dragonStat {
        uint32 fightWin;
        uint32 fightLose;
        uint32 children;
        uint32 fightToDeathWin;
        uint32 mutagenFace;
        uint32 mutagenFight;
        uint32 genLabFace;
        uint32 genLabFight;
    }
    
    mapping(uint256 => uint256) public birthBlock;
    mapping(uint256 => uint256) public deathBlock;
    mapping(uint256 => parent)  public parents;
    mapping(uint256 => lastAction) public lastActions;
    mapping(uint256 => dragonStat) public dragonStats;


    function setBirthBlock(uint256 _dragonID) external onlyRole("MainContract") {
        require(birthBlock[_dragonID] == 0);
        birthBlock[_dragonID] = block.number;
    }
    
    function setDeathBlock(uint256 _dragonID) external onlyRole("MainContract") {
        require(deathBlock[_dragonID] == 0);
        deathBlock[_dragonID] = block.number;
    }
    
    function setParents(uint256 _dragonID, uint256 _parentOne, uint256 _parentTwo) 
        external 
        onlyRole("MainContract") 
    {
        
        require(birthBlock[_dragonID] == 0);
        
        if (_parentOne <= UINT128_MAX) { 
            parents[_dragonID].parentOne = uint128(_parentOne);
        }
        
        if (_parentTwo <= UINT128_MAX) { 
            parents[_dragonID].parentTwo = uint128(_parentTwo);
        }
    }
    
    function setLastAction(uint256 _dragonID, uint256 _lastActionDragonID, uint8 _lastActionID) 
        external 
        onlyRole("ActionContract") 
    {
        lastActions[_dragonID].lastActionID = _lastActionID;
        if (_lastActionDragonID > UINT248_MAX) {
            lastActions[_dragonID].lastActionDragonID = 0;
        } else {
            lastActions[_dragonID].lastActionDragonID = uint248(_lastActionDragonID);
        }
    }
    
    function incFightWin(uint256 _dragonID) external onlyRole("FightContract") {
        dragonStats[_dragonID].fightWin++;
    }
    
    function incFightLose(uint256 _dragonID) external onlyRole("FightContract") {
        dragonStats[_dragonID].fightLose++;
    }
    
    function incFightToDeathWin(uint256 _dragonID) external onlyRole("DeathContract") {
        dragonStats[_dragonID].fightToDeathWin++;
    }
    
    function incChildren(uint256 _dragonID) external onlyRole("MainContract") {
        dragonStats[_dragonID].children++;
    }
    
    function addMutagenFace(uint256 _dragonID, uint256 _mutagenCount) 
        external 
        onlyRole("MutagenFaceContract") 
    {
        dragonStats[_dragonID].mutagenFace = dragonStats[_dragonID].mutagenFace + uint32(_mutagenCount);
    }
    
    function addMutagenFight(uint256 _dragonID, uint256 _mutagenCount) 
        external 
        onlyRole("MutagenFightContract") 
    {
        dragonStats[_dragonID].mutagenFight = dragonStats[_dragonID].mutagenFight + uint32(_mutagenCount);
    }
    
    function incGenLabFace(uint256 _dragonID) external onlyRole("GenLabContract") {
        dragonStats[_dragonID].genLabFace++;
    }
    
    function incGenLabFight(uint256 _dragonID) external onlyRole("GenLabContract") {
        dragonStats[_dragonID].genLabFight++;
    }
    
    function getDragonFight(uint256 _dragonID) external view returns (uint256){
        return  (dragonStats[_dragonID].fightWin + dragonStats[_dragonID].fightLose + dragonStats[_dragonID].fightToDeathWin);
    }
}