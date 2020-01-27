 
 

pragma solidity ^0.4.20;

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

contract DataAuction is IDataAuction, AccessAdmin {
    IDataAuction public ethAuction;
    IDataAuction public platAuction;

    function DataAuction(address _ethAddr, address _platAddr) public {
        ethAuction = IDataAuction(_ethAddr);
        platAuction = IDataAuction(_platAddr);
    }

    function setEthAuction(address _ethAddr) external onlyAdmin {
        ethAuction = IDataAuction(_ethAddr);
    }

    function setPlatAuction(address _platAddr) external onlyAdmin {
        platAuction = IDataAuction(_platAddr);
    }

    function isOnSale(uint256 _tokenId) external view returns(bool) {
        if (address(ethAuction) != address(0) && ethAuction.isOnSale(_tokenId)) {
            return true;   
        }
        if (address(platAuction) != address(0) && platAuction.isOnSale(_tokenId)) {
            return true;   
        }
    }

    function isOnSaleAny2(uint256 _tokenId1, uint256 _tokenId2) external view returns(bool) {
        if (address(ethAuction) != address(0) && ethAuction.isOnSaleAny2(_tokenId1, _tokenId2)) {
            return true;   
        }
        if (address(platAuction) != address(0) && platAuction.isOnSaleAny2(_tokenId1, _tokenId2)) {
            return true;   
        }
        return false;
    }

    function isOnSaleAny3(uint256 _tokenId1, uint256 _tokenId2, uint256 _tokenId3) external view returns(bool) {
        if (address(ethAuction) != address(0) && ethAuction.isOnSaleAny3(_tokenId1, _tokenId2, _tokenId3)) {
            return true;   
        }
        if (address(platAuction) != address(0) && platAuction.isOnSaleAny3(_tokenId1, _tokenId2, _tokenId3)) {
            return true;   
        }
        return false;
    }
}