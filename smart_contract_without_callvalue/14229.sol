pragma solidity ^0.4.16;


library SafeMath {
  function mul(uint a, uint b) internal pure  returns (uint) {
    uint c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }
  function div(uint a, uint b) internal pure returns (uint) {
    require(b > 0);
    uint c = a / b;
    require(a == b * c + a % b);
    return c;
  }
  function sub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    return a - b;
  }
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a);
    return c;
  }
  function max64(uint64 a, uint64 b) internal  pure returns (uint64) {
    return a >= b ? a : b;
  }
  function min64(uint64 a, uint64 b) internal  pure returns (uint64) {
    return a < b ? a : b;
  }
  function max256(uint256 a, uint256 b) internal  pure returns (uint256) {
    return a >= b ? a : b;
  }
  function min256(uint256 a, uint256 b) internal  pure returns (uint256) {
    return a < b ? a : b;
  }
}

contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) public constant returns (uint);
  function transfer(address to, uint value) public;
  event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint);
  function transferFrom(address from, address to, uint value) public;
  function approve(address spender, uint value) public;
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract BasicToken is ERC20Basic {
  
  using SafeMath for uint;
  
  mapping(address => uint) balances;

  function transfer(address _to, uint _value) public{
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }

  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }
}


contract StandardToken is BasicToken, ERC20 {
  mapping (address => mapping (address => uint)) allowed;

  function transferFrom(address _from, address _to, uint _value) public {
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint _value) public{
    require((_value == 0) || (allowed[msg.sender][_spender] == 0)) ;
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}


contract Ownable {
    address public owner;

    function Ownable() public{
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public{
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


contract TTC is StandardToken, Ownable {
  string public constant name = "TTC";
  string public constant symbol = "TTC";
  uint public constant decimals = 18;


  function TTC() public {
      totalSupply = 1000000000000000000000000000;
      balances[msg.sender] = totalSupply;  
  }


  function burn(uint _value) onlyOwner public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Transfer(msg.sender, 0x0, _value);
    return true;
  }

}


contract CrowdsaleMain is Ownable{
    
    using SafeMath for uint;

    struct Backer {
    uint weiReceived; 
    uint coinSent;
    uint coinReadyToSend;
  }

   

   
    enum Phases {PreStart,  MainIco, AfterIco}

   
  uint public constant MAIN_MAX_CAP = 100000000000000000000000000;  

   
  uint public constant MIN_INVEST_ETHER = 100 finney;

   
  uint public constant MAIN_COIN_PER_ETHER_ICO = 4000000000000000000000;  

   

   
  uint private mainStartTime = 1524052800;   
  uint private mainEndTime = 1526644800;     

   
  TTC public coin;

   
  uint public maximumCoinsPerAddress = 50 ether;
    
   
  address public mainMultisigEther;
   
  uint public mainEtherReceived;
   
  uint public mainCoinSentToEther;

   
  mapping(address => Backer) public mainBackers;
  address[] internal mainReadyToSendAddress;

   
  mapping(address => bool) public whiteList;
  address private whiteListOwner;

     
    Phases public phase = Phases.PreStart;

   

  modifier respectTimeFrame() {
    require((now >= mainStartTime) && (now < mainEndTime ));
    _;
  }

   
  event LogReceivedETH(address addr, uint value);
  event LogCoinsEmited(address indexed from, uint amount);

   
  function CrowdsaleMain() public{
    whiteListOwner = msg.sender;
  }

   
  function setTTCAddress(address _addr) onlyOwner public {
    require(_addr != address(0));
    coin = TTC(_addr);
  }

   
  function setWhiteListOwner(address _addr) onlyOwner public {
    whiteListOwner = _addr;

  }

    
  function isExistInWhiteList(address _addr) public view returns (bool) {
    return whiteList[_addr];
  }

   
  function changeMainStartTime(uint _timestamp) onlyOwner public {

    mainStartTime = _timestamp;
  }

   
  function changeMainEndTime(uint _timestamp) onlyOwner public {
    mainEndTime = _timestamp;

  }

   
  function setMultisigMain(address _addr) onlyOwner public {
    require(_addr != address(0));
    mainMultisigEther = _addr;
  }

   
  function setMaximumCoinsPerAddress(uint _cnt) onlyOwner public{
    maximumCoinsPerAddress = _cnt;
  }

   
  function() respectTimeFrame  payable public{
    require(whiteList[msg.sender]);
    receiveETH(msg.sender);
  }

   
  function receiveETH(address _beneficiary) internal {
    require(msg.value >= MIN_INVEST_ETHER) ; 
    adjustPhaseBasedOnTime();
    uint coinToSend ;

    if (phase == Phases.MainIco){
      Backer storage mainBacker = mainBackers[_beneficiary];
      require(mainBacker.weiReceived.add(msg.value) <= maximumCoinsPerAddress);

      coinToSend = msg.value.mul(MAIN_COIN_PER_ETHER_ICO).div(1 ether);   
      require(coinToSend.add(mainCoinSentToEther) <= MAIN_MAX_CAP) ;

      mainBacker.coinSent = mainBacker.coinSent.add(coinToSend);
      mainBacker.weiReceived = mainBacker.weiReceived.add(msg.value);   
      mainBacker.coinReadyToSend = mainBacker.coinReadyToSend.add(coinToSend);
      mainReadyToSendAddress.push(_beneficiary);

       
      mainEtherReceived = mainEtherReceived.add(msg.value); 
      mainCoinSentToEther = mainCoinSentToEther.add(coinToSend);

       
      LogReceivedETH(_beneficiary, mainEtherReceived); 
    }
  }

   
    function adjustPhaseBasedOnTime() internal {

        if (now < mainStartTime ) {
            if (phase != Phases.PreStart) {
                phase = Phases.PreStart;
            }
        } else if (now >= mainStartTime && now < mainEndTime) {
            if (phase != Phases.MainIco) {
                phase = Phases.MainIco;
            }
        }else {
          if (phase != Phases.AfterIco){
            phase = Phases.AfterIco;
          }
        }
    }
  

   
  function mainSendTTC() onlyOwner public{
    for(uint i=0; i < mainReadyToSendAddress.length ; i++){
      address backerAddress = mainReadyToSendAddress[i];
      uint coinReadyToSend = mainBackers[backerAddress].coinReadyToSend;
      if ( coinReadyToSend > 0) {
        mainBackers[backerAddress].coinReadyToSend = 0;
        coin.transfer(backerAddress, coinReadyToSend);
        LogCoinsEmited(backerAddress, coinReadyToSend);
      }
    }
    delete mainReadyToSendAddress;
    require(mainMultisigEther.send(this.balance)) ; 

  }

   
  function addWhiteList(address[] _whiteList) public {
    require(msg.sender == whiteListOwner);
    for (uint i =0;i<_whiteList.length;i++){
      whiteList[_whiteList[i]] = true;
    } 
  }
   
  function removeWhiteList(address[] _whiteList) public {
    require(msg.sender == whiteListOwner);
    for (uint i =0;i<_whiteList.length;i++){
      whiteList[_whiteList[i]] = false;
    }
  }

   
  function finalize() onlyOwner public {
    adjustPhaseBasedOnTime();
    require(phase == Phases.AfterIco);
    require(this.balance > 0);
    require(mainMultisigEther.send(this.balance)) ; 
    uint remains = coin.balanceOf(this);
    if (remains > 0) { 
      coin.transfer(owner,remains);
    }
  }

   
  function backTTCOwner() onlyOwner public {
    coin.transferOwnership(owner);
  }

   
  function getMainRemainCoins() onlyOwner public {
    uint mainRemains = MAIN_MAX_CAP - mainCoinSentToEther;
    Backer storage backer = mainBackers[owner];
    coin.transfer(owner, mainRemains); 
    backer.coinSent = backer.coinSent.add(mainRemains);
    mainCoinSentToEther = mainCoinSentToEther.add(mainRemains);

    LogCoinsEmited(this ,mainRemains);
    LogReceivedETH(owner, mainEtherReceived); 
  }

   
  function refund(address _beneficiary) onlyOwner public {
    uint valueToSend = 0;
    Backer storage mainBacker = mainBackers[_beneficiary];
    if (mainBacker.coinReadyToSend > 0){ 
      uint mainValueToSend = mainBacker.coinReadyToSend.mul(1 ether).div(MAIN_COIN_PER_ETHER_ICO);
      mainBacker.coinSent = mainBacker.coinSent.sub(mainBacker.coinReadyToSend);
      mainBacker.weiReceived = mainBacker.weiReceived.sub(mainValueToSend);   
      mainEtherReceived = mainEtherReceived.sub(mainValueToSend); 
      mainCoinSentToEther = mainCoinSentToEther.sub(mainBacker.coinReadyToSend);
      mainBacker.coinReadyToSend = 0;
      valueToSend = valueToSend + mainValueToSend;

    }
    if (valueToSend > 0){
      require(_beneficiary.send(valueToSend));
    }
    
  }


     
  function refundAll() onlyOwner public {
    
    for(uint j=0; j < mainReadyToSendAddress.length ; j++){
      refund(mainReadyToSendAddress[j]);

    }

    delete mainReadyToSendAddress;

  }
  

}