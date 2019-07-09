 

pragma solidity ^0.4.23;

 
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract IICO {

     
    address public owner;        
    address public beneficiary;  

     
    uint constant HEAD = 0;             
    uint constant TAIL = uint(-1);      
    uint constant INFINITY = uint(-2);  
     
     
     
     
    struct Bid {
         
        uint prev;             
        uint next;             
         
        uint maxValuation;     
        uint contrib;          
        uint bonus;            
        address contributor;   
        bool withdrawn;        
        bool redeemed;         
    }
    mapping (uint => Bid) public bids;  
    mapping (address => uint[]) public contributorBidIDs;  
    uint public lastBidID = 0;  

     
    uint public startTime;                       
    uint public endFullBonusTime;                
    uint public withdrawalLockTime;              
    uint public endTime;                         
    ERC20 public token;                          
    uint public tokensForSale;                   
    uint public maxBonus;                        
    uint constant BONUS_DIVISOR = 1E9;           

     
    bool public finalized;                  
    uint public cutOffBidID = TAIL;         
    uint public sumAcceptedContrib;         
    uint public sumAcceptedVirtualContrib;  

     
    event BidSubmitted(address indexed contributor, uint indexed bidID, uint indexed time);

     
    modifier onlyOwner{ require(owner == msg.sender); _; }

     

     
    function IICO(uint _startTime, uint _fullBonusLength, uint _partialWithdrawalLength, uint _withdrawalLockUpLength, uint _maxBonus, address _beneficiary) public {
        owner = msg.sender;
        startTime = _startTime;
        endFullBonusTime = startTime + _fullBonusLength;
        withdrawalLockTime = endFullBonusTime + _partialWithdrawalLength;
        endTime = withdrawalLockTime + _withdrawalLockUpLength;
        maxBonus = _maxBonus;
        beneficiary = _beneficiary;

         
        bids[HEAD] = Bid({
            prev: TAIL,
            next: TAIL,
            maxValuation: HEAD,
            contrib: 0,
            bonus: 0,
            contributor: address(0),
            withdrawn: false,
            redeemed: false
        });
        bids[TAIL] = Bid({
            prev: HEAD,
            next: HEAD,
            maxValuation: TAIL,
            contrib: 0,
            bonus: 0,
            contributor: address(0),
            withdrawn: false,
            redeemed: false
        });
    }

     
    function setToken(ERC20 _token) public onlyOwner {
        require(address(token) == address(0));  

        token = _token;
        tokensForSale = token.balanceOf(this);
    }

     
    function submitBid(uint _maxValuation, uint _next) public payable {
        Bid storage nextBid = bids[_next];
        uint prev = nextBid.prev;
        Bid storage prevBid = bids[prev];
        require(_maxValuation >= prevBid.maxValuation && _maxValuation < nextBid.maxValuation);  
        require(now >= startTime && now < endTime);  

        ++lastBidID;  
         
        prevBid.next = lastBidID;
        nextBid.prev = lastBidID;

         
        bids[lastBidID] = Bid({
            prev: prev,
            next: _next,
            maxValuation: _maxValuation,
            contrib: msg.value,
            bonus: bonus(),
            contributor: msg.sender,
            withdrawn: false,
            redeemed: false
        });

         
        contributorBidIDs[msg.sender].push(lastBidID);

         
        emit BidSubmitted(msg.sender, lastBidID, now);
    }


     
    function searchAndBid(uint _maxValuation, uint _next) public payable {
        submitBid(_maxValuation, search(_maxValuation,_next));
    }

     
    function withdraw(uint _bidID) public {
        Bid storage bid = bids[_bidID];
        require(msg.sender == bid.contributor);
        require(now < withdrawalLockTime);
        require(!bid.withdrawn);

        bid.withdrawn = true;

         
        uint refund = (now < endFullBonusTime) ? bid.contrib : (bid.contrib * (withdrawalLockTime - now)) / (withdrawalLockTime - endFullBonusTime);
        assert(refund <= bid.contrib);  
        bid.contrib -= refund;
        bid.bonus = (bid.bonus * 2) / 3;  

        msg.sender.transfer(refund);
    }

     
    function finalize(uint _maxIt) public {
        require(now >= endTime);
        require(!finalized);

         
        uint localCutOffBidID = cutOffBidID;
        uint localSumAcceptedContrib = sumAcceptedContrib;
        uint localSumAcceptedVirtualContrib = sumAcceptedVirtualContrib;

         
        for (uint it = 0; it < _maxIt && !finalized; ++it) {
            Bid storage bid = bids[localCutOffBidID];
            if (bid.contrib+localSumAcceptedContrib < bid.maxValuation) {  
                localSumAcceptedContrib        += bid.contrib;
                localSumAcceptedVirtualContrib += bid.contrib + (bid.contrib * bid.bonus) / BONUS_DIVISOR;
                localCutOffBidID = bid.prev;  
            } else {  
                finalized = true;
                uint contribCutOff = bid.maxValuation >= localSumAcceptedContrib ? bid.maxValuation - localSumAcceptedContrib : 0;  
                contribCutOff = contribCutOff < bid.contrib ? contribCutOff : bid.contrib;  
                bid.contributor.send(bid.contrib-contribCutOff);  
                bid.contrib = contribCutOff;  
                localSumAcceptedContrib += bid.contrib;
                localSumAcceptedVirtualContrib += bid.contrib + (bid.contrib * bid.bonus) / BONUS_DIVISOR;
                beneficiary.send(localSumAcceptedContrib);  
            }
        }

         
        cutOffBidID = localCutOffBidID;
        sumAcceptedContrib = localSumAcceptedContrib;
        sumAcceptedVirtualContrib = localSumAcceptedVirtualContrib;
    }

     
    function redeem(uint _bidID) public {
        Bid storage bid = bids[_bidID];
        Bid storage cutOffBid = bids[cutOffBidID];
        require(finalized);
        require(!bid.redeemed);

        bid.redeemed=true;
        if (bid.maxValuation > cutOffBid.maxValuation || (bid.maxValuation == cutOffBid.maxValuation && _bidID >= cutOffBidID))  
            require(token.transfer(bid.contributor, (tokensForSale * (bid.contrib + (bid.contrib * bid.bonus) / BONUS_DIVISOR)) / sumAcceptedVirtualContrib));
        else                                                                                             
            bid.contributor.transfer(bid.contrib);
    }

     
    function () public payable {
        if (msg.value != 0 && now >= startTime && now < endTime)  
            submitBid(INFINITY, TAIL);
        else if (msg.value == 0 && finalized)                     
            for (uint i = 0; i < contributorBidIDs[msg.sender].length; ++i)
            {
                if (!bids[contributorBidIDs[msg.sender][i]].redeemed)
                    redeem(contributorBidIDs[msg.sender][i]);
            }
        else                                                      
            revert();
    }

     

     
    function search(uint _maxValuation, uint _nextStart) view public returns(uint nextInsert) {
        uint next = _nextStart;
        bool found;

        while(!found) {  
            Bid storage nextBid = bids[next];
            uint prev = nextBid.prev;
            Bid storage prevBid = bids[prev];

            if (_maxValuation < prevBid.maxValuation)        
                next = prev;
            else if (_maxValuation >= nextBid.maxValuation)  
                next = nextBid.next;
            else                                 
                found = true;
        }

        return next;
    }

     
    function bonus() public view returns(uint b) {
        if (now < endFullBonusTime)  
            return maxBonus;
        else if (now > endTime)      
            return 0;
        else                         
            return (maxBonus * (endTime - now)) / (endTime - endFullBonusTime);
    }

     
    function totalContrib(address _contributor) public view returns (uint contribution) {
        for (uint i = 0; i < contributorBidIDs[_contributor].length; ++i)
            contribution += bids[contributorBidIDs[_contributor][i]].contrib;
    }

     

     
    function valuationAndCutOff() public view returns (uint valuation, uint virtualValuation, uint currentCutOffBidID, uint currentCutOffBidmaxValuation, uint currentCutOffBidContrib) {
        currentCutOffBidID = bids[TAIL].prev;

         
        while (currentCutOffBidID != HEAD) {
            Bid storage bid = bids[currentCutOffBidID];
            if (bid.contrib + valuation < bid.maxValuation) {  
                valuation += bid.contrib;
                virtualValuation += bid.contrib + (bid.contrib * bid.bonus) / BONUS_DIVISOR;
                currentCutOffBidID = bid.prev;  
            } else {  
                currentCutOffBidContrib = bid.maxValuation >= valuation ? bid.maxValuation - valuation : 0;  
                valuation += currentCutOffBidContrib;
                virtualValuation += currentCutOffBidContrib + (currentCutOffBidContrib * bid.bonus) / BONUS_DIVISOR;
                break;
            }
        }

        currentCutOffBidmaxValuation = bids[currentCutOffBidID].maxValuation;
    }
}

 
contract LevelWhitelistedIICO is IICO {
    
    uint public maximumBaseContribution;
    mapping (address => bool) public baseWhitelist;  
    mapping (address => bool) public reinforcedWhitelist;  
    address public whitelister;  
    
    modifier onlyWhitelister{ require(whitelister == msg.sender); _; }
    
     
    function LevelWhitelistedIICO(uint _startTime, uint _fullBonusLength, uint _partialWithdrawalLength, uint _withdrawalLockUpLength, uint _maxBonus, address _beneficiary, uint _maximumBaseContribution) IICO(_startTime,_fullBonusLength,_partialWithdrawalLength,_withdrawalLockUpLength,_maxBonus,_beneficiary) public {
        maximumBaseContribution=_maximumBaseContribution;
    }
    
     
    function submitBid(uint _maxValuation, uint _next) public payable {
        require(reinforcedWhitelist[msg.sender] || (baseWhitelist[msg.sender] && (msg.value + totalContrib(msg.sender) <= maximumBaseContribution)));  
        super.submitBid(_maxValuation,_next);
    }
    
     
    function setWhitelister(address _whitelister) public onlyOwner {
        whitelister=_whitelister;
    }
    
     
    function addBaseWhitelist(address[] _buyersToWhitelist) public onlyWhitelister {
        for(uint i=0;i<_buyersToWhitelist.length;++i)
            baseWhitelist[_buyersToWhitelist[i]]=true;
    }
    
     
    function addReinforcedWhitelist(address[] _buyersToWhitelist) public onlyWhitelister {
        for(uint i=0;i<_buyersToWhitelist.length;++i)
            reinforcedWhitelist[_buyersToWhitelist[i]]=true;
    }
    
     
    function removeBaseWhitelist(address[] _buyersToRemove) public onlyWhitelister {
        for(uint i=0;i<_buyersToRemove.length;++i)
            baseWhitelist[_buyersToRemove[i]]=false;
    }
    
     
    function removeReinforcedWhitelist(address[] _buyersToRemove) public onlyWhitelister {
        for(uint i=0;i<_buyersToRemove.length;++i)
            reinforcedWhitelist[_buyersToRemove[i]]=false;
    }

}