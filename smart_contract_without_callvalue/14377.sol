pragma solidity ^0.4.23;


contract Necropolis {
    function addDragon(address _lastDragonOwner, uint256 _dragonID, uint256 _deathReason) external;
}


contract GenRNG {
    function getNewGens(address _from, uint256 _dragonID) external returns (uint256[2] resultGen);
}


contract DragonSelectFight2Death {
    function addSelctFight2Death(
        address _dragonOwner, 
        uint256 _yourDragonID, 
        uint256 _oppDragonID, 
        uint256 _endBlockNumber, 
        uint256 _priceSelectFight2Death
    ) 
        external;
}


contract DragonsRandomFight2Death {
    function addRandomFight2Death(address _dragonOwner, uint256 _DragonID) external;
}


contract FixMarketPlace {
    function add2MarketPlace(address _dragonOwner, uint256 _dragonID, uint256 _dragonPrice, uint256 _endBlockNumber) external returns (bool);
}


contract Auction {
    function add2Auction(
        address _dragonOwner, 
        uint256 _dragonID, 
        uint256 _startPrice, 
        uint256 _step, 
        uint256 _endPrice, 
        uint256 _endBlockNumber
    ) 
        external 
        returns (bool);
}


contract DragonStats {
    function setParents(uint256 _dragonID, uint256 _parentOne, uint256 _parentTwo) external;
    function setBirthBlock(uint256 _dragonID) external;
    function incChildren(uint256 _dragonID) external;
    function setDeathBlock(uint256 _dragonID) external;
    function getDragonFight(uint256 _dragonID) external view returns (uint256);
}


contract SuperContract {
    function checkDragon(uint256 _dragonID) external returns (bool);
}


contract Mutagen2Face {
    function addDragon(address _dragonOwner, uint256 _dragonID, uint256 mutagenCount) external;
}


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
     
     
     
    return a / b;
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


library AddressUtils {

   
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
     
     
     
     
     
     
    assembly { size := extcodesize(addr) }   
    return size > 0;
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


contract ERC721Basic {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function exists(uint256 _tokenId) public view returns (bool _exists);

  function approve(address _to, uint256 _tokenId) public payable;
  function getApproved(uint256 _tokenId) public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator) public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public payable;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable;
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public payable;
}


contract ERC721Metadata is ERC721Basic {
  function name() public view returns (string _name);
  function symbol() public view returns (string _symbol);
  function tokenURI(uint256 _tokenId) external view returns (string);
}


contract ERC721BasicToken is ERC721Basic {
  using SafeMath for uint256;
  using AddressUtils for address;

   
   
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

   
  mapping (uint256 => address) internal tokenOwner;

   
  mapping (uint256 => address) internal tokenApprovals;

   
  mapping (address => uint256) internal ownedTokensCount;

   
  mapping (address => mapping (address => bool)) internal operatorApprovals;

   
  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender);
    _;
  }

   
  modifier canTransfer(uint256 _tokenId) {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    _;
  }

   
  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return ownedTokensCount[_owner];
  }

   
  function ownerOf(uint256 _tokenId) public view returns (address) {
    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

   
  function exists(uint256 _tokenId) public view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

   
  function approve(address _to, uint256 _tokenId) public payable{
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    if (getApproved(_tokenId) != address(0) || _to != address(0)) {
      tokenApprovals[_tokenId] = _to;
        if (msg.value > 0 && _to != address(0))  _to.transfer(msg.value);
        if (msg.value > 0 && _to == address(0))  owner.transfer(msg.value);
        
      emit Approval(owner, _to, _tokenId);
    }
  }

   
  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }

   
  function setApprovalForAll(address _to, bool _approved) public {
    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }

   
  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
    return operatorApprovals[_owner][_operator];
  }

   
  function transferFrom(address _from, address _to, uint256 _tokenId) public payable canTransfer(_tokenId) {
    require(_from != address(0));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);
    if (msg.value > 0) _to.transfer(msg.value);

    emit Transfer(_from, _to, _tokenId);
  }

   
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    public
    payable
    canTransfer(_tokenId)
  {
    safeTransferFrom(_from, _to, _tokenId, "");
  }

   
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public
    payable
    canTransfer(_tokenId)
  {
    transferFrom(_from, _to, _tokenId);
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

   
  function isApprovedOrOwner(address _spender, uint256 _tokenId) public view returns (bool) {
    address owner = ownerOf(_tokenId);
    return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
  }

   
  function _mint(address _to, uint256 _tokenId) internal {
    require(_to != address(0));
    addTokenTo(_to, _tokenId);
    emit Transfer(address(0), _to, _tokenId);
  }

   
  function _burn(address _owner, uint256 _tokenId) internal {
    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    emit Transfer(_owner, address(0), _tokenId);
  }

   
  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
      emit Approval(_owner, address(0), _tokenId);
    }
  }

   
  function addTokenTo(address _to, uint256 _tokenId) internal {
    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }

   
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);
  }

   
  function checkAndCallSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    internal
    returns (bool)
  {
    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}


contract ERC721Receiver {
   
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

   
  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}


contract ERC721Enumerable is ERC721Basic {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
  function tokenByIndex(uint256 _index) public view returns (uint256);
}


contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}


contract ERC721Token is ERC721, ERC721BasicToken {
   
  string internal name_;

   
  string internal symbol_;

   
  mapping (address => uint256[]) internal ownedTokens;

   
  mapping(uint256 => uint256) internal ownedTokensIndex;

   
  uint256[] internal allTokens;

   
  mapping(uint256 => uint256) internal allTokensIndex;

   
   

   
  constructor(string _name, string _symbol) public {
    name_ = _name;
    symbol_ = _symbol;
  }

   
  function name() public view returns (string) {
    return name_;
  }

   
  function symbol() public view returns (string) {
    return symbol_;
  }

   
   bytes constant firstPartURI = "https://www.dragonseth.com/image/";
    
    function tokenURI(uint256  _tokenId) external view returns (string) {
        require(exists(_tokenId));
        bytes memory tmpBytes = new bytes(96);
        uint256 i = 0;
        uint256 tokenId = _tokenId;
         
        while (tokenId != 0) {
            uint256 remainderDiv = tokenId % 10;
            tokenId = tokenId / 10;
            tmpBytes[i++] = byte(48 + remainderDiv);
        }
 
        bytes memory resaultBytes = new bytes(firstPartURI.length + i);
        
        for (uint256 j = 0; j < firstPartURI.length; j++) {
            resaultBytes[j] = firstPartURI[j];
        }
        
        i--;
        
        for (j = 0; j <= i; j++) {
            resaultBytes[j + firstPartURI.length] = tmpBytes[i - j];
        }
        
        return string(resaultBytes);
        
    }
 
   
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

   
  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  }

   
  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }

   
 
   
  function addTokenTo(address _to, uint256 _tokenId) internal {
    super.addTokenTo(_to, _tokenId);
    uint256 length = ownedTokens[_to].length;
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
  }

   
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    super.removeTokenFrom(_from, _tokenId);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;
     
     
     

    ownedTokens[_from].length--;
    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

   
  function _mint(address _to, uint256 _tokenId) internal {
    super._mint(_to, _tokenId);

    allTokensIndex[_tokenId] = allTokens.length;
    allTokens.push(_tokenId);
  }

   
  function _burn(address _owner, uint256 _tokenId) internal {
    super._burn(_owner, _tokenId);

     
 
     
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 lastTokenIndex = allTokens.length.sub(1);
    uint256 lastToken = allTokens[lastTokenIndex];

    allTokens[tokenIndex] = lastToken;
    allTokens[lastTokenIndex] = 0;

    allTokens.length--;
    allTokensIndex[_tokenId] = 0;
    allTokensIndex[lastToken] = tokenIndex;
  }
        
  function tokensOf(address _owner) external view returns (uint256[]) {
    return ownedTokens[_owner];
  }


}


contract DragonsETH_GC is RBACWithAdmin {
    GenRNG public genRNGContractAddress;
    FixMarketPlace public fmpContractAddress;
    DragonStats public dragonsStatsContract;
    Necropolis public necropolisContract;
    Auction public auctionContract;
    SuperContract public superContract;
    DragonSelectFight2Death public selectFight2DeathContract;
    DragonsRandomFight2Death public randomFight2DeathContract;
    Mutagen2Face public mutagen2FaceContract;
    
    address wallet;
    
    uint8 adultDragonStage = 3;
    bool stageThirdBegin = false;
    uint256 constant UINT256_MAX = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    uint256 public secondsInBlock = 15;
    uint256 public priceDecraseTime2Action = 0.000005 ether;  
    uint256 public priceRandomFight2Death = 0.02 ether;
    uint256 public priceSelectFight2Death = 0.03 ether;
    uint256 public priceChangeName = 0.01 ether;
    uint256 public needFightToAdult = 100;
    
    function changeGenRNGcontractAddress(address _genRNGContractAddress) external onlyAdmin {
        genRNGContractAddress = GenRNG(_genRNGContractAddress);
    }

    function changeFMPcontractAddress(address _fmpContractAddress) external onlyAdmin {
        fmpContractAddress = FixMarketPlace(_fmpContractAddress);
    }

    function changeDragonsStatsContract(address _dragonsStatsContract) external onlyAdmin {
        dragonsStatsContract = DragonStats(_dragonsStatsContract);
    }

    function changeAuctionContract(address _auctionContract) external onlyAdmin {
        auctionContract = Auction(_auctionContract);
    }

    function changeSelectFight2DeathContract(address _selectFight2DeathContract) external onlyAdmin {
        selectFight2DeathContract = DragonSelectFight2Death(_selectFight2DeathContract);
    }

    function changeRandomFight2DeathContract(address _randomFight2DeathContract) external onlyAdmin {
        randomFight2DeathContract = DragonsRandomFight2Death(_randomFight2DeathContract);
    }

    function changeMutagen2FaceContract(address _mutagen2FaceContract) external onlyAdmin {
        mutagen2FaceContract = Mutagen2Face(_mutagen2FaceContract);
    }

    function changeSuperContract(address _superContract) external onlyAdmin {
        superContract = SuperContract(_superContract);
    }

    function changeWallet(address _wallet) external onlyAdmin {
        wallet = _wallet;
    }

    function changePriceDecraseTime2Action(uint256 _priceDecraseTime2Action) external onlyAdmin {
        priceDecraseTime2Action = _priceDecraseTime2Action;
    }

    function changePriceRandomFight2Death(uint256 _priceRandomFight2Death) external onlyAdmin {
        priceRandomFight2Death = _priceRandomFight2Death;
    }

    function changePriceSelectFight2Death(uint256 _priceSelectFight2Death) external onlyAdmin {
        priceSelectFight2Death = _priceSelectFight2Death;
    }

    function changePriceChangeName(uint256 _priceChangeName) external onlyAdmin {
        priceChangeName = _priceChangeName;
    }

    function changeSecondsInBlock(uint256 _secondsInBlock) external onlyAdmin {
        secondsInBlock = _secondsInBlock;
    }
    function changeNeedFightToAdult(uint256 _needFightToAdult) external onlyAdmin {
        needFightToAdult = _needFightToAdult;
    }

    function changeAdultDragonStage(uint8 _adultDragonStage) external onlyAdmin {
        adultDragonStage = _adultDragonStage;
    }

    function setStageThirdBegin() external onlyAdmin {
        stageThirdBegin = true;
    }

    function withdrawAllEther() external onlyAdmin {
        require(wallet != 0);
        wallet.transfer(address(this).balance);
    }
    
     
    bytes4 constant ERC165_Signature = 0x01ffc9a7;
    bytes4 constant ERC721_Signature = 0x80ac58cd;
    bytes4 constant ERC721Metadata_Signature = 0x5b5e139f;
    bytes4 constant ERC721Enumerable_Signature = 0x780e9d63;
    
    function supportsInterface(bytes4 _interfaceID) external pure returns (bool) {
        return (
            (_interfaceID == ERC165_Signature) || 
            (_interfaceID == ERC721_Signature) || 
            (_interfaceID == ERC721Metadata_Signature) || 
            (_interfaceID == ERC721Enumerable_Signature)
        );
    }
}


contract ReentrancyGuard {

   
  bool private reentrancyLock = false;

   
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}


contract DragonsETH is ERC721Token("DragonsETH.com Dragon", "DragonsETH"), DragonsETH_GC, ReentrancyGuard {
    uint256 public totalDragons;
    uint256 public liveDragons;
    struct Dragon {
        uint256 gen1;
        uint8 stage;  
        uint8 currentAction;
         
        uint240 gen2;
        uint256 nextBlock2Action;
    }

    Dragon[] public dragons;
    mapping(uint256 => string) public dragonName;
    
   
    constructor(address _wallet, address _necropolisContract, address _dragonsStatsContract) public {
        
        _mint(msg.sender, 0);
        Dragon memory _dragon = Dragon({
            gen1: 0,
            stage: 0,
            currentAction: 0,
            gen2: 0,
            nextBlock2Action: UINT256_MAX
        });
        dragons.push(_dragon);
        transferFrom(msg.sender, _necropolisContract, 0);
        dragonsStatsContract = DragonStats(_dragonsStatsContract);
        necropolisContract = Necropolis(_necropolisContract);
        wallet = _wallet;
    }
   
    function add2MarketPlace(uint256 _dragonID, uint256 _dragonPrice, uint256 _endBlockNumber) external canTransfer(_dragonID)  {
        require(dragons[_dragonID].stage != 0);  
        if (dragons[_dragonID].stage >= 2) {
            checkDragonStatus(_dragonID, 2);
        }
        address dragonOwner = ownerOf(_dragonID);
        if (fmpContractAddress.add2MarketPlace(dragonOwner, _dragonID, _dragonPrice, _endBlockNumber)) {
            transferFrom(dragonOwner, fmpContractAddress, _dragonID);
        }
    }

    function add2Auction(
        uint256 _dragonID, 
        uint256 _startPrice, 
        uint256 _step, 
        uint256 _endPrice, 
        uint256 _endBlockNumber
    ) 
        external 
        canTransfer(_dragonID) 
    {
        require(dragons[_dragonID].stage != 0);  
        if (dragons[_dragonID].stage >= 2) {
            checkDragonStatus(_dragonID, 2);
        }
        address dragonOwner = ownerOf(_dragonID);
        if (auctionContract.add2Auction(dragonOwner, _dragonID, _startPrice, _step, _endPrice, _endBlockNumber)) {
            transferFrom(dragonOwner, auctionContract, _dragonID);
        }
    }
    
    function addRandomFight2Death(uint256 _dragonID) external payable nonReentrant canTransfer(_dragonID)   {
        checkDragonStatus(_dragonID, adultDragonStage);
        if (priceRandomFight2Death > 0) {
            require(msg.value >= priceRandomFight2Death);
            wallet.transfer(priceRandomFight2Death);
            if (msg.value - priceRandomFight2Death > 0) 
                msg.sender.transfer(msg.value - priceRandomFight2Death);
        } else {
            if (msg.value > 0) 
                msg.sender.transfer(msg.value);
        }
        address dragonOwner = ownerOf(_dragonID);
        transferFrom(dragonOwner, randomFight2DeathContract, _dragonID);
        randomFight2DeathContract.addRandomFight2Death(dragonOwner, _dragonID);
    }
    
    function addSelctFight2Death(uint256 _yourDragonID, uint256 _oppDragonID, uint256 _endBlockNumber) 
        external 
        payable 
        nonReentrant 
        canTransfer(_yourDragonID) 
    {
        checkDragonStatus(_yourDragonID, adultDragonStage);
        if (priceSelectFight2Death > 0) {
            require(msg.value >= priceSelectFight2Death);
            address(selectFight2DeathContract).transfer(priceSelectFight2Death);
            if (msg.value - priceSelectFight2Death > 0) msg.sender.transfer(msg.value - priceSelectFight2Death);
        } else {
            if (msg.value > 0) 
                msg.sender.transfer(msg.value);
        }
        address dragonOwner = ownerOf(_yourDragonID);
        transferFrom(dragonOwner, selectFight2DeathContract, _yourDragonID);
        selectFight2DeathContract.addSelctFight2Death(dragonOwner, _yourDragonID, _oppDragonID, _endBlockNumber, priceSelectFight2Death);
        
    }
    
    function mutagen2Face(uint256 _dragonID, uint256 _mutagenCount) external canTransfer(_dragonID)   {
        checkDragonStatus(_dragonID, 2);
        address dragonOwner = ownerOf(_dragonID);
        transferFrom(dragonOwner, mutagen2FaceContract, _dragonID);
        mutagen2FaceContract.addDragon(dragonOwner, _dragonID, _mutagenCount);
    }

    function createDragon(
        address _to, 
        uint256 _timeToBorn, 
        uint256 _parentOne, 
        uint256 _parentTwo, 
        uint256 _gen1, 
        uint240 _gen2
    ) 
        external 
        onlyRole("CreateContract") 
    {
        totalDragons++;
        liveDragons++;
        _mint(_to, totalDragons);
        uint256[2] memory twoGen;
        if (_parentOne == 0 && _parentTwo == 0 && _gen1 == 0 && _gen2 == 0) {
            twoGen = genRNGContractAddress.getNewGens(_to, totalDragons);
        } else {
            twoGen[0] = _gen1;
            twoGen[1] = uint256(_gen2);
        }
        Dragon memory _dragon = Dragon({
            gen1: twoGen[0],
            stage: 1,
            currentAction: 0,
            gen2: uint240(twoGen[1]),
            nextBlock2Action: _timeToBorn 
        });
        dragons.push(_dragon);
        if (_parentOne != 0) {
            dragonsStatsContract.setParents(totalDragons,_parentOne,_parentTwo);
            dragonsStatsContract.incChildren(_parentOne);
            dragonsStatsContract.incChildren(_parentTwo);
        }
        dragonsStatsContract.setBirthBlock(totalDragons);
    }
    
    function changeDragonGen(uint256 _dragonID, uint256 _gen, uint8 _which) external onlyRole("ChangeContract") {
        require(dragons[_dragonID].stage >= 2);  
        if (_which == 0) {
            dragons[_dragonID].gen1 = _gen;
        } else {
            dragons[_dragonID].gen2 = uint240(_gen);
        }
    }
    
    function birthDragon(uint256 _dragonID) external canTransfer(_dragonID) {
        require(dragons[_dragonID].stage != 0);  
        require(dragons[_dragonID].nextBlock2Action <= block.number);
        dragons[_dragonID].stage = 2;
    }
    
    function matureDragon(uint256 _dragonID) external canTransfer(_dragonID) {
        require(stageThirdBegin);
        checkDragonStatus(_dragonID, 2);
        require(dragonsStatsContract.getDragonFight(_dragonID) >= needFightToAdult);
        dragons[_dragonID].stage = 3;
        
    }
    
    function superDragon(uint256 _dragonID) external canTransfer(_dragonID) {
        checkDragonStatus(_dragonID, 3);
        require(superContract.checkDragon(_dragonID));
        dragons[_dragonID].stage = 4;
    }
    
    function killDragon(uint256 _dragonID) external onlyOwnerOf(_dragonID) {
        checkDragonStatus(_dragonID, 2);
        dragons[_dragonID].stage = 0;
        dragons[_dragonID].currentAction = 0xFF;
        dragons[_dragonID].nextBlock2Action = UINT256_MAX;
        necropolisContract.addDragon(ownerOf(_dragonID), _dragonID, 1);
        transferFrom(ownerOf(_dragonID), necropolisContract, _dragonID);
        dragonsStatsContract.setDeathBlock(_dragonID);
        liveDragons--;
    }
    
    function killDragonDeathContract(address _lastOwner, uint256 _dragonID, uint256 _deathReason) 
        external 
        canTransfer(_dragonID) 
        onlyRole("DeathContract") 
    {
        checkDragonStatus(_dragonID, 2);
        dragons[_dragonID].stage = 0;
        dragons[_dragonID].currentAction = 0xFF;
        dragons[_dragonID].nextBlock2Action = UINT256_MAX;
        necropolisContract.addDragon(_lastOwner, _dragonID, _deathReason);
        transferFrom(ownerOf(_dragonID), necropolisContract, _dragonID);
        dragonsStatsContract.setDeathBlock(_dragonID);
        liveDragons--;
        
    }
    
    function decraseTimeToAction(uint256 _dragonID) external payable nonReentrant canTransfer(_dragonID) {
        require(dragons[_dragonID].stage != 0);  
        require(msg.value >= priceDecraseTime2Action);
        require(dragons[_dragonID].nextBlock2Action > block.number);
        uint256 maxBlockCount = dragons[_dragonID].nextBlock2Action - block.number;
        if (msg.value > maxBlockCount * priceDecraseTime2Action) {
            msg.sender.transfer(msg.value - maxBlockCount * priceDecraseTime2Action);
            wallet.transfer(maxBlockCount * priceDecraseTime2Action);
            dragons[_dragonID].nextBlock2Action = 0;
        } else {
            if (priceDecraseTime2Action == 0) {
                dragons[_dragonID].nextBlock2Action = 0;
            } else {
                wallet.transfer(msg.value);
                dragons[_dragonID].nextBlock2Action = dragons[_dragonID].nextBlock2Action - msg.value / priceDecraseTime2Action - 1;
            }
        }
        
    }
    
    function addDragonName(uint256 _dragonID,string _newName) external payable nonReentrant canTransfer(_dragonID) {
        checkDragonStatus(_dragonID, 2);
        if (bytes(dragonName[_dragonID]).length == 0) {
            dragonName[_dragonID] = _newName;
            if (msg.value > 0) 
                msg.sender.transfer(msg.value);
        } else {
            if (priceChangeName == 0) {
                dragonName[_dragonID] = _newName;
                if (msg.value > 0) 
                    msg.sender.transfer(msg.value);
            } else {
                require(msg.value >= priceChangeName);
                wallet.transfer(priceChangeName);
                if (msg.value - priceChangeName > 0) 
                    msg.sender.transfer(msg.value - priceChangeName);
                dragonName[_dragonID] = _newName;
            }
        }
    }
    
    function checkDragonStatus(uint256 _dragonID, uint8 _stage) public view {
        require(dragons[_dragonID].stage != 0);  
         
        require(
            dragons[_dragonID].nextBlock2Action <= block.number && 
            dragons[_dragonID].currentAction == 0 && 
            dragons[_dragonID].stage >= _stage
        );
    }
    
    function setCurrentAction(uint256 _dragonID, uint8 _currentAction) external onlyRole("ActionContract") {
        dragons[_dragonID].currentAction = _currentAction;
    }
    
    function setTime2Rest(uint256 _dragonID, uint256 _addNextBlock2Action) external onlyRole("ActionContract") {
        dragons[_dragonID].nextBlock2Action = block.number + _addNextBlock2Action;
    }
}