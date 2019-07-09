pragma solidity ^0.4.18;  



contract EtherCartel{
     
    uint256 public DRUGS_TO_PRODUCE_1KILO=86400; 
    uint256 public STARTING_KILOS=300;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress=0x85abE8E3bed0d4891ba201Af1e212FE50bb65a26;
    mapping (address => uint256) public Kilos;
    mapping (address => uint256) public claimedDrugs;
    mapping (address => uint256) public lastCollect;
    mapping (address => address) public referrals;
    uint256 public marketDrugs;
    function DrugDealer() public{
        ceoAddress=msg.sender;
    }
    function collectDrugs(address ref) public{
        require(initialized);
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender){
            referrals[msg.sender]=ref;
        }
        uint256 drugsUsed=getMyDrugs();
        uint256 newKilo=SafeMath.div(drugsUsed,DRUGS_TO_PRODUCE_1KILO);
        Kilos[msg.sender]=SafeMath.add(Kilos[msg.sender],newKilo);
        claimedDrugs[msg.sender]=0;
        lastCollect[msg.sender]=now;
        
         
        claimedDrugs[referrals[msg.sender]]=SafeMath.add(claimedDrugs[referrals[msg.sender]],SafeMath.div(drugsUsed,5));
        
         
        marketDrugs=SafeMath.add(marketDrugs,SafeMath.div(drugsUsed,10));
    }
    function sellDrugs() public{
        require(initialized);
        uint256 hasDrugs=getMyDrugs();
        uint256 drugValue=calculateDrugSell(hasDrugs);
        uint256 fee=devFee(drugValue);
        claimedDrugs[msg.sender]=0;
        lastCollect[msg.sender]=now;
        marketDrugs=SafeMath.add(marketDrugs,hasDrugs);
        ceoAddress.transfer(fee);
        msg.sender.transfer(SafeMath.sub(drugValue,fee));
    }
    function buyDrugs() public payable{
        require(initialized);
        uint256 drugsBought=calculateDrugBuy(msg.value,SafeMath.sub(this.balance,msg.value));
        drugsBought=SafeMath.sub(drugsBought,devFee(drugsBought));
        ceoAddress.transfer(devFee(msg.value));
        claimedDrugs[msg.sender]=SafeMath.add(claimedDrugs[msg.sender],drugsBought);
    }
     
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
         
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateDrugSell(uint256 drugs) public view returns(uint256){
        return calculateTrade(drugs,marketDrugs,this.balance);
    }
    function calculateDrugBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketDrugs);
    }
    function calculateDrugBuySimple(uint256 eth) public view returns(uint256){
        return calculateDrugBuy(eth,this.balance);
    }
    function devFee(uint256 amount) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,4),100);
    }
    function seedMarket(uint256 drugs) public payable{
        require(marketDrugs==0);
        initialized=true;
        marketDrugs=drugs;
    }
    function getFreeKilo() public{
        require(initialized);
        require(Kilos[msg.sender]==0);
        lastCollect[msg.sender]=now;
        Kilos[msg.sender]=STARTING_KILOS;
    }
    function getBalance() public view returns(uint256){
        return this.balance;
    }
    function getMyKilo() public view returns(uint256){
        return Kilos[msg.sender];
    }
    function getMyDrugs() public view returns(uint256){
        return SafeMath.add(claimedDrugs[msg.sender],getDrugsSinceLastCollect(msg.sender));
    }
    function getDrugsSinceLastCollect(address adr) public view returns(uint256){
        uint256 secondsPassed=min(DRUGS_TO_PRODUCE_1KILO,SafeMath.sub(now,lastCollect[adr]));
        return SafeMath.mul(secondsPassed,Kilos[adr]);
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