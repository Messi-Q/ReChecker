pragma solidity ^0.4.23;

contract token {
    function transferFrom(address sender, address receiver, uint amount) returns(bool success) {}
    function burn() {}
}

library SafeMath {
    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}

contract EphronIndiaCoinICO {
    using SafeMath for uint;
     
    uint constant public maxGoal = 900000;  
     
    uint public prices = 100000;  
    uint public amount_stages = 27500;  
     
    uint public amountRaised;
     
    uint public tokensSold = 0;
     
    uint constant public start = 1526470200;  
     
    uint constant public end = 1531675800;  
     
    mapping(address => uint) public balances;
     
    bool public crowdsaleEnded = false;
     
    address public tokenOwner;
     
    token public tokenReward;
     
    address wallet;
     
    event Finalize(address _tokenOwner, uint _amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution, uint _amountRaised);

     
    uint _current = 0;
    function current() public returns (uint) {
         
        if(_current == 0) {
            return now;
        }
        return _current;
    }
    function setCurrent(uint __current) {
        _current = __current;
    }
     

     
    function EphronIndiaCoinICO(address tokenAddr, address walletAddr, address tokenOwnerAddr) {
        tokenReward = token(tokenAddr);
        wallet = walletAddr;
        tokenOwner = tokenOwnerAddr;
    }

     
    function() payable {
        if (msg.sender != wallet)  
            exchange(msg.sender);
    }

     
     
     
    function exchange(address receiver) payable {
        uint amount = msg.value;
        uint price = getPrice();
        uint numTokens = amount.mul(price);

        require(numTokens > 0);
        require(!crowdsaleEnded && current() >= start && current() <= end && tokensSold.add(numTokens) <= maxGoal);

        wallet.transfer(amount);
        balances[receiver] = balances[receiver].add(amount);

         
        amountRaised = amountRaised.add(amount);
        tokensSold = tokensSold.add(numTokens);

        assert(tokenReward.transferFrom(tokenOwner, receiver, numTokens));
        FundTransfer(receiver, amount, true, amountRaised);
    }
    
      
    function getPrice() constant returns (uint price) {
        return prices;
    }

     
     
     
    function manualExchange(address receiver, uint value) {
        require(msg.sender == tokenOwner);
        require(tokensSold.add(value) <= maxGoal);
        tokensSold = tokensSold.add(value);
        assert(tokenReward.transferFrom(tokenOwner, receiver, value));
    }

   

    modifier afterDeadline() { if (current() >= end) _; }

     
    function finalize() afterDeadline {
        require(!crowdsaleEnded);
        tokenReward.burn();  
        Finalize(tokenOwner, amountRaised);
        crowdsaleEnded = true;
    }

     
     
    function safeWithdrawal() afterDeadline {
        uint amount = balances[msg.sender];
        if (address(this).balance >= amount) {
            balances[msg.sender] = 0;
            if (amount > 0) {
                msg.sender.transfer(amount);
                FundTransfer(msg.sender, amount, false, amountRaised);
            }
        }
    }
}