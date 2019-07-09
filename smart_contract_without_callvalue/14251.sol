pragma solidity ^0.4.18;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   
   
}

 
contract AbstractCon {
    function allowance(address _owner, address _spender)  public pure returns (uint256 remaining);
    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success);
    function token_rate() public returns (uint256);
    function minimum_token_sell() public returns (uint16);
    function decimals() public returns (uint8);
     
     
    
}

 
contract SynergisProxyDeposit is Ownable {
    using SafeMath for uint256;

     
     
     
    enum Role {Fund, Team, Adviser}
    struct Partner {
        Role roleInProject;
        address account;
        uint256  amount;
    }

    mapping (int16 => Partner)  public partners;  
    mapping (address => uint8) public special_offer; 


     
     
     
    uint8 constant Stake_Team = 10;
    uint8 constant Stake_Adv = 5;

    string public constant name = "SYNERGIS_TOKEN_CHANGE";


    uint8 public numTeamDeposits = 0;  
    uint8 public numAdviserDeposits = 0;  
    int16 public maxId = 1; 
    uint256 public notDistributedAmount = 0;
    uint256 public weiRaised;  
    address public ERC20address;

     
     
     
    event Income(address from, uint256 amount);
    event NewDepositCreated(address _acc, Role _role, int16 _maxid);
    event DeletedDeposit(address _acc, Role _role, int16 _maxid, uint256 amount);
    event DistributeIncome(address who, uint256 notDistrAm, uint256 distrAm);
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 weivalue, uint256 tokens);
    event FundsWithdraw(address indexed who, uint256 amount );
    event DepositIncome(address indexed _deposit, uint256 _amount );
    event SpecialOfferAdd(address _acc, uint16 _discount);
    event SpecialOfferRemove(address _acc);
     

     
    constructor (address fundAcc) public {
         
        require(fundAcc != address(0));  
        partners[0]=Partner(Role.Fund, fundAcc, 0); 
    }

    function() public payable {
        emit Income(msg.sender, msg.value);
        sellTokens(msg.sender);
    }

         
    function sellTokens(address beneficiary) internal  {   
        uint256 weiAmount = msg.value;  
        notDistributedAmount = notDistributedAmount.add(weiAmount); 
        AbstractCon ac = AbstractCon(ERC20address);
         
        uint256 tokens = weiAmount.mul(ac.token_rate()*(100+uint256(special_offer[beneficiary])))/100;
        require(beneficiary != address(0));
        require(ac.token_rate() > 0); 
        require(tokens >= ac.minimum_token_sell()*(10 ** uint256(ac.decimals())));
        require(ac.transferFrom(ERC20address, beneficiary, tokens)); 
        weiRaised = weiRaised.add(weiAmount);
        emit TokenPurchase(msg.sender, beneficiary, msg.value, tokens);
    }

     
    function setERC20address(address currentERC20contract)  public onlyOwner {
        require(address(currentERC20contract) != 0);
        AbstractCon ac = AbstractCon(currentERC20contract);
        require(ac.allowance(currentERC20contract, address(this))>0);
        ERC20address = currentERC20contract;
    }    

     
     
     
     
    function newDeposit(Role _role, address _dep) public onlyOwner returns (int16){
        require(getDepositID(_dep)==-1); 
        require(_dep != address(0));
        require(_dep != address(this));
        int16 depositID = maxId++; 
        partners[depositID]=Partner(_role, _dep, 0); 
         
        if (_role==Role.Team) {
            numTeamDeposits++;  
        }
        if (_role==Role.Adviser) {
            numAdviserDeposits++;  
        }
        emit NewDepositCreated(_dep, _role, depositID);
        return depositID;
    }

     
    function deleteDeposit(address dep) public onlyOwner {
        int16 depositId = getDepositID(dep);
        require(depositId>0);
         
        require(partners[depositId].roleInProject != Role.Fund);
         
        if (partners[depositId].roleInProject==Role.Team) {
            numTeamDeposits--;
        }
        if (partners[depositId].roleInProject==Role.Adviser) {
            numAdviserDeposits--;
        }
         
        notDistributedAmount = notDistributedAmount.add(partners[depositId].amount);
        emit DeletedDeposit(dep, partners[depositId].roleInProject, depositId, partners[depositId].amount);
        delete(partners[depositId]);

    }

    function getDepositID(address dep) internal constant returns (int16 id){
         
        for (int16 i=0; i<=maxId; i++) {
            if (dep==partners[i].account){
                 
                 
                return i;
            }
        }
        return -1;
    }

     
    function withdraw() external {
        int16 id = getDepositID(msg.sender);
        require(id >=0);
        uint256 amount = partners[id].amount;
         
         
        partners[id].amount = 0;
        msg.sender.transfer(amount);
        emit FundsWithdraw(msg.sender, amount);
    }


    function distributeIncomeEther() public onlyOwner { 
        require(notDistributedAmount !=0);
        uint256 distributed;
        uint256 sum;
        uint256 _amount;
        for (int16 i=0; i<=maxId; i++) {
            if  (partners[i].account != address(0) ){
                sum = 0;
                if  (partners[i].roleInProject==Role.Team) {
                    sum = notDistributedAmount/100*Stake_Team/numTeamDeposits;
                    emit DepositIncome(partners[i].account, uint256(sum));
                }
                if  (partners[i].roleInProject==Role.Adviser) {
                    sum = notDistributedAmount/100*Stake_Adv/numAdviserDeposits;
                    emit DepositIncome(partners[i].account, uint256(sum));
                }
                if  (partners[i].roleInProject==Role.Fund) {
                    int16 fundAccountId=i;  
                } else {
                    partners[i].amount = partners[i].amount.add(sum);
                    distributed = distributed.add(sum);
                }
            }
        }
         
        emit DistributeIncome(msg.sender, notDistributedAmount, distributed);
        _amount = notDistributedAmount.sub(distributed);
        partners[fundAccountId].amount =
                 partners[fundAccountId].amount.add(_amount);
        emit DepositIncome(partners[fundAccountId].account, uint256(_amount));         
        notDistributedAmount = 0;
         
    }


     
    function checkBalance() public constant returns (uint256 red_balance) {
         
        uint256 allDepositSum;
        for (int16 i=0; i<=maxId; i++) {
            allDepositSum = allDepositSum.add(partners[i].amount);
        }
        red_balance = address(this).balance.sub(notDistributedAmount).sub(allDepositSum);
        return red_balance;
    }

     
     

     
     
     

         
    function addSpecialOffer (address vip, uint8 discount_percent) public onlyOwner {
        require(discount_percent>0 && discount_percent<100);
        special_offer[vip] = discount_percent;
        emit SpecialOfferAdd(vip, discount_percent);
    }

     
    function removeSpecialOffer(address was_vip) public onlyOwner {
        special_offer[was_vip] = 0;
        emit SpecialOfferRemove(was_vip);
    }
   
   
   
   
   
}