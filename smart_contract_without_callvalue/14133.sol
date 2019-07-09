pragma solidity ^0.4.18;  


contract ERC20Interface {
    function transfer(address to, uint256 tokens) public returns (bool success);
}

contract Etheropoly {

    function buy(address) public payable returns(uint256);
    function transfer(address, uint256) public returns(bool);
    function myTokens() public view returns(uint256);
    function myDividends(bool) public view returns(uint256);
    function reinvest() public;
}

 
contract AcceptsEtheropoly {
    Etheropoly public tokenContract;

    function AcceptsEtheropoly(address _tokenContract) public {
        tokenContract = Etheropoly(_tokenContract);
    }

    modifier onlyTokenContract {
        require(msg.sender == address(tokenContract));
        _;
    }

     
    function tokenFallback(address _from, uint256 _value, bytes _data) external returns (bool);
}

 
contract EtheropolyShrimpFarmer is AcceptsEtheropoly {
     
    uint256 public EGGS_TO_HATCH_1SHRIMP=86400; 
    uint256 public STARTING_SHRIMP=300;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public hatcheryShrimp;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    uint256 public marketEggs;

    function EtheropolyShrimpFarmer(address _baseContract)
      AcceptsEtheropoly(_baseContract)
      public{
        ceoAddress=msg.sender;
    }

     
    function() payable public {
       
    }

     
    function tokenFallback(address _from, uint256 _value, bytes _data)
      external
      onlyTokenContract
      returns (bool) {
        require(initialized);
        require(!_isContract(_from));
        require(_value >= 1 finney);  

        uint256 EtheropolyBalance = tokenContract.myTokens();

        uint256 eggsBought=calculateEggBuy(_value, SafeMath.sub(EtheropolyBalance, _value));
        eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
        reinvest();
        tokenContract.transfer(ceoAddress, devFee(_value));
        claimedEggs[_from]=SafeMath.add(claimedEggs[_from],eggsBought);

        return true;
    }

    function hatchEggs(address ref) public{
        require(initialized);
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender){
            referrals[msg.sender]=ref;
        }
        uint256 eggsUsed=getMyEggs();
        uint256 newShrimp=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1SHRIMP);
        hatcheryShrimp[msg.sender]=SafeMath.add(hatcheryShrimp[msg.sender],newShrimp);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;

         
        claimedEggs[referrals[msg.sender]]=SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(eggsUsed,5));

         
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,10));
    }

    function sellEggs() public{
        require(initialized);
        uint256 hasEggs=getMyEggs();
        uint256 eggValue=calculateEggSell(hasEggs);
        uint256 fee=devFee(eggValue);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketEggs=SafeMath.add(marketEggs,hasEggs);
        reinvest();
        tokenContract.transfer(ceoAddress, fee);
        tokenContract.transfer(msg.sender, SafeMath.sub(eggValue,fee));
    }

     
    function seedMarket(uint256 eggs) public {
        require(marketEggs==0);
        require(msg.sender==ceoAddress);  
        initialized=true;
        marketEggs=eggs;
    }

     
     
     
    function reinvest() public {
       if(tokenContract.myDividends(true) > 1) {
         tokenContract.reinvest();
       }
    }

     
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
         
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }

     
    function calculateEggSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs,marketEggs, tokenContract.myTokens());
    }

     
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketEggs);
    }

     
    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth, tokenContract.myTokens());
    }

     
    function devFee(uint256 amount) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,4),100);
    }

     
    function getMyShrimp() public view returns(uint256){
        return hatcheryShrimp[msg.sender];
    }

     
    function getMyEggs() public view returns(uint256){
        return SafeMath.add(claimedEggs[msg.sender],getEggsSinceLastHatch(msg.sender));
    }

     
    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed=min(EGGS_TO_HATCH_1SHRIMP,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryShrimp[adr]);
    }

     
    function getContractDividends() public view returns(uint256) {
      return tokenContract.myDividends(true);  
    }

     
    function getBalance() public view returns(uint256){
        return tokenContract.myTokens();
    }

     
    function _isContract(address _user) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(_user) }
        return size > 0;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
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