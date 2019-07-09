pragma solidity ^0.4.23;

 
contract Registry {
     
    struct Entry {
        address addr;
        bytes32 next;
        bytes32 prev;
    }
    mapping (bytes32 => Entry) public entries;

     
    address constant NO_ADDRESS = address(0);

    address public owner;
    modifier fromOwner() { require(msg.sender==owner); _; }

    event Created(uint time);
    event Registered(uint time, bytes32 name, address addr);
    event Unregistered(uint time, bytes32 name);

     
    constructor(address _owner)
        public
    {
        owner = _owner;
        emit Created(now);
    }


     
     
     

    function register(bytes32 _name, address _addr)
        fromOwner
        public
    {
        require(_name != 0 && _addr != 0);
        Entry storage entry = entries[_name];

         
        if (entry.addr == NO_ADDRESS) {
            entry.next = entries[0x0].next;
            entries[entries[0x0].next].prev = _name;
            entries[0x0].next = _name;
        }
         
        entry.addr = _addr;
        emit Registered(now, _name, _addr);
    }

    function unregister(bytes32 _name)
        fromOwner
        public
    {
        require(_name != 0);
        Entry storage entry = entries[_name];
        if (entry.addr == NO_ADDRESS) return;

         
        entries[entry.prev].next = entry.next;
        entries[entry.next].prev = entry.prev;
        delete entries[_name];
        emit Unregistered(now, _name);
    }


     
     
     

    function size()
        public
        view
        returns (uint _size)
    {
        Entry memory _curEntry = entries[0x0];
        while (_curEntry.next > 0) {
            _curEntry = entries[_curEntry.next];
            _size++;
        }
        return _size;
    }

     
    function addressOf(bytes32 _name)
        public
        view
        returns (address _addr)
    {
        _addr = entries[_name].addr;
        require(_addr != address(0));
        return _addr;
    }

     
    function nameOf(address _address)
        public
        view
        returns (bytes32 _name)
    {
        Entry memory _curEntry = entries[0x0];
        Entry memory _nextEntry;
        while (_curEntry.next > 0) {
            _nextEntry = entries[_curEntry.next];
            if (_nextEntry.addr == _address){
                return _curEntry.next;
            }
            _curEntry = _nextEntry;
        }
    }

     
    function mappings()
        public
        view
        returns (bytes32[] _names, address[] _addresses)
    {
        uint _size = size();

         
        _names = new bytes32[](_size);
        _addresses = new address[](_size);
        uint _i = 0;
        Entry memory _curEntry = entries[0x0];
        Entry memory _nextEntry;
        while (_curEntry.next > 0) {
            _nextEntry = entries[_curEntry.next];
            _names[_i] = _curEntry.next;
            _addresses[_i] = _nextEntry.addr;
            _curEntry = _nextEntry;
            _i++;
        }
        return (_names, _addresses);
    }
}