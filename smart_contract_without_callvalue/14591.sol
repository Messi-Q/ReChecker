pragma solidity ^0.4.20;

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

contract Ownable {
	address public owner;
	address public controller;
	
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor() public {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}
	
	modifier onlyController() {
		require(msg.sender == controller);
		_;
	}

	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0));
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}
	
	function setControler(address _controller) public onlyOwner {
		controller = _controller;
	}
}

contract OwnableToken {
	address public owner;
	address public minter;
	address public burner;
	address public controller;
	
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	function OwnableToken() public {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}
	
	modifier onlyMinter() {
		require(msg.sender == minter);
		_;
	}
	
	modifier onlyBurner() {
		require(msg.sender == burner);
		_;
	}
	modifier onlyController() {
		require(msg.sender == controller);
		_;
	}
  
	modifier onlyPayloadSize(uint256 numwords) {                                       
		assert(msg.data.length == numwords * 32 + 4);
		_;
	}

	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0));
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}
	
	function setMinter(address _minterAddress) public onlyOwner {
		minter = _minterAddress;
	}
	
	function setBurner(address _burnerAddress) public onlyOwner {
		burner = _burnerAddress;
	}
	
	function setControler(address _controller) public onlyOwner {
		controller = _controller;
	}
}

contract KYCControl is OwnableToken {
	event KYCApproved(address _user, bool isApproved);
	mapping(address => bool) public KYCParticipants;
	
	function isKYCApproved(address _who) view public returns (bool _isAprroved){
		return KYCParticipants[_who];
	}

	function approveKYC(address _userAddress) onlyController public {
		KYCParticipants[_userAddress] = true;
		emit KYCApproved(_userAddress, true);
	}
}

contract VernamCrowdSaleToken is OwnableToken, KYCControl {
	using SafeMath for uint256;
	
    event Transfer(address indexed from, address indexed to, uint256 value);
    
	 
	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public _totalSupply;
	
	 
	uint256 constant POW = 10 ** 18;
	uint256 _circulatingSupply;
	
	 
	mapping (address => uint256) public balances;
		
	 
	event Burn(address indexed from, uint256 value);
	event Mint(address indexed _participant, uint256 value);

	 
	function VernamCrowdSaleToken() public {
		name = "Vernam Crowdsale Token";                             
		symbol = "VCT";                               				 
		decimals = 18;                            					 
		_totalSupply = SafeMath.mul(1000000000, POW);     			 
		_circulatingSupply = 0;
	}
	
	function mintToken(address _participant, uint256 _mintedAmount) public onlyMinter returns (bool _success) {
		require(_mintedAmount > 0);
		require(_circulatingSupply.add(_mintedAmount) <= _totalSupply);
		KYCParticipants[_participant] = false;

        balances[_participant] =  balances[_participant].add(_mintedAmount);
        _circulatingSupply = _circulatingSupply.add(_mintedAmount);
		
		emit Transfer(0, this, _mintedAmount);
        emit Transfer(this, _participant, _mintedAmount);
		emit Mint(_participant, _mintedAmount);
		
		return true;
    }
	
	function burn(address _participant, uint256 _value) public onlyBurner returns (bool _success) {
        require(_value > 0);
		require(balances[_participant] >= _value);   							 
		require(isKYCApproved(_participant) == true);
		balances[_participant] = balances[_participant].sub(_value);             
		_circulatingSupply = _circulatingSupply.sub(_value);
        _totalSupply = _totalSupply.sub(_value);                      			 
		emit Transfer(_participant, 0, _value);
        emit Burn(_participant, _value);
        
		return true;
    }
  
	function totalSupply() public view returns (uint256) {
		return _totalSupply;
	}
	
	function circulatingSupply() public view returns (uint256) {
		return _circulatingSupply;
	}
	
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}
}

contract VernamCrowdSale is Ownable {
	using SafeMath for uint256;
	
	 
	uint constant TEN_ETHERS = 10 ether;
	 
	uint constant minimumContribution = 100 finney;
	uint constant maximumContribution = 500 ether;
	
	 
	uint constant FIRST_MONTH = 0;
	uint constant SECOND_MONTH = 1;
	uint constant THIRD_MONTH = 2;
	uint constant FORTH_MONTH = 3;
	uint constant FIFTH_MONTH = 4;
	uint constant SIXTH_MONTH = 5;	
	
	address public benecifiary;
	
     
	bool public isInCrowdsale;
	
	 
	uint public startTime;
	 
	uint public totalSoldTokens;
	
	 
	uint public totalContributedWei;

     
	uint constant public threeHotHoursDuration = 3 hours;
	uint constant public threeHotHoursPriceOfTokenInWei = 63751115644524 wei;  
		
	uint public threeHotHoursTokensCap; 
	uint public threeHotHoursCapInWei; 
	uint public threeHotHoursEnd;

	uint public firstStageDuration = 8 days;
	uint public firstStagePriceOfTokenInWei = 85005100306018 wei;     

	uint public firstStageEnd;
	
	uint constant public secondStageDuration = 12 days;
	uint constant public secondStagePriceOfTokenInWei = 90000900009000 wei;      
    
	uint public secondStageEnd;
	
	uint constant public thirdStageDuration = 41 days;
	uint constant public thirdStagePriceOfTokenInWei = 106258633513973 wei;           
	
	uint constant public thirdStageDiscountPriceOfTokenInWei = 95002850085503 wei;   
	
	uint public thirdStageEnd;
	
	uint constant public TOKENS_HARD_CAP = 500000000000000000000000000;  
	
	 
	uint constant POW = 10 ** 18;
	
	 
	uint constant public LOCK_TOKENS_DURATION = 30 days;
	uint public firstMonthEnd;
	uint public secondMonthEnd;
	uint public thirdMonthEnd;
	uint public fourthMonthEnd;
	uint public fifthMonthEnd;
    
     
	mapping(address => uint) public contributedInWei;
	mapping(address => uint) public threeHotHoursTokens;
	mapping(address => mapping(uint => uint)) public getTokensBalance;
	mapping(address => mapping(uint => bool)) public isTokensTaken;
	mapping(address => bool) public isCalculated;
	
	VernamCrowdSaleToken public vernamCrowdsaleToken;
	
	 
    modifier afterCrowdsale() {
        require(block.timestamp > thirdStageEnd);
        _;
    }
    
    modifier isAfterThreeHotHours {
	    require(block.timestamp > threeHotHoursEnd);
	    _;
	}
	
     
    event CrowdsaleActivated(uint startTime, uint endTime);
    event TokensBought(address participant, uint weiAmount, uint tokensAmount);
    event ReleasedTokens(uint _amount);
    event TokensClaimed(address _participant, uint tokensToGetFromWhiteList);
    
     
	constructor(address _benecifiary, address _vernamCrowdSaleTokenAddress) public {
		benecifiary = _benecifiary;
		vernamCrowdsaleToken = VernamCrowdSaleToken(_vernamCrowdSaleTokenAddress);
        
		isInCrowdsale = false;
	}
	
	 
	function activateCrowdSale() public onlyOwner {
	    		
		setTimeForCrowdsalePeriods();
		
		threeHotHoursTokensCap = 100000000000000000000000000;
		threeHotHoursCapInWei = threeHotHoursPriceOfTokenInWei.mul((threeHotHoursTokensCap).div(POW));
	    
		timeLock();
		
		isInCrowdsale = true;
		
	    emit CrowdsaleActivated(startTime, thirdStageEnd);
	}
	
	 
	function() public payable {
		buyTokens(msg.sender,msg.value);
	}
	
	 
	function buyTokens(address _participant, uint _weiAmount) public payable returns(bool success) {
	     
		require(isInCrowdsale == true);
		 
		require(_weiAmount >= minimumContribution);
		require(_weiAmount <= maximumContribution);
		
		 
		 
		validatePurchase(_participant, _weiAmount);

		uint currentLevelTokens;
		uint nextLevelTokens;
		 
		(currentLevelTokens, nextLevelTokens) = calculateAndCreateTokens(_weiAmount);
		uint tokensAmount = currentLevelTokens.add(nextLevelTokens);
		
		 
		if(totalSoldTokens.add(tokensAmount) > TOKENS_HARD_CAP) {
			isInCrowdsale = false;
			return;
		}
		
		 
		benecifiary.transfer(_weiAmount);
		
		 
		contributedInWei[_participant] = contributedInWei[_participant].add(_weiAmount);
		
		 
		if(threeHotHoursEnd > block.timestamp) {
			threeHotHoursTokens[_participant] = threeHotHoursTokens[_participant].add(currentLevelTokens);
			isCalculated[_participant] = false;
			 
			 
			if(nextLevelTokens > 0) {
				vernamCrowdsaleToken.mintToken(_participant, nextLevelTokens);
			} 
		} else {	
			vernamCrowdsaleToken.mintToken(_participant, tokensAmount);        
		}
		
		 
		totalSoldTokens = totalSoldTokens.add(tokensAmount);
		
		 
		totalContributedWei = totalContributedWei.add(_weiAmount);
		
		emit TokensBought(_participant, _weiAmount, tokensAmount);
		
		return true;
	}
	
	 
	function calculateAndCreateTokens(uint weiAmount) internal view returns (uint _currentLevelTokensAmount, uint _nextLevelTokensAmount) {

		if(block.timestamp < threeHotHoursEnd && totalSoldTokens < threeHotHoursTokensCap) {
		    (_currentLevelTokensAmount, _nextLevelTokensAmount) = tokensCalculator(weiAmount, threeHotHoursPriceOfTokenInWei, firstStagePriceOfTokenInWei, threeHotHoursCapInWei);
			return (_currentLevelTokensAmount, _nextLevelTokensAmount);
		}
		
		if(block.timestamp < firstStageEnd) {
		    _currentLevelTokensAmount = weiAmount.div(firstStagePriceOfTokenInWei);
	        _currentLevelTokensAmount = _currentLevelTokensAmount.mul(POW);
	        
		    return (_currentLevelTokensAmount, 0);
		}
		
		if(block.timestamp < secondStageEnd) {		
		    _currentLevelTokensAmount = weiAmount.div(secondStagePriceOfTokenInWei);
	        _currentLevelTokensAmount = _currentLevelTokensAmount.mul(POW);
	        
		    return (_currentLevelTokensAmount, 0);
		}
		
		if(block.timestamp < thirdStageEnd && weiAmount >= TEN_ETHERS) {
		    _currentLevelTokensAmount = weiAmount.div(thirdStageDiscountPriceOfTokenInWei);
	        _currentLevelTokensAmount = _currentLevelTokensAmount.mul(POW);
	        
		    return (_currentLevelTokensAmount, 0);
		}
		
		if(block.timestamp < thirdStageEnd){	
		    _currentLevelTokensAmount = weiAmount.div(thirdStagePriceOfTokenInWei);
	        _currentLevelTokensAmount = _currentLevelTokensAmount.mul(POW);
	        
		    return (_currentLevelTokensAmount, 0);
		}
		
		revert();
	}
	
	 
	function release() public {
	    releaseThreeHotHourTokens(msg.sender);
	}
	
	 
	function releaseThreeHotHourTokens(address _participant) public isAfterThreeHotHours returns(bool success) { 
	     
	     
		if(isCalculated[_participant] == false) {
		    calculateTokensForMonth(_participant);
		    isCalculated[_participant] = true;
		}
		
		 
		uint _amount = unlockTokensAmount(_participant);
		
		 
		threeHotHoursTokens[_participant] = threeHotHoursTokens[_participant].sub(_amount);
		
		 
		vernamCrowdsaleToken.mintToken(_participant, _amount);        

		emit ReleasedTokens(_amount);
		
		return true;
	}
	
	 
	function getContributedAmountInWei(address _participant) public view returns (uint) {
        return contributedInWei[_participant];
    }
	
	 
      
	function tokensCalculator(uint weiAmount, uint currentLevelPrice, uint nextLevelPrice, uint currentLevelCap) internal view returns (uint _currentLevelTokensAmount, uint _nextLevelTokensAmount){
	    uint currentAmountInWei = 0;
		uint remainingAmountInWei = 0;
		uint currentLevelTokensAmount = 0;
		uint nextLevelTokensAmount = 0;
		
		 
		if(weiAmount.add(totalContributedWei) > currentLevelCap) {
		    remainingAmountInWei = (weiAmount.add(totalContributedWei)).sub(currentLevelCap);
		    currentAmountInWei = weiAmount.sub(remainingAmountInWei);
            
            currentLevelTokensAmount = currentAmountInWei.div(currentLevelPrice);
            nextLevelTokensAmount = remainingAmountInWei.div(nextLevelPrice); 
	    } else {
	        currentLevelTokensAmount = weiAmount.div(currentLevelPrice);
			nextLevelTokensAmount = 0;
	    }
	    currentLevelTokensAmount = currentLevelTokensAmount.mul(POW);
	    nextLevelTokensAmount = nextLevelTokensAmount.mul(POW);
		
		
		return (currentLevelTokensAmount, nextLevelTokensAmount);
	}
	
	 
	function calculateTokensForMonth(address _participant) internal {
	     
	    uint maxBalance = threeHotHoursTokens[_participant];
	    
	     
	    uint percentage = 10;
	    for(uint month = 0; month < 6; month++) {
	         
	         
	        if(month == 3 || month == 5) {
	            percentage += 10;
	        }
	        
	         
	        getTokensBalance[_participant][month] = maxBalance.div(percentage);
	        
	         
	        isTokensTaken[_participant][month] = false; 
	    }
	}
	
		
	 
	function unlockTokensAmount(address _participant) internal returns (uint _tokensAmount) {
	     
		require(threeHotHoursTokens[_participant] > 0);
		
		 
        if(block.timestamp < firstMonthEnd && isTokensTaken[_participant][FIRST_MONTH] == false) {
             
            return getTokens(_participant, FIRST_MONTH.add(1));  
        } 
        
         
        if(((block.timestamp >= firstMonthEnd) && (block.timestamp < secondMonthEnd)) 
            && isTokensTaken[_participant][SECOND_MONTH] == false) {
             
            return getTokens(_participant, SECOND_MONTH.add(1));  
        } 
        
         
        if(((block.timestamp >= secondMonthEnd) && (block.timestamp < thirdMonthEnd)) 
            && isTokensTaken[_participant][THIRD_MONTH] == false) {
             
            return getTokens(_participant, THIRD_MONTH.add(1));  
        } 
        
         
        if(((block.timestamp >= thirdMonthEnd) && (block.timestamp < fourthMonthEnd)) 
            && isTokensTaken[_participant][FORTH_MONTH] == false) {
             
            return getTokens(_participant, FORTH_MONTH.add(1));  
        } 
        
         
        if(((block.timestamp >= fourthMonthEnd) && (block.timestamp < fifthMonthEnd)) 
            && isTokensTaken[_participant][FIFTH_MONTH] == false) {
             
            return getTokens(_participant, FIFTH_MONTH.add(1));  
        } 
        
         
        if((block.timestamp >= fifthMonthEnd) 
            && isTokensTaken[_participant][SIXTH_MONTH] == false) {
            return getTokens(_participant, SIXTH_MONTH.add(1));  
        }
    }
    
     
    function getTokens(address _participant, uint _period) internal returns(uint tokensAmount) {
        uint tokens = 0;
        for(uint month = 0; month < _period; month++) {
             
            if(isTokensTaken[_participant][month] == false) { 
                 
                isTokensTaken[_participant][month] = true;
                
                 
                tokens += getTokensBalance[_participant][month];
                
                 
                getTokensBalance[_participant][month] = 0;
            }
        }
        
        return tokens;
    }
	
	 
	function validatePurchase(address _participant, uint _weiAmount) pure internal {
        require(_participant != address(0));
        require(_weiAmount != 0);
    }
	
	  
	function setTimeForCrowdsalePeriods() internal {
		startTime = block.timestamp;
		threeHotHoursEnd = startTime.add(threeHotHoursDuration);
		firstStageEnd = threeHotHoursEnd.add(firstStageDuration);
		secondStageEnd = firstStageEnd.add(secondStageDuration);
		thirdStageEnd = secondStageEnd.add(thirdStageDuration);
	}
	
	 
	function timeLock() internal {
		firstMonthEnd = (startTime.add(LOCK_TOKENS_DURATION)).add(threeHotHoursDuration);
		secondMonthEnd = firstMonthEnd.add(LOCK_TOKENS_DURATION);
		thirdMonthEnd = secondMonthEnd.add(LOCK_TOKENS_DURATION);
		fourthMonthEnd = thirdMonthEnd.add(LOCK_TOKENS_DURATION);
		fifthMonthEnd = fourthMonthEnd.add(LOCK_TOKENS_DURATION);
	}
	
	function getPrice(uint256 time, uint256 weiAmount) public view returns (uint levelPrice) {

		if(time < threeHotHoursEnd && totalSoldTokens < threeHotHoursTokensCap) {
            return threeHotHoursPriceOfTokenInWei;
		}
		
		if(time < firstStageEnd) {
            return firstStagePriceOfTokenInWei;
		}
		
		if(time < secondStageEnd) {
            return secondStagePriceOfTokenInWei;
		}
		
		if(time < thirdStageEnd && weiAmount > TEN_ETHERS) {
            return thirdStageDiscountPriceOfTokenInWei;
		}
		
		if(time < thirdStageEnd){		
		    return thirdStagePriceOfTokenInWei;
		}
	}
	
	function setBenecifiary(address _newBenecifiary) public onlyOwner {
		benecifiary = _newBenecifiary;
	}
}
contract OwnableController {
	address public owner;
	address public KYCTeam;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor() public {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}
	
	modifier onlyKYCTeam() {
		require(msg.sender == KYCTeam);
		_;
	}
	
	function setKYCTeam(address _KYCTeam) public onlyOwner {
		KYCTeam = _KYCTeam;
	}

	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0));
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}
}
contract Controller is OwnableController {
    
    VernamCrowdSale public vernamCrowdSale;
	VernamCrowdSaleToken public vernamCrowdsaleToken;
	VernamToken public vernamToken;
	
	mapping(address => bool) public isParticipantApproved;
    
    event Refunded(address _to, uint amountInWei);
	event Convert(address indexed participant, uint tokens);
    
    function Controller(address _crowdsaleAddress, address _vernamCrowdSaleToken) public {
        vernamCrowdSale = VernamCrowdSale(_crowdsaleAddress);
		vernamCrowdsaleToken = VernamCrowdSaleToken(_vernamCrowdSaleToken);
    }
    
    function releaseThreeHotHourTokens() public {
        vernamCrowdSale.releaseThreeHotHourTokens(msg.sender);
    }
	
	function convertYourTokens() public {
		convertTokens(msg.sender);
	}
	
	function convertTokens(address _participant) public {
	    bool isApproved = vernamCrowdsaleToken.isKYCApproved(_participant);
		if(isApproved == false && isParticipantApproved[_participant] == true){
			vernamCrowdsaleToken.approveKYC(_participant);
			isApproved = vernamCrowdsaleToken.isKYCApproved(_participant);
		}
	    
	    require(isApproved == true);
	    
		uint256 tokens = vernamCrowdsaleToken.balanceOf(_participant);
		
		require(tokens > 0);
		vernamCrowdsaleToken.burn(_participant, tokens);
		vernamToken.transfer(_participant, tokens);
		
		emit Convert(_participant, tokens);
	}
	
	function approveKYC(address _participant) public onlyKYCTeam returns(bool _success) {
	    vernamCrowdsaleToken.approveKYC(_participant);
		isParticipantApproved[_participant] = vernamCrowdsaleToken.isKYCApproved(_participant);
	    return isParticipantApproved[_participant];
	}
	
	function setVernamOriginalToken(address _vernamToken) public onlyOwner {
		vernamToken = VernamToken(_vernamToken);
	}
}

contract ERC20 {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract VernamToken is ERC20 {
	using SafeMath for uint256;
	
	 
	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public _totalSupply;
		
	modifier onlyPayloadSize(uint256 numwords) {                                          
		assert(msg.data.length == numwords * 32 + 4);
		_;
	}
	
	 
	mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) internal allowed;

	 
	function VernamToken(uint256 _totalSupply_) public {
		name = "Vernam Token";                                   	 
		symbol = "VRN";                               				 
		decimals = 18;                            					 
		_totalSupply = _totalSupply_;     			 
		balances[msg.sender] = _totalSupply_;
	}

	function transfer(address _to, uint256 _value) onlyPayloadSize(2) public returns (bool _success) {
		return _transfer(msg.sender, _to, _value);
	}
	
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success) {
        require(_value <= allowed[_from][msg.sender]);     								 
        
		_transfer(_from, _to, _value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		
		return true;
    }
	
	 
	function _transfer(address _from, address _to, uint256 _value) internal returns (bool _success) {
		require (_to != address(0x0));														 
		require(_value >= 0);
		require (balances[_from] >= _value);                								 
		require (balances[_to].add(_value) > balances[_to]); 								 
		
		uint256 previousBalances = balances[_from].add(balances[_to]);					 
		
		balances[_from] = balances[_from].sub(_value);        				   				 
		balances[_to] = balances[_to].add(_value);                            				 
		
		emit Transfer(_from, _to, _value);
		
		 
        assert(balances[_from] + balances[_to] == previousBalances);  
		
		return true;
	}

	function increaseApproval(address _spender, uint256 _addedValue) onlyPayloadSize(2) public returns (bool _success) {
		require(allowed[msg.sender][_spender].add(_addedValue) <= balances[msg.sender]);
		
		allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
		
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		
		return true;
	}

	function decreaseApproval(address _spender, uint256 _subtractedValue) onlyPayloadSize(2) public returns (bool _success) {
		uint256 oldValue = allowed[msg.sender][_spender];
		
		if (_subtractedValue > oldValue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
		}
		
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		
		return true;
	}
	
	function approve(address _spender, uint256 _value) onlyPayloadSize(2) public returns (bool _success) {
		require(_value <= balances[msg.sender]);
		
		allowed[msg.sender][_spender] = _value;
		
		emit Approval(msg.sender, _spender, _value);
		
		return true;
	}
  
	function totalSupply() public view returns (uint256) {
		return _totalSupply;
	}
	
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}
	
	function allowance(address _owner, address _spender) public view returns (uint256 _remaining) {
		return allowed[_owner][_spender];
	}
}