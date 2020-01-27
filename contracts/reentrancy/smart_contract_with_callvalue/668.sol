pragma solidity ^0.5.0;

 
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

     
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

     
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

     
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

 

pragma solidity ^0.5.0;


 
contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

 

pragma solidity >=0.4.24;

interface ENS {

     
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

     
    event Transfer(bytes32 indexed node, address owner);

     
    event NewResolver(bytes32 indexed node, address resolver);

     
    event NewTTL(bytes32 indexed node, uint64 ttl);


    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;
    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
    function setTTL(bytes32 node, uint64 ttl) external;
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function ttl(bytes32 node) external view returns (uint64);

}

 

pragma solidity >=0.4.24;

interface Deed {

    function setOwner(address payable newOwner) external;
    function setRegistrar(address newRegistrar) external;
    function setBalance(uint newValue, bool throwOnFailure) external;
    function closeDeed(uint refundRatio) external;
    function destroyDeed() external;

    function owner() external view returns (address);
    function previousOwner() external view returns (address);
    function value() external view returns (uint);
    function creationDate() external view returns (uint);

}

 

pragma solidity ^0.5.0;


 
contract DeedImplementation is Deed {

    address payable constant burn = address(0xdead);

    address payable private _owner;
    address private _previousOwner;
    address private _registrar;

    uint private _creationDate;
    uint private _value;

    bool active;

    event OwnerChanged(address newOwner);
    event DeedClosed();

    modifier onlyRegistrar {
        require(msg.sender == _registrar);
        _;
    }

    modifier onlyActive {
        require(active);
        _;
    }

    constructor(address payable initialOwner) public payable {
        _owner = initialOwner;
        _registrar = msg.sender;
        _creationDate = now;
        active = true;
        _value = msg.value;
    }

    function setOwner(address payable newOwner) external onlyRegistrar {
        require(newOwner != address(0x0));
        _previousOwner = _owner;   
        _owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    function setRegistrar(address newRegistrar) external onlyRegistrar {
        _registrar = newRegistrar;
    }

    function setBalance(uint newValue, bool throwOnFailure) external onlyRegistrar onlyActive {
         
        require(_value >= newValue);
        _value = newValue;
         
        require(_owner.send(address(this).balance - newValue) || !throwOnFailure);
    }

     
    function closeDeed(uint refundRatio) external onlyRegistrar onlyActive {
        active = false;
        require(burn.send(((1000 - refundRatio) * address(this).balance)/1000));
        emit DeedClosed();
        _destroyDeed();
    }

     
    function destroyDeed() external {
        _destroyDeed();
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function previousOwner() external view returns (address) {
        return _previousOwner;
    }

    function value() external view returns (uint) {
        return _value;
    }

    function creationDate() external view returns (uint) {
        _creationDate;
    }

    function _destroyDeed() internal {
        require(!active);

         
         
         
        if (_owner.send(address(this).balance)) {
            selfdestruct(burn);
        }
    }
}

interface Registrar {

    enum Mode { Open, Auction, Owned, Forbidden, Reveal, NotYetAvailable }

    event AuctionStarted(bytes32 indexed hash, uint registrationDate);
    event NewBid(bytes32 indexed hash, address indexed bidder, uint deposit);
    event BidRevealed(bytes32 indexed hash, address indexed owner, uint value, uint8 status);
    event HashRegistered(bytes32 indexed hash, address indexed owner, uint value, uint registrationDate);
    event HashReleased(bytes32 indexed hash, uint value);
    event HashInvalidated(bytes32 indexed hash, string indexed name, uint value, uint registrationDate);

    function startAuction(bytes32 _hash) external;
    function startAuctions(bytes32[] calldata _hashes) external;
    function newBid(bytes32 sealedBid) external payable;
    function startAuctionsAndBid(bytes32[] calldata hashes, bytes32 sealedBid) external payable;
    function unsealBid(bytes32 _hash, uint _value, bytes32 _salt) external;
    function cancelBid(address bidder, bytes32 seal) external;
    function finalizeAuction(bytes32 _hash) external;
    function transfer(bytes32 _hash, address payable newOwner) external;
    function releaseDeed(bytes32 _hash) external;
    function invalidateName(string calldata unhashedName) external;
    function eraseNode(bytes32[] calldata labels) external;
    function transferRegistrars(bytes32 _hash) external;
    function acceptRegistrarTransfer(bytes32 hash, Deed deed, uint registrationDate) external;
    function entries(bytes32 _hash) external view returns (Mode, address, uint, uint, uint);
}

contract HashRegistrar is Registrar {
    ENS public ens;
    bytes32 public rootNode;

    mapping (bytes32 => Entry) _entries;
    mapping (address => mapping (bytes32 => Deed)) public sealedBids;

    uint32 constant totalAuctionLength = 5 days;
    uint32 constant revealPeriod = 48 hours;
    uint32 public constant launchLength = 8 weeks;

    uint constant minPrice = 0.01 ether;
    uint public registryStarted;

    struct Entry {
        Deed deed;
        uint registrationDate;
        uint value;
        uint highestBid;
    }

    modifier inState(bytes32 _hash, Mode _state) {
        require(state(_hash) == _state);
        _;
    }

    modifier onlyOwner(bytes32 _hash) {
        require(state(_hash) == Mode.Owned && msg.sender == _entries[_hash].deed.owner());
        _;
    }

    modifier registryOpen() {
        require(now >= registryStarted && now <= registryStarted + (365 * 4) * 1 days && ens.owner(rootNode) == address(this));
        _;
    }

     
    constructor(ENS _ens, bytes32 _rootNode, uint _startDate) public {
        ens = _ens;
        rootNode = _rootNode;
        registryStarted = _startDate > 0 ? _startDate : now;
    }

     
    function startAuction(bytes32 _hash) external {
        _startAuction(_hash);
    }

     
    function startAuctions(bytes32[] calldata _hashes) external {
        _startAuctions(_hashes);
    }

     
    function newBid(bytes32 sealedBid) external payable {
        _newBid(sealedBid);
    }

     
    function startAuctionsAndBid(bytes32[] calldata hashes, bytes32 sealedBid) external payable {
        _startAuctions(hashes);
        _newBid(sealedBid);
    }

     
    function unsealBid(bytes32 _hash, uint _value, bytes32 _salt) external {
        bytes32 seal = shaBid(_hash, msg.sender, _value, _salt);
        Deed bid = sealedBids[msg.sender][seal];
        require(address(bid) != address(0x0));

        sealedBids[msg.sender][seal] = Deed(address(0x0));
        Entry storage h = _entries[_hash];
        uint value = min(_value, bid.value());
        bid.setBalance(value, true);

        Mode auctionState = state(_hash);
        if (auctionState == Mode.Owned) {
             
            bid.closeDeed(5);
            emit BidRevealed(_hash, msg.sender, value, 1);
        } else if (auctionState != Mode.Reveal) {
             
            revert();
        } else if (value < minPrice || bid.creationDate() > h.registrationDate - revealPeriod) {
             
            bid.closeDeed(995);
            emit BidRevealed(_hash, msg.sender, value, 0);
        } else if (value > h.highestBid) {
             
             
            if (address(h.deed) != address(0x0)) {
                Deed previousWinner = h.deed;
                previousWinner.closeDeed(995);
            }

             
             
            h.value = h.highestBid;   
            h.highestBid = value;
            h.deed = bid;
            emit BidRevealed(_hash, msg.sender, value, 2);
        } else if (value > h.value) {
             
            h.value = value;
            bid.closeDeed(995);
            emit BidRevealed(_hash, msg.sender, value, 3);
        } else {
             
            bid.closeDeed(995);
            emit BidRevealed(_hash, msg.sender, value, 4);
        }
    }

     
    function cancelBid(address bidder, bytes32 seal) external {
        Deed bid = sealedBids[bidder][seal];

        require(address(bid) != address(0x0) && now >= bid.creationDate() + totalAuctionLength + 2 weeks);

         
        bid.setOwner(msg.sender);
        bid.closeDeed(5);
        sealedBids[bidder][seal] = Deed(0);
        emit BidRevealed(seal, bidder, 0, 5);
    }

     
    function finalizeAuction(bytes32 _hash) external onlyOwner(_hash) {
        Entry storage h = _entries[_hash];
        
         
        h.value = max(h.value, minPrice);
        h.deed.setBalance(h.value, true);

        trySetSubnodeOwner(_hash, h.deed.owner());
        emit HashRegistered(_hash, h.deed.owner(), h.value, h.registrationDate);
    }

     
    function transfer(bytes32 _hash, address payable newOwner) external onlyOwner(_hash) {
        require(newOwner != address(0x0));

        Entry storage h = _entries[_hash];
        h.deed.setOwner(newOwner);
        trySetSubnodeOwner(_hash, newOwner);
    }

     
    function releaseDeed(bytes32 _hash) external onlyOwner(_hash) {
        Entry storage h = _entries[_hash];
        Deed deedContract = h.deed;

        require(now >= h.registrationDate + 365 days || ens.owner(rootNode) != address(this));

        h.value = 0;
        h.highestBid = 0;
        h.deed = Deed(0);

        _tryEraseSingleNode(_hash);
        deedContract.closeDeed(1000);
        emit HashReleased(_hash, h.value);        
    }

     
    function invalidateName(string calldata unhashedName)
        external
        inState(keccak256(abi.encode(unhashedName)), Mode.Owned)
    {
        require(strlen(unhashedName) <= 6);
        bytes32 hash = keccak256(abi.encode(unhashedName));

        Entry storage h = _entries[hash];

        _tryEraseSingleNode(hash);

        if (address(h.deed) != address(0x0)) {
             
             
            h.value = max(h.value, minPrice);
            h.deed.setBalance(h.value/2, false);
            h.deed.setOwner(msg.sender);
            h.deed.closeDeed(1000);
        }

        emit HashInvalidated(hash, unhashedName, h.value, h.registrationDate);

        h.value = 0;
        h.highestBid = 0;
        h.deed = Deed(0);
    }

     
    function eraseNode(bytes32[] calldata labels) external {
        require(labels.length != 0);
        require(state(labels[labels.length - 1]) != Mode.Owned);

        _eraseNodeHierarchy(labels.length - 1, labels, rootNode);
    }

     
    function transferRegistrars(bytes32 _hash) external onlyOwner(_hash) {
        address registrar = ens.owner(rootNode);
        require(registrar != address(this));

         
        Entry storage h = _entries[_hash];
        h.deed.setRegistrar(registrar);

         
        Registrar(registrar).acceptRegistrarTransfer(_hash, h.deed, h.registrationDate);

         
        h.deed = Deed(0);
        h.registrationDate = 0;
        h.value = 0;
        h.highestBid = 0;
    }

     
    function acceptRegistrarTransfer(bytes32 hash, Deed deed, uint registrationDate) external {
        hash; deed; registrationDate;  
    }

    function entries(bytes32 _hash) external view returns (Mode, address, uint, uint, uint) {
        Entry storage h = _entries[_hash];
        return (state(_hash), address(h.deed), h.registrationDate, h.value, h.highestBid);
    }

    function state(bytes32 _hash) public view returns (Mode) {
        Entry storage entry = _entries[_hash];

        if (!isAllowed(_hash, now)) {
            return Mode.NotYetAvailable;
        } else if (now < entry.registrationDate) {
            if (now < entry.registrationDate - revealPeriod) {
                return Mode.Auction;
            } else {
                return Mode.Reveal;
            }
        } else {
            if (entry.highestBid == 0) {
                return Mode.Open;
            } else {
                return Mode.Owned;
            }
        }
    }

     
    function isAllowed(bytes32 _hash, uint _timestamp) public view returns (bool allowed) {
        return _timestamp > getAllowedTime(_hash);
    }

     
    function getAllowedTime(bytes32 _hash) public view returns (uint) {
        return registryStarted + ((launchLength * (uint(_hash) >> 128)) >> 128);
         
    }

     
    function shaBid(bytes32 hash, address owner, uint value, bytes32 salt) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(hash, owner, value, salt));
    }

    function _tryEraseSingleNode(bytes32 label) internal {
        if (ens.owner(rootNode) == address(this)) {
            ens.setSubnodeOwner(rootNode, label, address(this));
            bytes32 node = keccak256(abi.encodePacked(rootNode, label));
            ens.setResolver(node, address(0x0));
            ens.setOwner(node, address(0x0));
        }
    }

    function _startAuction(bytes32 _hash) internal registryOpen() {
        Mode mode = state(_hash);
        if (mode == Mode.Auction) return;
        require(mode == Mode.Open);

        Entry storage newAuction = _entries[_hash];
        newAuction.registrationDate = now + totalAuctionLength;
        newAuction.value = 0;
        newAuction.highestBid = 0;
        emit AuctionStarted(_hash, newAuction.registrationDate);
    }

    function _startAuctions(bytes32[] memory _hashes) internal {
        for (uint i = 0; i < _hashes.length; i ++) {
            _startAuction(_hashes[i]);
        }
    }

    function _newBid(bytes32 sealedBid) internal {
        require(address(sealedBids[msg.sender][sealedBid]) == address(0x0));
        require(msg.value >= minPrice);

         
        Deed bid = (new DeedImplementation).value(msg.value)(msg.sender);
        sealedBids[msg.sender][sealedBid] = bid;
        emit NewBid(sealedBid, msg.sender, msg.value);
    }

    function _eraseNodeHierarchy(uint idx, bytes32[] memory labels, bytes32 node) internal {
         
        ens.setSubnodeOwner(node, labels[idx], address(this));
        node = keccak256(abi.encodePacked(node, labels[idx]));

         
        if (idx > 0) {
            _eraseNodeHierarchy(idx - 1, labels, node);
        }

         
        ens.setResolver(node, address(0x0));
        ens.setOwner(node, address(0x0));
    }

     
    function trySetSubnodeOwner(bytes32 _hash, address _newOwner) internal {
        if (ens.owner(rootNode) == address(this))
            ens.setSubnodeOwner(rootNode, _hash, _newOwner);
    }

     
    function max(uint a, uint b) internal pure returns (uint) {
        if (a > b)
            return a;
        else
            return b;
    }

     
    function min(uint a, uint b) internal pure returns (uint) {
        if (a < b)
            return a;
        else
            return b;
    }

     
    function strlen(string memory s) internal pure returns (uint) {
         
        uint ptr;
        uint end;
        assembly {
            ptr := add(s, 1)
            end := add(mload(s), ptr)
        }
        uint len = 0;
        for (len; ptr < end; len++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if (b < 0xE0) {
                ptr += 2;
            } else if (b < 0xF0) {
                ptr += 3;
            } else if (b < 0xF8) {
                ptr += 4;
            } else if (b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
        return len;
    }

}

contract CustodialContract is WhitelistAdminRole {
    HashRegistrar registrar;

    mapping (bytes32 => Ownership) domains;

    struct Ownership {
        address primary;
        address secondary;
    }

    event NewPrimaryOwner(bytes32 indexed labelHash, address indexed owner);
    event NewSecondaryOwner(bytes32 indexed labelHash, address indexed owner);
    event DomainWithdrawal(bytes32 indexed labelHash, address indexed recipient);

    function() external payable {}
    
    constructor(address _registrar) public {
        registrar = HashRegistrar(_registrar);
    }

    modifier onlyOwner(bytes32 _labelHash) {
        require(isOwner(_labelHash));
        _;
    }

    modifier onlyTransferred(bytes32 _labelHash) {
        require(isTransferred(_labelHash));
        _;
    }

    function isTransferred(bytes32 _labelHash) public view returns (bool) {
        (, address deedAddress, , , ) = registrar.entries(_labelHash);
        Deed deed = Deed(deedAddress);

        return (deed.owner() == address(this));
    }

    function isOwner(bytes32 _labelHash) public view returns (bool) {
        return (isPrimaryOwner(_labelHash) || isSecondaryOwner(_labelHash));
    }

    function isPrimaryOwner(bytes32 _labelHash) public view returns (bool) {
        (, address deedAddress, , , ) = registrar.entries(_labelHash);
        Deed deed = Deed(deedAddress);

        if (
            domains[_labelHash].primary == address(0) &&
            deed.previousOwner() == msg.sender
        ) {
            return true;
        }
        return (domains[_labelHash].primary == msg.sender);
    }

    function isSecondaryOwner(bytes32 _labelHash) public view returns (bool) {
        return (domains[_labelHash].secondary == msg.sender);
    }

    function setPrimaryOwners(bytes32[] memory _labelHashes, address _address) public {
        for (uint i=0; i<_labelHashes.length; i++) {
            setPrimaryOwner(_labelHashes[i], _address);
        }
    }

    function setSecondaryOwners(bytes32[] memory _labelHashes, address _address) public {
        for (uint i=0; i<_labelHashes.length; i++) {
            setSecondaryOwner(_labelHashes[i], _address);
        }
    }

    function setPrimaryOwner(bytes32 _labelHash, address _address) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
        domains[_labelHash].primary = _address;
        emit NewPrimaryOwner(_labelHash, _address);
    }

    function setSecondaryOwner(bytes32 _labelHash, address _address) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
        domains[_labelHash].secondary = _address;
        emit NewSecondaryOwner(_labelHash, _address);
    }

    function setPrimaryAndSecondaryOwner(bytes32 _labelHash, address _primary, address _secondary) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
        setPrimaryOwner(_labelHash, _primary);
        setSecondaryOwner(_labelHash, _secondary);
    }

    function withdrawDomain(bytes32 _labelHash, address payable _address) public onlyTransferred(_labelHash) onlyOwner(_labelHash) {
        domains[_labelHash].primary = address(0);
        domains[_labelHash].secondary = address(0);
        registrar.transfer(_labelHash, _address);
        emit DomainWithdrawal(_labelHash, _address);
    }

    function call(address _to, bytes memory _data) public payable onlyWhitelistAdmin {
        require(_to != address(registrar));
        (bool success,) = _to.call.value(msg.value)(_data);
        require(success);
    }
}