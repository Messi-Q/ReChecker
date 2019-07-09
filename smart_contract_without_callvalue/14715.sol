pragma solidity ^0.4.23;

 
library SafeMath {
     
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    
     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        return a / b;
    }
    
     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
     
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

 
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

 
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    uint256 totalSupply_;
    
     
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    
     
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
     
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}

contract StandardToken is ERC20, BasicToken {
    mapping (address => mapping (address => uint256)) internal allowed;
     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
    
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        
        emit Transfer(_from, _to, _value);
        return true;
    }
    
     
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
     
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
    
     
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
     
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
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
    
     
    function transferOwnership(address newOwner) public onlyOwner {
      require(newOwner != address(0));
      emit OwnershipTransferred(owner, newOwner);
      owner = newOwner;
    }
}

 
contract Pausable is Ownable {
    event Pause();
    event Unpause();
    
    bool public canPause = true;
    bool public paused = false;


     
    modifier whenNotPaused() {
        require(!paused || msg.sender == owner);
        _;
    }
    
     
    modifier whenPaused() {
        require(paused);
        _;
    }
    
     
    function pause() onlyOwner whenNotPaused public {
        require(canPause == true);
        paused = true;
        emit Pause();
    }
    
     
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
    
     
    function notPauseable() onlyOwner public{
        paused = false;
        canPause = false;
    }
}

 
contract PausableToken is StandardToken, Pausable {
     
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }
    
     
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    
     
    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }
    
     
    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }
    
     
    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

 
contract Configurable {
    uint256 public constant cap = 1000000000*10**18;
    uint256 public constant preSaleFirstCap = 25000000*10**18;
    uint256 public constant preSaleSecondCap = 175000000*10**18;  
    uint256 public constant preSaleThirdCap = 325000000*10**18;  
    uint256 public constant preSaleFourthCap = 425000000*10**18;  
    uint256 public constant privateLimit = 200000000*10**18;
    uint256 public constant basePrice = 2777777777777777777778;  
    uint256 public constant preSaleDiscountPrice = 11111111111111111111111;  
    uint256 public constant preSaleFirstPrice = 5555555555555555555556;  
    uint256 public constant preSaleSecondPrice = 5555555555555555555556;  
    uint256 public constant preSaleThirdPrice = 4273504273504273504274;  
    uint256 public constant preSaleFourthPrice = 3472222222222222222222;  
    uint256 public constant privateDiscountPrice = 7936507936507936507937;  
    uint256 public privateSold = 0;
    
    uint256 public icoStartDate = 0;
    uint256 public constant timeToBeBurned = 1 years;
    uint256 public constant companyReserve = 1000000000*10**18;
    uint256 public remainingTokens = 0;
    bool public icoFinalized = false;
    uint256 public icoEnd = 0; 
    uint256 public maxAmmount = 1000 ether;  
    uint256 public minContribute = 0.1 ether;  
    uint256 public constant preSaleStartDate = 1525046400;  
    
     
    uint256 public privateEventTokens = 0;
    uint256 public publicEventTokens = 0;
    bool public privateEventActive = false;
    bool public publicEventActive = false;
    uint256 public publicMin = 0;
    uint256 public privateMin = 0;
    uint256 public privateRate = 0;
    uint256 public publicRate = 0;
}

 
contract CrowdsaleToken is PausableToken, Configurable {
     
     enum Stages {
        preSale, 
        pause, 
        sale, 
        icoEnd
    }
  
    Stages currentStage;
    mapping(address => bool) saleDiscountList;  
    mapping(address => bool) customPrivateSale;  
    
     
    constructor() public {
        currentStage = Stages.preSale;
        pause();
        balances[owner] = balances[owner].add(companyReserve);
        totalSupply_ = totalSupply_.add(companyReserve);
        emit Transfer(address(this), owner, companyReserve);
    }
    
     
    function () public payable {
        require(msg.value >= minContribute);
        require(preSaleStartDate < now);
        require(currentStage != Stages.pause);
        require(currentStage != Stages.icoEnd);
        require(msg.value > 0);
        uint256[] memory tokens = tokensAmount(msg.value);
        require (tokens[0] > 0);
        balances[msg.sender] = balances[msg.sender].add(tokens[0]);
        totalSupply_ = totalSupply_.add(tokens[0]);
        require(totalSupply_ <= cap.add(companyReserve));
        emit Transfer(address(this), msg.sender, tokens[0]);
        uint256 ethValue = msg.value.sub(tokens[1]);
        owner.transfer(ethValue);
        if(tokens[1] > 0){
            msg.sender.transfer(tokens[1]);
            emit Transfer(address(this), msg.sender, tokens[1]);
        }
    }
    
    
     
    function tokensAmount (uint256 _wei) internal returns (uint256[]) {
        uint256[] memory tokens = new uint256[](7);
        tokens[0] = tokens[1] = 0;
        uint256 stageWei = 0;
        uint256 stageTokens = 0;
        uint256 stagePrice = 0;
        uint256 totalSold = totalSupply_.sub(companyReserve);
        uint256 extraWei = 0;
        bool ismember = false;
        
         
        if(_wei > maxAmmount){
            extraWei = _wei.sub(maxAmmount);
            _wei = maxAmmount;
        }
        
         
       if(customPrivateSale[msg.sender] == true && msg.value >= privateMin && privateEventActive == true && privateEventTokens > 0){
            stagePrice = privateRate;
            stageTokens = _wei.mul(stagePrice).div(1 ether);
           
            if(stageTokens <= privateEventTokens){
                tokens[0] = tokens[0].add(stageTokens);
                privateEventTokens = privateEventTokens.sub(tokens[0]);
                
                if(extraWei > 0){
                    tokens[1] = extraWei;
                     
                }
                
                return tokens;
            } else {
                stageTokens = privateEventTokens;
                privateEventActive = false;
                stageWei = stageTokens.mul(1 ether).div(stagePrice);
                tokens[0] = tokens[0].add(stageTokens);
                privateEventTokens = privateEventTokens.sub(tokens[0]);
                _wei = _wei.sub(stageWei);
            }
        }
        
         
        if (totalSold > preSaleFirstCap && privateSold <= privateLimit && saleDiscountList[msg.sender]) {
            stagePrice = privateDiscountPrice;  
          
          stageTokens = _wei.mul(stagePrice).div(1 ether);
          
          if (privateSold.add(tokens[0]).add(stageTokens) <= privateLimit) {
            tokens[0] = tokens[0].add(stageTokens);
            
            if(extraWei > 0){
                tokens[1] = extraWei;
            }
            totalSold = totalSold.add(tokens[0]);
            privateSold = privateSold.add(tokens[0]);
            return tokens;
          } else {
            stageTokens = privateLimit.sub(privateSold);
            privateSold = privateSold.add(stageTokens);
            stageWei = stageTokens.mul(1 ether).div(stagePrice);
            tokens[0] = tokens[0].add(stageTokens);
            _wei = _wei.sub(stageWei);
          }
        }
        
          
        if(publicEventActive == true && publicEventTokens > 0 && msg.value >= publicMin) {
            stagePrice = publicRate;
            stageTokens = _wei.mul(stagePrice).div(1 ether);
           
            if(stageTokens <= publicEventTokens){
                tokens[0] = tokens[0].add(stageTokens);
                publicEventTokens = publicEventTokens.sub(tokens[0]);
                
                if(extraWei > 0){
                    tokens[1] = stageWei;
                     
                }
                
                return tokens;
            } else {
                stageTokens = publicEventTokens;
                publicEventActive = false;
                stageWei = stageTokens.mul(1 ether).div(stagePrice);
                tokens[0] = tokens[0].add(stageTokens);
                publicEventTokens = publicEventTokens.sub(tokens[0]);
                _wei = _wei.sub(stageWei);
            }
        }
        
        
         
        if (currentStage == Stages.preSale && totalSold <= preSaleFirstCap) {
          if (msg.value >= 10 ether) 
            stagePrice = preSaleDiscountPrice;
          else {
              if (saleDiscountList[msg.sender]) {
                  ismember = true;
                stagePrice = privateDiscountPrice;  
              }
            else
                stagePrice = preSaleFirstPrice;
          }
            
            stageTokens = _wei.mul(stagePrice).div(1 ether);
          
          if (totalSold.add(stageTokens) <= preSaleFirstCap) {
            tokens[0] = tokens[0].add(stageTokens);
            
            if(extraWei > 0){
                tokens[1] = extraWei;
            }
            return tokens;
          }
            else if( ismember && totalSold.add(stageTokens) <= privateLimit) {
                tokens[0] = tokens[0].add(stageTokens);
                privateSold = privateSold.sub(tokens[0]);
            
            if(extraWei > 0){
                tokens[1] = extraWei;
            }
            return tokens;
            
          } else {
            stageTokens = preSaleFirstCap.sub(totalSold);
            stageWei = stageTokens.mul(1 ether).div(stagePrice);
            tokens[0] = tokens[0].add(stageTokens);
            if(ismember)
                privateSold = privateSold.sub(tokens[0]);
            _wei = _wei.sub(stageWei);
          }
        }
        
         
        if (currentStage == Stages.preSale && totalSold.add(tokens[0]) <= preSaleSecondCap) {
              stagePrice = preSaleSecondPrice; 

          stageTokens = _wei.mul(stagePrice).div(1 ether);
          
          if (totalSold.add(tokens[0]).add(stageTokens) <= preSaleSecondCap) {
            tokens[0] = tokens[0].add(stageTokens);
            
            if(extraWei > 0){
                tokens[1] = extraWei;
            }
        
            return tokens;
          } else {
            stageTokens = preSaleSecondCap.sub(totalSold).sub(tokens[0]);
            stageWei = stageTokens.mul(1 ether).div(stagePrice);
            tokens[0] = tokens[0].add(stageTokens);
            _wei = _wei.sub(stageWei);
          }
        }
        
         
        if (currentStage == Stages.preSale && totalSold.add(tokens[0]) <= preSaleThirdCap) {
            stagePrice = preSaleThirdPrice;
          stageTokens = _wei.mul(stagePrice).div(1 ether);
          
          if (totalSold.add(tokens[0]).add(stageTokens) <= preSaleThirdCap) {
            tokens[0] = tokens[0].add(stageTokens);
           
            if(extraWei > 0){
                tokens[1] = extraWei;
            }
        
            return tokens;
          } else {
            stageTokens = preSaleThirdCap.sub(totalSold).sub(tokens[0]);
            stageWei = stageTokens.mul(1 ether).div(stagePrice);
            tokens[0] = tokens[0].add(stageTokens);
            _wei = _wei.sub(stageWei);
          }
        }
         
        if (currentStage == Stages.preSale && totalSold.add(tokens[0]) <= preSaleFourthCap) {
            stagePrice = preSaleFourthPrice;
          
          stageTokens = _wei.mul(stagePrice).div(1 ether);
          
          if (totalSold.add(tokens[0]).add(stageTokens) <= preSaleFourthCap) {
            tokens[0] = tokens[0].add(stageTokens);
            
            if(extraWei > 0){
                tokens[1] = extraWei;
            }
        
            return tokens;
          } else {
            stageTokens = preSaleFourthCap.sub(totalSold).sub(tokens[0]);
            stageWei = stageTokens.mul(1 ether).div(stagePrice);
            tokens[0] = tokens[0].add(stageTokens);
            _wei = _wei.sub(stageWei);
            currentStage = Stages.pause;
            
            if(_wei > 0 || extraWei > 0){
                _wei = _wei.add(extraWei);
                tokens[1] = _wei;
            }
            return tokens;
          }
        }
        
         
        if (currentStage == Stages.sale) {
          if (privateSold > privateLimit && saleDiscountList[msg.sender]) {
            stagePrice = privateDiscountPrice;  
            stageTokens = _wei.mul(stagePrice).div(1 ether);
            uint256 ceil = totalSold.add(privateLimit);
            
            if (ceil > cap) {
              ceil = cap;
            }
            
            if (totalSold.add(stageTokens) <= ceil) {
              tokens[0] = tokens[0].add(stageTokens);
             
              if(extraWei > 0){
               tokens[1] = extraWei;
            }
            privateSold = privateSold.sub(tokens[0]);
              return tokens;          
            } else {
              stageTokens = ceil.sub(totalSold);
              tokens[0] = tokens[0].add(stageTokens);
              stageWei = stageTokens.mul(1 ether).div(stagePrice);
              _wei = _wei.sub(stageWei);
            }
            
            if (ceil == cap) {
              endIco();
              if(_wei > 0 || extraWei > 0){
                _wei = _wei.add(extraWei);
                tokens[1] = _wei;
              }
              privateSold = privateSold.sub(tokens[0]);
              return tokens;
            }
          }
          
          stagePrice = basePrice;
          stageTokens = _wei.mul(stagePrice).div(1 ether);
          
          if (totalSold.add(tokens[0]).add(stageTokens) <= cap) {
            tokens[0] = tokens[0].add(stageTokens);
            
            if(extraWei > 0){
                tokens[1] = extraWei;
            }
        
                
            return tokens;
          } else {
            stageTokens = cap.sub(totalSold).sub(tokens[0]);
            stageWei = stageTokens.mul(1 ether).div(stagePrice);
            tokens[0] = tokens[0].add(stageTokens);
            _wei = _wei.sub(stageWei);
            endIco();
            
            if(_wei > 0 || extraWei > 0){
                _wei = _wei.add(extraWei);
                tokens[1] = _wei;
            }
            return tokens;
          }      
        }
    }

     
    function startIco() public onlyOwner {
        require(currentStage != Stages.icoEnd);
        currentStage = Stages.sale;
        icoStartDate = now;
    }
    
     
    function setCustomEvent(uint256 tokenCap, uint256 eventRate, bool isActive, string eventType, uint256 minAmount) public onlyOwner {
        require(tokenCap > 0);
        require(eventRate > 0);
        require(minAmount > 0);
        
        if(compareStrings(eventType, "private")){
            privateEventTokens = tokenCap;
            privateRate = eventRate;
            privateEventActive = isActive;
            privateMin = minAmount;
        }
        else if(compareStrings(eventType, "public")){
            publicEventTokens = tokenCap;
            publicRate = eventRate;
            publicEventActive = isActive;
            publicMin = minAmount;
        }
        else
            require(1==2);
    }
    
     
    function compareStrings (string a, string b) internal pure returns (bool){
       return keccak256(a) == keccak256(b);
   }
    
     
    function setEventActive (bool isActive, string eventType) public onlyOwner {
         
        if(compareStrings(eventType, "private"))
            privateEventActive = isActive;
         
        else if(compareStrings(eventType, "public"))
            publicEventActive = isActive;
        else
            require(1==2);
    }

     
    function setMinMax (uint256 minMax, string eventType) public onlyOwner {
        require(minMax >= 0);
         
        if(compareStrings(eventType, "max"))
            maxAmmount = minMax;
         
        else if(compareStrings(eventType,"min"))
            minContribute = minMax;
        else
            require(1==2);
    }

     
    function setDiscountMember(address _address, string memberType, bool isActiveMember) public onlyOwner {
         
        if(compareStrings(memberType, "preSale"))
            saleDiscountList[_address] = isActiveMember;
         
        else if(compareStrings(memberType,"privateEvent"))
            customPrivateSale[_address] = isActiveMember;
        else
            require(1==2);
    }
    
     
    function isMemberOf(address _address, string memberType) public view returns (bool){
         
        if(compareStrings(memberType, "preSale"))
            return saleDiscountList[_address];
         
        else if(compareStrings(memberType,"privateEvent"))
            return customPrivateSale[_address];
        else
            require(1==2);
    }

     
    function endIco() internal {
        currentStage = Stages.icoEnd;
    }

     
    function withdrawFromRemainingTokens(uint256 _value) public onlyOwner returns(bool) {
        require(currentStage == Stages.icoEnd);
        require(remainingTokens > 0);
        
         
        if (now > icoEnd.add(timeToBeBurned)) 
            remainingTokens = 0;
        
         
        if (_value <= remainingTokens) {
            balances[owner] = balances[owner].add(_value);
            totalSupply_ = totalSupply_.add(_value);
            remainingTokens = remainingTokens.sub(_value);
            emit Transfer(address(this), owner, _value);
            return true;
          }
          return false;
    }

     
    function finalizeIco() public onlyOwner {
        require(!icoFinalized);
            icoFinalized = true;
        
        if (currentStage != Stages.icoEnd){
             endIco();
             icoEnd = now;
        }
        
        remainingTokens = cap.add(companyReserve).sub(totalSupply_);
        owner.transfer(address(this).balance);
    }
    
     
    function currentBonus() public view returns (string) {
        if(totalSupply_.sub(companyReserve) < preSaleFirstCap)
            return "300% Bonus!";
        else if((totalSupply_.sub(companyReserve) < preSaleSecondCap) && (totalSupply_.sub(companyReserve) > preSaleFirstCap))
            return "100% Bonus!";
        else if((totalSupply_.sub(companyReserve) < preSaleThirdCap) && (totalSupply_.sub(companyReserve) > preSaleSecondCap))
            return "54% Bonus!";
        else if((totalSupply_.sub(companyReserve) < preSaleFourthCap) && (totalSupply_.sub(companyReserve) > preSaleThirdCap))
            return "25% Bonus!";
        else
            return "No Bonus... Sorry...#BOTB";
    }
}

 
contract KimeraToken is CrowdsaleToken {
    string public constant name = "KIMERACoin";
    string public constant symbol = "KIMERA";
    uint32 public constant decimals = 18;
}