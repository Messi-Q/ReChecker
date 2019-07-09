 
 

pragma solidity ^0.4.20;

 
 
interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

 
 
contract ERC721 is ERC165 {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function approve(address _approved, uint256 _tokenId) external;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

 
interface ERC721TokenReceiver {
	function onERC721Received(address _from, uint256 _tokenId, bytes data) external returns(bytes4);
}

contract AccessAdmin {
    bool public isPaused = false;
    address public addrAdmin;  

    event AdminTransferred(address indexed preAdmin, address indexed newAdmin);

    function AccessAdmin() public {
        addrAdmin = msg.sender;
    }  


    modifier onlyAdmin() {
        require(msg.sender == addrAdmin);
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused);
        _;
    }

    modifier whenPaused {
        require(isPaused);
        _;
    }

    function setAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0));
        AdminTransferred(addrAdmin, _newAdmin);
        addrAdmin = _newAdmin;
    }

    function doPause() external onlyAdmin whenNotPaused {
        isPaused = true;
    }

    function doUnpause() external onlyAdmin whenPaused {
        isPaused = false;
    }
}

contract AccessService is AccessAdmin {
    address public addrService;
    address public addrFinance;

    modifier onlyService() {
        require(msg.sender == addrService);
        _;
    }

    modifier onlyFinance() {
        require(msg.sender == addrFinance);
        _;
    }

    function setService(address _newService) external {
        require(msg.sender == addrService || msg.sender == addrAdmin);
        require(_newService != address(0));
        addrService = _newService;
    }

    function setFinance(address _newFinance) external {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        require(_newFinance != address(0));
        addrFinance = _newFinance;
    }

    function withdraw(address _target, uint256 _amount) 
        external 
    {
        require(msg.sender == addrFinance || msg.sender == addrAdmin);
        require(_amount > 0);
        address receiver = _target == address(0) ? addrFinance : _target;
        uint256 balance = this.balance;
        if (_amount < balance) {
            receiver.transfer(_amount);
        } else {
            receiver.transfer(this.balance);
        }      
    }
}

interface IDataMining {
    function getRecommender(address _target) external view returns(address);
    function subFreeMineral(address _target) external returns(bool);
}


interface IDataEquip {
    function isEquiped(address _target, uint256 _tokenId) external view returns(bool);
    function isEquipedAny2(address _target, uint256 _tokenId1, uint256 _tokenId2) external view returns(bool);
    function isEquipedAny3(address _target, uint256 _tokenId1, uint256 _tokenId2, uint256 _tokenId3) external view returns(bool);
}

interface IDataAuction {
    function isOnSale(uint256 _tokenId) external view returns(bool);
    function isOnSaleAny2(uint256 _tokenId1, uint256 _tokenId2) external view returns(bool);
    function isOnSaleAny3(uint256 _tokenId1, uint256 _tokenId2, uint256 _tokenId3) external view returns(bool);
}

interface IBitGuildToken {
    function transfer(address _to, uint256 _value) external;
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external; 
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) external returns (bool);
    function balanceOf(address _from) external view returns(uint256);
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
         
        uint256 c = a / b;
         
        return c;
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

contract WarToken is ERC721, AccessAdmin {
     
    struct Fashion {
        uint16 protoId;      
        uint16 quality;      
        uint16 pos;          
        uint16 health;       
        uint16 atkMin;       
        uint16 atkMax;       
        uint16 defence;      
        uint16 crit;         
        uint16 isPercent;    
        uint16 attrExt1;     
        uint16 attrExt2;     
        uint16 attrExt3;     
    }

     
    Fashion[] public fashionArray;

     
    uint256 destroyFashionCount;

     
    mapping (uint256 => address) fashionIdToOwner;

     
    mapping (address => uint256[]) ownerToFashionArray;

     
    mapping (uint256 => uint256) fashionIdToOwnerIndex;

     
    mapping (uint256 => address) fashionIdToApprovals;

     
    mapping (address => mapping (address => bool)) operatorToApprovals;

     
    mapping (address => bool) actionContracts;

    function setActionContract(address _actionAddr, bool _useful) external onlyAdmin {
        actionContracts[_actionAddr] = _useful;
    }

    function getActionContract(address _actionAddr) external view onlyAdmin returns(bool) {
        return actionContracts[_actionAddr];
    }

     
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

     
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

     
    event Transfer(address indexed from, address indexed to, uint256 tokenId);

     
    event CreateFashion(address indexed owner, uint256 tokenId, uint16 protoId, uint16 quality, uint16 pos, uint16 createType);

     
    event ChangeFashion(address indexed owner, uint256 tokenId, uint16 changeType);

     
    event DeleteFashion(address indexed owner, uint256 tokenId, uint16 deleteType);
    
    function WarToken() public {
        addrAdmin = msg.sender;
        fashionArray.length += 1;
    }

     
     
    modifier isValidToken(uint256 _tokenId) {
        require(_tokenId >= 1 && _tokenId <= fashionArray.length);
        require(fashionIdToOwner[_tokenId] != address(0)); 
        _;
    }

    modifier canTransfer(uint256 _tokenId) {
        address owner = fashionIdToOwner[_tokenId];
        require(msg.sender == owner || msg.sender == fashionIdToApprovals[_tokenId] || operatorToApprovals[owner][msg.sender]);
        _;
    }

     
    function supportsInterface(bytes4 _interfaceId) external view returns(bool) {
         
        return (_interfaceId == 0x01ffc9a7 || _interfaceId == 0x80ac58cd || _interfaceId == 0x8153916a) && (_interfaceId != 0xffffffff);
    }
        
    function name() public pure returns(string) {
        return "WAR Token";
    }

    function symbol() public pure returns(string) {
        return "WAR";
    }

     
     
     
    function balanceOf(address _owner) external view returns(uint256) {
        require(_owner != address(0));
        return ownerToFashionArray[_owner].length;
    }

     
     
     
    function ownerOf(uint256 _tokenId) external view   returns (address owner) {
        return fashionIdToOwner[_tokenId];
    }

     
     
     
     
     
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) 
        external
        whenNotPaused
    {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

     
     
     
     
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) 
        external
        whenNotPaused
    {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

     
     
     
     
    function transferFrom(address _from, address _to, uint256 _tokenId)
        external
        whenNotPaused
        isValidToken(_tokenId)
        canTransfer(_tokenId)
    {
        address owner = fashionIdToOwner[_tokenId];
        require(owner != address(0));
        require(_to != address(0));
        require(owner == _from);
        
        _transfer(_from, _to, _tokenId);
    }

     
     
     
    function approve(address _approved, uint256 _tokenId)
        external
        whenNotPaused
    {
        address owner = fashionIdToOwner[_tokenId];
        require(owner != address(0));
        require(msg.sender == owner || operatorToApprovals[owner][msg.sender]);

        fashionIdToApprovals[_tokenId] = _approved;
        Approval(owner, _approved, _tokenId);
    }

     
     
     
    function setApprovalForAll(address _operator, bool _approved) 
        external 
        whenNotPaused
    {
        operatorToApprovals[msg.sender][_operator] = _approved;
        ApprovalForAll(msg.sender, _operator, _approved);
    }

     
     
     
    function getApproved(uint256 _tokenId) external view isValidToken(_tokenId) returns (address) {
        return fashionIdToApprovals[_tokenId];
    }

     
     
     
     
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operatorToApprovals[_owner][_operator];
    }

     
     
     
    function totalSupply() external view returns (uint256) {
        return fashionArray.length - destroyFashionCount - 1;
    }

     
     
     
     
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        if (_from != address(0)) {
            uint256 indexFrom = fashionIdToOwnerIndex[_tokenId];
            uint256[] storage fsArray = ownerToFashionArray[_from];
            require(fsArray[indexFrom] == _tokenId);

             
            if (indexFrom != fsArray.length - 1) {
                uint256 lastTokenId = fsArray[fsArray.length - 1];
                fsArray[indexFrom] = lastTokenId; 
                fashionIdToOwnerIndex[lastTokenId] = indexFrom;
            }
            fsArray.length -= 1; 
            
            if (fashionIdToApprovals[_tokenId] != address(0)) {
                delete fashionIdToApprovals[_tokenId];
            }      
        }

         
        fashionIdToOwner[_tokenId] = _to;
        ownerToFashionArray[_to].push(_tokenId);
        fashionIdToOwnerIndex[_tokenId] = ownerToFashionArray[_to].length - 1;
        
        Transfer(_from != address(0) ? _from : this, _to, _tokenId);
    }

     
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) 
        internal
        isValidToken(_tokenId) 
        canTransfer(_tokenId)
    {
        address owner = fashionIdToOwner[_tokenId];
        require(owner != address(0));
        require(_to != address(0));
        require(owner == _from);
        
        _transfer(_from, _to, _tokenId);

         
        uint256 codeSize;
        assembly { codeSize := extcodesize(_to) }
        if (codeSize == 0) {
            return;
        }
        bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(_from, _tokenId, data);
         
        require(retval == 0xf0b9e5ba);
    }

     

     
     
     
     
    function createFashion(address _owner, uint16[9] _attrs, uint16 _createType) 
        external 
        whenNotPaused
        returns(uint256)
    {
        require(actionContracts[msg.sender]);
        require(_owner != address(0));

        uint256 newFashionId = fashionArray.length;
        require(newFashionId < 4294967296);

        fashionArray.length += 1;
        Fashion storage fs = fashionArray[newFashionId];
        fs.protoId = _attrs[0];
        fs.quality = _attrs[1];
        fs.pos = _attrs[2];
        if (_attrs[3] != 0) {
            fs.health = _attrs[3];
        }
        
        if (_attrs[4] != 0) {
            fs.atkMin = _attrs[4];
            fs.atkMax = _attrs[5];
        }
       
        if (_attrs[6] != 0) {
            fs.defence = _attrs[6];
        }
        
        if (_attrs[7] != 0) {
            fs.crit = _attrs[7];
        }

        if (_attrs[8] != 0) {
            fs.isPercent = _attrs[8];
        }
        
        _transfer(0, _owner, newFashionId);
        CreateFashion(_owner, newFashionId, _attrs[0], _attrs[1], _attrs[2], _createType);
        return newFashionId;
    }

     
    function _changeAttrByIndex(Fashion storage _fs, uint16 _index, uint16 _val) internal {
        if (_index == 3) {
            _fs.health = _val;
        } else if(_index == 4) {
            _fs.atkMin = _val;
        } else if(_index == 5) {
            _fs.atkMax = _val;
        } else if(_index == 6) {
            _fs.defence = _val;
        } else if(_index == 7) {
            _fs.crit = _val;
        } else if(_index == 9) {
            _fs.attrExt1 = _val;
        } else if(_index == 10) {
            _fs.attrExt2 = _val;
        } else if(_index == 11) {
            _fs.attrExt3 = _val;
        }
    }

     
     
     
     
     
    function changeFashionAttr(uint256 _tokenId, uint16[4] _idxArray, uint16[4] _params, uint16 _changeType) 
        external 
        whenNotPaused
        isValidToken(_tokenId) 
    {
        require(actionContracts[msg.sender]);

        Fashion storage fs = fashionArray[_tokenId];
        if (_idxArray[0] > 0) {
            _changeAttrByIndex(fs, _idxArray[0], _params[0]);
        }

        if (_idxArray[1] > 0) {
            _changeAttrByIndex(fs, _idxArray[1], _params[1]);
        }

        if (_idxArray[2] > 0) {
            _changeAttrByIndex(fs, _idxArray[2], _params[2]);
        }

        if (_idxArray[3] > 0) {
            _changeAttrByIndex(fs, _idxArray[3], _params[3]);
        }

        ChangeFashion(fashionIdToOwner[_tokenId], _tokenId, _changeType);
    }

     
     
     
    function destroyFashion(uint256 _tokenId, uint16 _deleteType)
        external 
        whenNotPaused
        isValidToken(_tokenId) 
    {
        require(actionContracts[msg.sender]);

        address _from = fashionIdToOwner[_tokenId];
        uint256 indexFrom = fashionIdToOwnerIndex[_tokenId];
        uint256[] storage fsArray = ownerToFashionArray[_from]; 
        require(fsArray[indexFrom] == _tokenId);

        if (indexFrom != fsArray.length - 1) {
            uint256 lastTokenId = fsArray[fsArray.length - 1];
            fsArray[indexFrom] = lastTokenId; 
            fashionIdToOwnerIndex[lastTokenId] = indexFrom;
        }
        fsArray.length -= 1; 

        fashionIdToOwner[_tokenId] = address(0);
        delete fashionIdToOwnerIndex[_tokenId];
        destroyFashionCount += 1;

        Transfer(_from, 0, _tokenId);

        DeleteFashion(_from, _tokenId, _deleteType);
    }

     
    function safeTransferByContract(uint256 _tokenId, address _to) 
        external
        whenNotPaused
    {
        require(actionContracts[msg.sender]);

        require(_tokenId >= 1 && _tokenId <= fashionArray.length);
        address owner = fashionIdToOwner[_tokenId];
        require(owner != address(0));
        require(_to != address(0));
        require(owner != _to);

        _transfer(owner, _to, _tokenId);
    }

     

     
    function getFashion(uint256 _tokenId) external view isValidToken(_tokenId) returns (uint16[12] datas) {
        Fashion storage fs = fashionArray[_tokenId];
        datas[0] = fs.protoId;
        datas[1] = fs.quality;
        datas[2] = fs.pos;
        datas[3] = fs.health;
        datas[4] = fs.atkMin;
        datas[5] = fs.atkMax;
        datas[6] = fs.defence;
        datas[7] = fs.crit;
        datas[8] = fs.isPercent;
        datas[9] = fs.attrExt1;
        datas[10] = fs.attrExt2;
        datas[11] = fs.attrExt3;
    }

     
    function getOwnFashions(address _owner) external view returns(uint256[] tokens, uint32[] flags) {
        require(_owner != address(0));
        uint256[] storage fsArray = ownerToFashionArray[_owner];
        uint256 length = fsArray.length;
        tokens = new uint256[](length);
        flags = new uint32[](length);
        for (uint256 i = 0; i < length; ++i) {
            tokens[i] = fsArray[i];
            Fashion storage fs = fashionArray[fsArray[i]];
            flags[i] = uint32(uint32(fs.protoId) * 100 + uint32(fs.quality) * 10 + fs.pos);
        }
    }

     
    function getFashionsAttrs(uint256[] _tokens) external view returns(uint16[] attrs) {
        uint256 length = _tokens.length;
        require(length <= 64);
        attrs = new uint16[](length * 11);
        uint256 tokenId;
        uint256 index;
        for (uint256 i = 0; i < length; ++i) {
            tokenId = _tokens[i];
            if (fashionIdToOwner[tokenId] != address(0)) {
                index = i * 11;
                Fashion storage fs = fashionArray[tokenId];
                attrs[index] = fs.health;
                attrs[index + 1] = fs.atkMin;
                attrs[index + 2] = fs.atkMax;
                attrs[index + 3] = fs.defence;
                attrs[index + 4] = fs.crit;
                attrs[index + 5] = fs.isPercent;
                attrs[index + 6] = fs.attrExt1;
                attrs[index + 7] = fs.attrExt2;
                attrs[index + 8] = fs.attrExt3;
            }   
        }
    }
}

contract ActionAuctionPlat is AccessService {
    using SafeMath for uint256; 

    event AuctionPlatCreate(uint256 indexed index, address indexed seller, uint256 tokenId);
    event AuctionPlatSold(uint256 indexed index, address indexed seller, address indexed buyer, uint256 tokenId, uint256 price);
    event AuctionPlatCancel(uint256 indexed index, address indexed seller, uint256 tokenId);
    event AuctionPlatPriceChange(uint256 indexed index, address indexed seller, uint256 tokenId, uint64 platVal);

    struct Auction {
        address seller;      
        uint64 tokenId;      
        uint64 price;        
        uint64 tmStart;      
        uint64 tmSell;       
    }

     
    Auction[] public auctionArray;
     
    mapping(uint256 => uint256) public latestAction;
     
    WarToken public tokenContract;
     
    IDataEquip public equipContract;
     
    IBitGuildToken public bitGuildContract;
     
    IDataAuction public ethAuction;
     
    uint64 public searchStartIndex;
     
    uint64 public auctionDuration = 172800;
     
    uint64 public auctionSumPlat;

    function ActionAuctionPlat(address _nftAddr, address _platAddr) public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;

        tokenContract = WarToken(_nftAddr);

        Auction memory order = Auction(0, 0, 0, 1, 1);
        auctionArray.push(order);

        bitGuildContract = IBitGuildToken(_platAddr);
    }

    function() external {}

    function setDataEquip(address _addr) external onlyAdmin {
        require(_addr != address(0));
        equipContract = IDataEquip(_addr);
    }

    function setEthAuction(address _addr) external onlyAdmin {
        require(_addr != address(0));
        ethAuction = IDataAuction(_addr);
    }

    function setDuration(uint64 _duration) external onlyAdmin {
        require(_duration >= 300 && _duration <= 8640000);
        auctionDuration = _duration;
    }

    function newAuction(uint256 _tokenId, uint64 _pricePlat) 
        external
        whenNotPaused
    {
        require(tokenContract.ownerOf(_tokenId) == msg.sender);
        require(!equipContract.isEquiped(msg.sender, _tokenId));
        require(_pricePlat >= 1 && _pricePlat <= 999999);

        uint16[12] memory fashion = tokenContract.getFashion(_tokenId);
        require(fashion[1] > 1);

        uint64 tmNow = uint64(block.timestamp);
        uint256 lastIndex = latestAction[_tokenId];
        if (lastIndex > 0) {
            Auction memory oldOrder = auctionArray[lastIndex];
            require((oldOrder.tmStart + auctionDuration) <= tmNow || oldOrder.tmSell > 0);
        }

        if (address(ethAuction) != address(0)) {
            require(!ethAuction.isOnSale(_tokenId));
        }

        uint256 newAuctionIndex = auctionArray.length;
        auctionArray.length += 1;
        Auction storage order = auctionArray[newAuctionIndex];
        order.seller = msg.sender;
        order.tokenId = uint64(_tokenId);
        order.price = _pricePlat;
        uint64 lastActionStart = auctionArray[newAuctionIndex - 1].tmStart;
        if (tmNow >= lastActionStart) {
            order.tmStart = tmNow;
        } else {
            order.tmStart = lastActionStart;
        }
        
        latestAction[_tokenId] = newAuctionIndex;

        AuctionPlatCreate(newAuctionIndex, msg.sender, _tokenId);
    }

    function cancelAuction(uint256 _tokenId) external whenNotPaused {
        require(tokenContract.ownerOf(_tokenId) == msg.sender);
        uint256 lastIndex = latestAction[_tokenId];
        require(lastIndex > 0);
        Auction storage order = auctionArray[lastIndex];
        require(order.seller == msg.sender);
        require(order.tmSell == 0);
        order.tmSell = 1;
        AuctionPlatCancel(lastIndex, msg.sender, _tokenId);
    }

    function changePrice(uint256 _tokenId, uint64 _pricePlat) external whenNotPaused {
        require(tokenContract.ownerOf(_tokenId) == msg.sender);
        uint256 lastIndex = latestAction[_tokenId];
        require(lastIndex > 0);
        Auction storage order = auctionArray[lastIndex];
        require(order.seller == msg.sender);
        require(order.tmSell == 0);

        uint64 tmNow = uint64(block.timestamp);
        require(order.tmStart + auctionDuration > tmNow);
        
        require(_pricePlat >= 1 && _pricePlat <= 999999);
        order.price = _pricePlat;

        AuctionPlatPriceChange(lastIndex, msg.sender, _tokenId, _pricePlat);
    }

    function _bid(address _sender, uint256 _platVal, uint256 _tokenId) internal {
        uint256 lastIndex = latestAction[_tokenId];
        require(lastIndex > 0);
        Auction storage order = auctionArray[lastIndex];

        uint64 tmNow = uint64(block.timestamp);
        require(order.tmStart + auctionDuration > tmNow);
        require(order.tmSell == 0);

        address realOwner = tokenContract.ownerOf(_tokenId);
        require(realOwner == order.seller);
        require(realOwner != _sender);

        uint256 price = (uint256(order.price)).mul(1000000000000000000);
        require(price == _platVal);

        require(bitGuildContract.transferFrom(_sender, address(this), _platVal));
        order.tmSell = tmNow;
        auctionSumPlat += order.price;
        uint256 sellerProceeds = price.mul(9).div(10);
        tokenContract.safeTransferByContract(_tokenId, _sender);
        bitGuildContract.transfer(realOwner, sellerProceeds);

        AuctionPlatSold(lastIndex, realOwner, _sender, _tokenId, price);
    }

    function _getTokenIdFromBytes(bytes _extraData) internal pure returns(uint256) {
        uint256 val = 0;
        uint256 index = 0;
        uint256 length = _extraData.length;
        while (index < length) {
            val += (uint256(_extraData[index]) * (256 ** (length - index - 1)));
            index += 1;
        }
        return val;
    }

    function receiveApproval(address _sender, uint256 _value, address _tokenContract, bytes _extraData) 
        external 
        whenNotPaused 
    {
        require(msg.sender == address(bitGuildContract));
        require(_extraData.length <= 8);
        uint256 tokenId = _getTokenIdFromBytes(_extraData);
        _bid(_sender, _value, tokenId);
    }

    function _getStartIndex(uint64 startIndex) internal view returns(uint64) {
         
        uint64 tmFind = uint64(block.timestamp) - auctionDuration;
        uint64 first = startIndex;
        uint64 middle;
        uint64 half;
        uint64 len = uint64(auctionArray.length - startIndex);

        while(len > 0) {
            half = len / 2;
            middle = first + half;
            if (auctionArray[middle].tmStart < tmFind) {
                first = middle + 1;
                len = len - half - 1;
            } else {
                len = half;
            }
        }
        return first;
    }

    function resetSearchStartIndex () internal {
        searchStartIndex = _getStartIndex(searchStartIndex);
    }
    
    function _getAuctionIdArray(uint64 _startIndex, uint64 _count) 
        internal 
        view 
        returns(uint64[])
    {
        uint64 tmFind = uint64(block.timestamp) - auctionDuration;
        uint64 start = _startIndex > 0 ? _startIndex : _getStartIndex(0);
        uint256 length = auctionArray.length;
        uint256 maxLen = _count > 0 ? _count : length - start;
        if (maxLen == 0) {
            maxLen = 1;
        }
        uint64[] memory auctionIdArray = new uint64[](maxLen);
        uint64 counter = 0;
        for (uint64 i = start; i < length; ++i) {
            if (auctionArray[i].tmStart > tmFind && auctionArray[i].tmSell == 0) {
                auctionIdArray[counter++] = i;
                if (_count > 0 && counter == _count) {
                    break;
                }
            }
        }
        if (counter == auctionIdArray.length) {
            return auctionIdArray;
        } else {
            uint64[] memory realIdArray = new uint64[](counter);
            for (uint256 j = 0; j < counter; ++j) {
                realIdArray[j] = auctionIdArray[j];
            }
            return realIdArray;
        }
    } 

    function getAuctionIdArray(uint64 _startIndex, uint64 _count) external view returns(uint64[]) {
        return _getAuctionIdArray(_startIndex, _count);
    }
    
    function getAuctionArray(uint64 _startIndex, uint64 _count) 
        external 
        view 
        returns(
        uint64[] auctionIdArray, 
        address[] sellerArray, 
        uint64[] tokenIdArray, 
        uint64[] priceArray, 
        uint64[] tmStartArray)
    {
        auctionIdArray = _getAuctionIdArray(_startIndex, _count);
        uint256 length = auctionIdArray.length;
        sellerArray = new address[](length);
        tokenIdArray = new uint64[](length);
        priceArray = new uint64[](length);
        tmStartArray = new uint64[](length);
        
        for (uint256 i = 0; i < length; ++i) {
            Auction storage tmpAuction = auctionArray[auctionIdArray[i]];
            sellerArray[i] = tmpAuction.seller;
            tokenIdArray[i] = tmpAuction.tokenId;
            priceArray[i] = tmpAuction.price;
            tmStartArray[i] = tmpAuction.tmStart; 
        }
    } 

    function getAuction(uint64 auctionId) external view returns(
        address seller,
        uint64 tokenId,
        uint64 price,
        uint64 tmStart,
        uint64 tmSell) 
    {
        require (auctionId < auctionArray.length); 
        Auction memory auction = auctionArray[auctionId];
        seller = auction.seller;
        tokenId = auction.tokenId;
        price = auction.price;
        tmStart = auction.tmStart;
        tmSell = auction.tmSell;
    }

    function getAuctionTotal() external view returns(uint256) {
        return auctionArray.length;
    }

    function getStartIndex(uint64 _startIndex) external view returns(uint256) {
        require (_startIndex < auctionArray.length);
        return _getStartIndex(_startIndex);
    }

    function isOnSale(uint256 _tokenId) external view returns(bool) {
        uint256 lastIndex = latestAction[_tokenId];
        if (lastIndex > 0) {
            Auction storage order = auctionArray[lastIndex];
            uint64 tmNow = uint64(block.timestamp);
            if ((order.tmStart + auctionDuration > tmNow) && order.tmSell == 0) {
                return true;
            }
        }
        return false;
    }

    function isOnSaleAny2(uint256 _tokenId1, uint256 _tokenId2) external view returns(bool) {
        uint256 lastIndex = latestAction[_tokenId1];
        uint64 tmNow = uint64(block.timestamp);
        if (lastIndex > 0) {
            Auction storage order1 = auctionArray[lastIndex];
            if ((order1.tmStart + auctionDuration > tmNow) && order1.tmSell == 0) {
                return true;
            }
        }
        lastIndex = latestAction[_tokenId2];
        if (lastIndex > 0) {
            Auction storage order2 = auctionArray[lastIndex];
            if ((order2.tmStart + auctionDuration > tmNow) && order2.tmSell == 0) {
                return true;
            }
        }
        return false;
    }

    function isOnSaleAny3(uint256 _tokenId1, uint256 _tokenId2, uint256 _tokenId3) external view returns(bool) {
        uint256 lastIndex = latestAction[_tokenId1];
        uint64 tmNow = uint64(block.timestamp);
        if (lastIndex > 0) {
            Auction storage order1 = auctionArray[lastIndex];
            if ((order1.tmStart + auctionDuration > tmNow) && order1.tmSell == 0) {
                return true;
            }
        }
        lastIndex = latestAction[_tokenId2];
        if (lastIndex > 0) {
            Auction storage order2 = auctionArray[lastIndex];
            if ((order2.tmStart + auctionDuration > tmNow) && order2.tmSell == 0) {
                return true;
            }
        }
        lastIndex = latestAction[_tokenId3];
        if (lastIndex > 0) {
            Auction storage order3 = auctionArray[lastIndex];
            if ((order3.tmStart + auctionDuration > tmNow) && order3.tmSell == 0) {
                return true;
            }
        }
        return false;
    }
}