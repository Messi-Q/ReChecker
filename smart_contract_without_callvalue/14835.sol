pragma solidity ^0.4.11;

contract Factory {
  address developer = 0x007C67F0CDBea74592240d492Aef2a712DAFa094c3;
  
  event ContractCreated(address creator, address newcontract, uint timestamp, string contract_type);
    
  function setDeveloper(address _dev) {
    if(developer==address(0) || developer==msg.sender){
       developer = _dev;
    }
  }
  
  function createContract (bool isbroker, string contract_type) {
    address newContract = new Broker(isbroker, developer, msg.sender);
    ContractCreated(msg.sender, newContract, block.timestamp, contract_type);
  } 
}

contract Broker {
  enum State { Created, Validated, Locked, Finished }
  State public state;

  enum FileState { 
    Created, 
    Invalidated
     
  }

  struct File{
     
     
     
    bytes32 purpose;
     
    string name;
     
    string ipfshash;
    FileState state;
  }

  struct Item{
    string name;
     
    uint   price;
     
    string detail;
    File[] documents;
  }

  Item public item;
  address public seller;
  address public buyer;
  address public broker;
  uint    public brokerFee;
   
  uint    public developerfee = 0.1 finney;
  uint    minimumdeveloperfee = 0.1 finney;
  address developer = 0x007C67F0CDBea74592240d492Aef2a712DAFa094c3;
   
  address creator = 0x0;
  address factory = 0x0;


  modifier onlyBuyer() {
    require(msg.sender == buyer);
    _;
  }

  modifier onlySeller() {
    require(msg.sender == seller);
    _;
  }

  modifier onlyCreator() {
    require(msg.sender == creator);
    _;
  }

  modifier onlyBroker() {
    require(msg.sender == broker);
    _;
  }

  modifier inState(State _state) {
      require(state == _state);
      _;
  }

  modifier condition(bool _condition) {
      require(_condition);
      _;
  }

  event AbortedBySeller();
  event AbortedByBroker();
  event PurchaseConfirmed();
  event ItemReceived();
  event Validated();
  event ItemInfoChanged(string name, uint price, string detail, uint developerfee);
  event SellerChanged(address seller);
  event BrokerChanged(address broker);
  event BrokerFeeChanged(uint fee);

   
  function Broker(bool isbroker, address _dev, address _creator) {
    if(creator==address(0)){
       
      if(isbroker)
        broker = _creator;
      else
        seller = _creator;
      creator = _creator;
       
       
      state = State.Created;

       
      brokerFee = 50;
    }
    if(developer==address(0) || developer==msg.sender){
       developer = _dev;
    }
    if(factory==address(0)){
       factory = msg.sender;
    }
  }

  function joinAsBuyer(){
    if(buyer==address(0)){
      buyer = msg.sender;
    }
  }

  function joinAsBroker(){
    if(broker==address(0)){
      broker = msg.sender;
    }
  }

  function createOrSet(string name, uint price, string detail)
    inState(State.Created)
    onlyCreator
  {
    require(price > minimumdeveloperfee);
    item.name = name;
    item.price = price;
    item.detail = detail;
    developerfee = (price/1000)<minimumdeveloperfee ? minimumdeveloperfee : (price/1000);
    ItemInfoChanged(name, price, detail, developerfee);
  }

  function getBroker()
    constant returns(address, uint)
  {
    return (broker, brokerFee);
  }

  function getSeller()
    constant returns(address)
  {
    return (seller);
  }

  function setBroker(address _address)
    onlySeller
    inState(State.Created)
  {
    broker = _address;
    BrokerChanged(broker);
  }

  function setBrokerFee(uint fee)
    onlyCreator
    inState(State.Created)
  {
    brokerFee = fee;
    BrokerFeeChanged(fee);
  }

  function setSeller(address _address)
    onlyBroker
    inState(State.Created)
  {
    seller = _address;
    SellerChanged(seller);
  }

   
   
   
   
   
   
   
  function addDocument(bytes32 _purpose, string _name, string _ipfshash)
  {
    require(state != State.Finished);
    require(state != State.Locked);
    item.documents.push( File({
      purpose:_purpose, name:_name, ipfshash:_ipfshash, state:FileState.Created}
      ) 
    );
  }

   
  function deleteDocument(uint index)
  {
    require(state != State.Finished);
    require(state != State.Locked);
    if(index<item.documents.length){
      item.documents[index].state = FileState.Invalidated;
    }
  }

  function validate()
    onlyBroker
    inState(State.Created)
  {
     
     
     
    Validated();
     
    state = State.Validated;
  }

   
   
   
  function abort()
      onlySeller
      inState(State.Created)
  {
      AbortedBySeller();
      state = State.Finished;
       
      seller.transfer(this.balance);
  }

  function abortByBroker()
      onlyBroker
  {
      require(state != State.Finished);
      state = State.Finished;
      AbortedByBroker();
      buyer.transfer(this.balance);
  }

   
   
   
  function confirmPurchase()
      inState(State.Validated)
      condition(msg.value == item.price)
      payable
  {
      state = State.Locked;
      buyer = msg.sender;
      PurchaseConfirmed();
  }

   
   
  function confirmReceived()
      onlyBroker
      inState(State.Locked)
  {
       
       
       
      state = State.Finished;

       
       
      seller.transfer(this.balance-brokerFee-developerfee);
      broker.transfer(brokerFee);
      developer.transfer(developerfee);

      ItemReceived();
  }

  function getInfo() constant returns (State, string, uint, string, uint, uint){
    return (state, item.name, item.price, item.detail, item.documents.length, developerfee);
  }

  function getFileAt(uint index) constant returns(uint, bytes32, string, string, FileState){
    return (index,
      item.documents[index].purpose,
      item.documents[index].name,
      item.documents[index].ipfshash,
      item.documents[index].state);
  }
}