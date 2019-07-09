pragma solidity 0.4.23;

 

contract Ownable {
  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

   
  modifier whenPaused() {
    require(paused);
    _;
  }

   
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

   
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

contract SafeMath {
  function safeMul(uint a, uint b) internal pure returns (uint256) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal pure returns (uint256) {
    uint c = a / b;
    return c;
  }

  function safeSub(uint a, uint b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal pure returns (uint256) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}


 
contract Stoppable is Pausable {
  event Stop();

  bool public stopped = false;


   
  modifier whenNotStopped() {
    require(!stopped);
    _;
  }

   
  modifier whenStopped() {
    require(stopped);
    _;
  }

   
  function stop() public onlyOwner whenNotStopped {
    stopped = true;
    emit Stop();
  }
}


 
contract e2pEscrow is Stoppable, SafeMath {

   
  uint public commissionFee;

   
  uint public commissionToWithdraw;  

   
  address public verifier;
    
   
  event LogDeposit(
		   address indexed sender,
		   address indexed transitAddress,
		   uint amount,
		      uint commission
		   );

  event LogCancel(
		  address indexed sender,
		  address indexed transitAddress
		  );

  event LogWithdraw(
		    address indexed sender,
		    address indexed transitAddress,
		    address indexed recipient,
		    uint amount
		    );

  event LogWithdrawCommission(uint commissionAmount);

  event LogChangeFixedCommissionFee(
				    uint oldCommissionFee,
				    uint newCommissionFee
				    );
  
  event LogChangeVerifier(
			  address oldVerifier,
			  address newVerifier
			  );  
  
  struct Transfer {
    address from;
    uint amount;  
  }

   
  mapping (address => Transfer) transferDct;


   
  constructor(uint _commissionFee, address _verifier) public {
    commissionFee = _commissionFee;
    verifier = _verifier;
  }


  modifier onlyVerifier() {
    require(msg.sender == verifier);
    _;
  }
  
   
  function deposit(address _transitAddress)
                            public
                            whenNotPaused
                            whenNotStopped
                            payable
    returns(bool)
  {
     
    require(transferDct[_transitAddress].amount == 0);

    require(msg.value > commissionFee);

     
    transferDct[_transitAddress] = Transfer(
					    msg.sender,
					    safeSub(msg.value, commissionFee) 
					    );

     
    commissionToWithdraw = safeAdd(commissionToWithdraw, commissionFee);

     
    emit LogDeposit(msg.sender, _transitAddress, msg.value, commissionFee);
    return true;
  }

   
  function changeFixedCommissionFee(uint _newCommissionFee)
                          public
                          whenNotPaused
                          whenNotStopped
                          onlyOwner
    returns(bool success)
  {
    uint oldCommissionFee = commissionFee;
    commissionFee = _newCommissionFee;
    emit LogChangeFixedCommissionFee(oldCommissionFee, commissionFee);
    return true;
  }

  
   
  function changeVerifier(address _newVerifier)
                          public
                          whenNotPaused
                          whenNotStopped
                          onlyOwner
    returns(bool success)
  {
    address oldVerifier = verifier;
    verifier = _newVerifier;
    emit LogChangeVerifier(oldVerifier, verifier);
    return true;
  }

  
   
  function withdrawCommission()
                        public
                        whenNotPaused
    returns(bool success)
  {
    uint commissionToTransfer = commissionToWithdraw;
    commissionToWithdraw = 0;
    owner.transfer(commissionToTransfer);  

    emit LogWithdrawCommission(commissionToTransfer);
    return true;
  }

   
  function getTransfer(address _transitAddress)
            public
            constant
    returns (
	     address id,
	     address from,  
	     uint amount)  
  {
    Transfer memory transfer = transferDct[_transitAddress];
    return (
	    _transitAddress,
	    transfer.from,
	        transfer.amount
	    );
  }


   
  function cancelTransfer(address _transitAddress) public returns (bool success) {
    Transfer memory transferOrder = transferDct[_transitAddress];

     
    require(msg.sender == transferOrder.from);

    delete transferDct[_transitAddress];
    
     
    msg.sender.transfer(transferOrder.amount);

     
    emit LogCancel(msg.sender, _transitAddress);
    
    return true;
  }

   
  function verifySignature(
			   address _transitAddress,
			   address _recipient,
			   uint8 _v,
			   bytes32 _r,
			   bytes32 _s)
    public pure returns(bool success)
  {
    bytes32 prefixedHash = keccak256("\x19Ethereum Signed Message:\n32", _recipient);
    address retAddr = ecrecover(prefixedHash, _v, _r, _s);
    return retAddr == _transitAddress;
  }

   
  function verifyTransferSignature(
				   address _transitAddress,
				   address _recipient,
				   uint8 _v,
				   bytes32 _r,
				   bytes32 _s)
    public pure returns(bool success)
  {
    return (verifySignature(_transitAddress,
			    _recipient, _v, _r, _s));
  }

   
  function withdraw(
		    address _transitAddress,
		    address _recipient,
		    uint8 _v,
		    bytes32 _r,
		    bytes32 _s
		    )
    public
    onlyVerifier  
    whenNotPaused
    whenNotStopped
    returns (bool success)
  {
    Transfer memory transferOrder = transferDct[_transitAddress];

     
    (verifySignature(_transitAddress,
		     _recipient, _v, _r, _s ));

    delete transferDct[_transitAddress];

     
    _recipient.transfer(transferOrder.amount);

     
    emit LogWithdraw(transferOrder.from, _transitAddress, _recipient, transferOrder.amount);

    return true;
  }

   
  function() public payable {
    revert();
  }
}