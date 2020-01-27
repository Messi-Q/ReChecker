pragma solidity ^0.4.13;

contract AbstractENS {
    function owner(bytes32 node) constant returns(address);
    function resolver(bytes32 node) constant returns(address);
    function ttl(bytes32 node) constant returns(uint64);
    function setOwner(bytes32 node, address owner);
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner);
    function setResolver(bytes32 node, address resolver);
    function setTTL(bytes32 node, uint64 ttl);

     
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

     
    event Transfer(bytes32 indexed node, address owner);

     
    event NewResolver(bytes32 indexed node, address resolver);

     
    event NewTTL(bytes32 indexed node, uint64 ttl);
}

contract ENS is AbstractENS {
    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
    }

    mapping(bytes32=>Record) records;

     
    modifier only_owner(bytes32 node) {
        if(records[node].owner != msg.sender) throw;
        _;
    }

     
    function ENS() {
        records[0].owner = msg.sender;
    }

     
    function owner(bytes32 node) constant returns (address) {
        return records[node].owner;
    }

     
    function resolver(bytes32 node) constant returns (address) {
        return records[node].resolver;
    }

     
    function ttl(bytes32 node) constant returns (uint64) {
        return records[node].ttl;
    }

     
    function setOwner(bytes32 node, address owner) only_owner(node) {
        Transfer(node, owner);
        records[node].owner = owner;
    }

     
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) only_owner(node) {
        var subnode = sha3(node, label);
        NewOwner(node, label, owner);
        records[subnode].owner = owner;
    }

     
    function setResolver(bytes32 node, address resolver) only_owner(node) {
        NewResolver(node, resolver);
        records[node].resolver = resolver;
    }

     
    function setTTL(bytes32 node, uint64 ttl) only_owner(node) {
        NewTTL(node, ttl);
        records[node].ttl = ttl;
    }
}

contract Deed {
    address public registrar;
    address constant burn = 0xdead;
    uint public creationDate;
    address public owner;
    address public previousOwner;
    uint public value;
    event OwnerChanged(address newOwner);
    event DeedClosed();
    bool active;


    modifier onlyRegistrar {
        if (msg.sender != registrar) throw;
        _;
    }

    modifier onlyActive {
        if (!active) throw;
        _;
    }

    function Deed(address _owner) payable {
        owner = _owner;
        registrar = msg.sender;
        creationDate = now;
        active = true;
        value = msg.value;
    }

    function setOwner(address newOwner) onlyRegistrar {
        if (newOwner == 0) throw;
        previousOwner = owner;   
        owner = newOwner;
        OwnerChanged(newOwner);
    }

    function setRegistrar(address newRegistrar) onlyRegistrar {
        registrar = newRegistrar;
    }

    function setBalance(uint newValue, bool throwOnFailure) onlyRegistrar onlyActive {
         
        if (value < newValue) throw;
        value = newValue;
         
        if (!owner.send(this.balance - newValue) && throwOnFailure) throw;
    }

     
    function closeDeed(uint refundRatio) onlyRegistrar onlyActive {
        active = false;
        if (! burn.send(((1000 - refundRatio) * this.balance)/1000)) throw;
        DeedClosed();
        destroyDeed();
    }

     
    function destroyDeed() {
        if (active) throw;
        
         
         
         
        if(owner.send(this.balance)) {
            selfdestruct(burn);
        }
    }
}

contract Registrar {
    AbstractENS public ens;
    bytes32 public rootNode;

    mapping (bytes32 => entry) _entries;
    mapping (address => mapping(bytes32 => Deed)) public sealedBids;
    
    enum Mode { Open, Auction, Owned, Forbidden, Reveal, NotYetAvailable }

    uint32 constant totalAuctionLength = 5 seconds;
    uint32 constant revealPeriod = 3 seconds;
    uint32 public constant launchLength = 0 seconds;

    uint constant minPrice = 0.01 ether;
    uint public registryStarted;

    event AuctionStarted(bytes32 indexed hash, uint registrationDate);
    event NewBid(bytes32 indexed hash, address indexed bidder, uint deposit);
    event BidRevealed(bytes32 indexed hash, address indexed owner, uint value, uint8 status);
    event HashRegistered(bytes32 indexed hash, address indexed owner, uint value, uint registrationDate);
    event HashReleased(bytes32 indexed hash, uint value);
    event HashInvalidated(bytes32 indexed hash, string indexed name, uint value, uint registrationDate);

    struct entry {
        Deed deed;
        uint registrationDate;
        uint value;
        uint highestBid;
    }

     
     
     
     
     
     
    function state(bytes32 _hash) constant returns (Mode) {
        var entry = _entries[_hash];
        
        if(!isAllowed(_hash, now)) {
            return Mode.NotYetAvailable;
        } else if(now < entry.registrationDate) {
            if (now < entry.registrationDate - revealPeriod) {
                return Mode.Auction;
            } else {
                return Mode.Reveal;
            }
        } else {
            if(entry.highestBid == 0) {
                return Mode.Open;
            } else {
                return Mode.Owned;
            }
        }
    }

    modifier inState(bytes32 _hash, Mode _state) {
        if(state(_hash) != _state) throw;
        _;
    }

    modifier onlyOwner(bytes32 _hash) {
        if (state(_hash) != Mode.Owned || msg.sender != _entries[_hash].deed.owner()) throw;
        _;
    }

    modifier registryOpen() {
        if(now < registryStarted  || now > registryStarted + 4 years || ens.owner(rootNode) != address(this)) throw;
        _;
    }

    function entries(bytes32 _hash) constant returns (Mode, address, uint, uint, uint) {
        entry h = _entries[_hash];
        return (state(_hash), h.deed, h.registrationDate, h.value, h.highestBid);
    }

     
    function Registrar(AbstractENS _ens, bytes32 _rootNode, uint _startDate) {
        ens = _ens;
        rootNode = _rootNode;
        registryStarted = _startDate > 0 ? _startDate : now;
    }

     
    function max(uint a, uint b) internal constant returns (uint max) {
        if (a > b)
            return a;
        else
            return b;
    }

     
    function min(uint a, uint b) internal constant returns (uint min) {
        if (a < b)
            return a;
        else
            return b;
    }

     
    function strlen(string s) internal constant returns (uint) {
         
        uint ptr;
        uint end;
        assembly {
            ptr := add(s, 1)
            end := add(mload(s), ptr)
        }
        for (uint len = 0; ptr < end; len++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
        return len;
    }
    
     
     
    function isAllowed(bytes32 _hash, uint _timestamp) constant returns (bool allowed){
        return _timestamp > getAllowedTime(_hash);
    }

     
    function getAllowedTime(bytes32 _hash) constant returns (uint timestamp) {
        return registryStarted + (launchLength*(uint(_hash)>>128)>>128);
         
    }
     
    function trySetSubnodeOwner(bytes32 _hash, address _newOwner) internal {
        if(ens.owner(rootNode) == address(this))
            ens.setSubnodeOwner(rootNode, _hash, _newOwner);        
    }

     
    function startAuction(bytes32 _hash) registryOpen() {
        var mode = state(_hash);
        if(mode == Mode.Auction) return;
        if(mode != Mode.Open) throw;

        entry newAuction = _entries[_hash];
        newAuction.registrationDate = now + totalAuctionLength;
        newAuction.value = 0;
        newAuction.highestBid = 0;
        AuctionStarted(_hash, newAuction.registrationDate);
    }

     
    function startAuctions(bytes32[] _hashes)  {
        for (uint i = 0; i < _hashes.length; i ++ ) {
            startAuction(_hashes[i]);
        }
    }

     
    function shaBid(bytes32 hash, address owner, uint value, bytes32 salt) constant returns (bytes32 sealedBid) {
        return sha3(hash, owner, value, salt);
    }

     
    function newBid(bytes32 sealedBid) payable {
        if (address(sealedBids[msg.sender][sealedBid]) > 0 ) throw;
        if (msg.value < minPrice) throw;
         
        Deed newBid = (new Deed).value(msg.value)(msg.sender);
        sealedBids[msg.sender][sealedBid] = newBid;
        NewBid(sealedBid, msg.sender, msg.value);
    }

     
    function startAuctionsAndBid(bytes32[] hashes, bytes32 sealedBid) payable {
        startAuctions(hashes);
        newBid(sealedBid);
    }

     
    function unsealBid(bytes32 _hash, uint _value, bytes32 _salt) {
        bytes32 seal = shaBid(_hash, msg.sender, _value, _salt);
        Deed bid = sealedBids[msg.sender][seal];
        if (address(bid) == 0 ) throw;
        sealedBids[msg.sender][seal] = Deed(0);
        entry h = _entries[_hash];
        uint value = min(_value, bid.value());
        bid.setBalance(value, true);

        var auctionState = state(_hash);
        if(auctionState == Mode.Owned) {
             
            bid.closeDeed(5);
            BidRevealed(_hash, msg.sender, value, 1);
        } else if(auctionState != Mode.Reveal) {
             
            throw;
        } else if (value < minPrice || bid.creationDate() > h.registrationDate - revealPeriod) {
             
            bid.closeDeed(995);
            BidRevealed(_hash, msg.sender, value, 0);
        } else if (value > h.highestBid) {
             
             
            if(address(h.deed) != 0) {
                Deed previousWinner = h.deed;
                previousWinner.closeDeed(995);
            }

             
             
            h.value = h.highestBid;   
            h.highestBid = value;
            h.deed = bid;
            BidRevealed(_hash, msg.sender, value, 2);
        } else if (value > h.value) {
             
            h.value = value;
            bid.closeDeed(995);
            BidRevealed(_hash, msg.sender, value, 3);
        } else {
             
            bid.closeDeed(995);
            BidRevealed(_hash, msg.sender, value, 4);
        }
    }

     
    function cancelBid(address bidder, bytes32 seal) {
        Deed bid = sealedBids[bidder][seal];
        
         
         
         
         
         
         
        if (address(bid) == 0
            || now < bid.creationDate() + totalAuctionLength + 2 weeks) throw;

         
        bid.setOwner(msg.sender);
        bid.closeDeed(5);
        sealedBids[bidder][seal] = Deed(0);
        BidRevealed(seal, bidder, 0, 5);
    }

     
    function finalizeAuction(bytes32 _hash) onlyOwner(_hash) {
        entry h = _entries[_hash];
        
         
        h.value =  max(h.value, minPrice);
        h.deed.setBalance(h.value, true);

        trySetSubnodeOwner(_hash, h.deed.owner());
        HashRegistered(_hash, h.deed.owner(), h.value, h.registrationDate);
    }

     
    function transfer(bytes32 _hash, address newOwner) onlyOwner(_hash) {
        if (newOwner == 0) throw;

        entry h = _entries[_hash];
        h.deed.setOwner(newOwner);
        trySetSubnodeOwner(_hash, newOwner);
    }

     
    function releaseDeed(bytes32 _hash) onlyOwner(_hash) {
        entry h = _entries[_hash];
        Deed deedContract = h.deed;
        if(now < h.registrationDate + 1 years && ens.owner(rootNode) == address(this)) throw;

        h.value = 0;
        h.highestBid = 0;
        h.deed = Deed(0);

        _tryEraseSingleNode(_hash);
        deedContract.closeDeed(1000);
        HashReleased(_hash, h.value);        
    }

     
    function invalidateName(string unhashedName) inState(sha3(unhashedName), Mode.Owned) {
        if (strlen(unhashedName) > 6 ) throw;
        bytes32 hash = sha3(unhashedName);

        entry h = _entries[hash];

        _tryEraseSingleNode(hash);

        if(address(h.deed) != 0) {
             
             
            h.value = max(h.value, minPrice);
            h.deed.setBalance(h.value/2, false);
            h.deed.setOwner(msg.sender);
            h.deed.closeDeed(1000);
        }

        HashInvalidated(hash, unhashedName, h.value, h.registrationDate);

        h.value = 0;
        h.highestBid = 0;
        h.deed = Deed(0);
    }

     
    function eraseNode(bytes32[] labels) {
        if(labels.length == 0) throw;
        if(state(labels[labels.length - 1]) == Mode.Owned) throw;

        _eraseNodeHierarchy(labels.length - 1, labels, rootNode);
    }

    function _tryEraseSingleNode(bytes32 label) internal {
        if(ens.owner(rootNode) == address(this)) {
            ens.setSubnodeOwner(rootNode, label, address(this));
            var node = sha3(rootNode, label);
            ens.setResolver(node, 0);
            ens.setOwner(node, 0);
        }
    }

    function _eraseNodeHierarchy(uint idx, bytes32[] labels, bytes32 node) internal {
         
        ens.setSubnodeOwner(node, labels[idx], address(this));
        node = sha3(node, labels[idx]);
        
         
        if(idx > 0)
            _eraseNodeHierarchy(idx - 1, labels, node);

         
        ens.setResolver(node, 0);
        ens.setOwner(node, 0);
    }

     
    function transferRegistrars(bytes32 _hash) onlyOwner(_hash) {
        var registrar = ens.owner(rootNode);
        if(registrar == address(this))
            throw;

         
        entry h = _entries[_hash];
        h.deed.setRegistrar(registrar);

         
        Registrar(registrar).acceptRegistrarTransfer(_hash, h.deed, h.registrationDate);

         
        h.deed = Deed(0);
        h.registrationDate = 0;
        h.value = 0;
        h.highestBid = 0;
    }

     
    function acceptRegistrarTransfer(bytes32 hash, Deed deed, uint registrationDate) {}

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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Whitelist is Ownable {
  mapping(address => bool) public whitelist;
  
  event WhitelistedAddressAdded(address addr);
  event WhitelistedAddressRemoved(address addr);

   
  modifier onlyWhitelisted() {
    require(whitelist[msg.sender]);
    _;
  }

   
  function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
    if (!whitelist[addr]) {
      whitelist[addr] = true;
      WhitelistedAddressAdded(addr);
      success = true; 
    }
  }

   
  function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addAddressToWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

   
  function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
    if (whitelist[addr]) {
      whitelist[addr] = false;
      WhitelistedAddressRemoved(addr);
      success = true;
    }
  }

   
  function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (removeAddressFromWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

}

contract BedOracleV1 is Whitelist {
    struct Bid {
        uint value;
        uint reward;
        bytes32 hash;
        address owner;
    }

    Registrar internal registrar_;
    uint internal balance_;
    mapping (bytes32 => Bid) internal bids_;

    event Added(address indexed owner, bytes32 indexed shaBid, bytes8 indexed gasPrices, bytes cypherBid);
    event Finished(bytes32 indexed shaBid);
    event Forfeited(bytes32 indexed shaBid);
    event Withdrawn(address indexed to, uint value);

    function() external payable {}
    
    constructor(address _registrar) public {
        registrar_ = Registrar(_registrar);
    }

     
    function add(bytes32 _shaBid, uint reward, bytes _cypherBid, bytes8 _gasPrices)
        external payable
    {
         
        require(bids_[_shaBid].owner == 0);
        require(msg.value > 0.01 ether + reward);

         
         
         

         
        bids_[_shaBid] = Bid(
            msg.value - reward,
            reward,
            bytes32(0),
            msg.sender
        );

         
         
        emit Added(msg.sender, _shaBid, _gasPrices, _cypherBid);
    }

     
     
     
    function bid(bytes32 _shaBid) external onlyWhitelisted {
        Bid storage b = bids_[_shaBid];

        registrar_.newBid.value(b.value)(_shaBid);
    }

     
     
    function reveal(bytes32 _hash, uint _value, bytes32 _salt) external {
        bids_[keccak256(_hash, this, _value, _salt)].hash = _hash;

        registrar_.unsealBid(_hash, _value, _salt);
    }

     
    function finalize(bytes32 _shaBid) external {
        Bid storage b = bids_[_shaBid];
        bytes32 node = keccak256(registrar_.rootNode(), b.hash);
        
        registrar_.finalizeAuction(b.hash);

         
        ENS(registrar_.ens()).setResolver(node, address(0));

        registrar_.transfer(b.hash, b.owner);

         
        b.value = 0;

         
        balance_ += b.reward;
        b.reward = 0;

        emit Finished(_shaBid);
    }

    function forfeit(bytes32 _shaBid) external onlyWhitelisted {
        Bid storage b = bids_[_shaBid];

         
         
        require(registrar_.state(b.hash) == Registrar.Mode.Owned);

         
        b.owner.transfer(b.value);
        b.value = 0;

         
        balance_ += b.reward;
        b.reward = 0;

        emit Forfeited(_shaBid);
    }

    function getBid(bytes32 _shaBid)
        external view returns (uint, uint, bytes32, address)
    {
        Bid storage b = bids_[_shaBid];
        return (b.value, b.reward, b.hash, b.owner);
    }

    function setRegistrar(address _newRegistrar) external onlyOwner {
        registrar_ = Registrar(_newRegistrar);
    }

     
    function withdraw() external onlyWhitelisted {
        msg.sender.transfer(balance_);
        emit Withdrawn(msg.sender, balance_);
        balance_ = 0;
    }
}