contract ManagedAccountInterface {
     
    address public owner;
     
    bool public payOwnerOnly;
     
    uint public accumulatedInput;

    function payOut(address _recipient, uint _amount) returns (bool);

    event PayOut(address indexed _recipient, uint _amount);
}


contract ManagedAccount is ManagedAccountInterface{

     
    function ManagedAccount(address _owner, bool _payOwnerOnly) {
        owner = _owner;
        payOwnerOnly = _payOwnerOnly;
    }

    function() {
        accumulatedInput += msg.value;
    }

    function payOut(address _recipient, uint _amount) returns (bool) {
        if (msg.sender != owner || msg.value > 0 || (payOwnerOnly && _recipient != owner))
            throw;
        if (_recipient.call.value(_amount)()) {
            PayOut(_recipient, _amount);
            return true;
        } else {
            return false;
        }
    }
}

 


 

 


 

 

contract TokenInterface {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

     
    uint256 public totalSupply;

     
     
    function balanceOf(address _owner) constant returns (uint256 balance);

     
     
     
     
    function transfer(address _to, uint256 _amount) returns (bool success);

     
     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success);

     
     
     
     
     
    function approve(address _spender, uint256 _amount) returns (bool success);

     
     
     
     
    function allowance(
        address _owner,
        address _spender
    ) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );
}


contract Token is TokenInterface {
     
     
    modifier noEther() {if (msg.value > 0) throw; _}

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) noEther returns (bool success) {
        if (balances[msg.sender] >= _amount && _amount > 0) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
           return false;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) noEther returns (bool success) {

        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0) {

            balances[_to] += _amount;
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract TokenCreationInterface {

    uint public closingTime;

    uint public minTokensToCreate;
     
    bool public isFueled;

    address public privateCreation;

    ManagedAccount public extraBalance;
     
    mapping (address => uint256) weiGiven;

    function createTokenProxy(address _tokenHolder) returns (bool success);

    function refund();

    function divisor() constant returns (uint divisor);

    event FuelingToDate(uint value);
    event CreatedToken(address indexed to, uint amount);
    event Refund(address indexed to, uint value);
}


contract TokenCreation is TokenCreationInterface, Token {
    function TokenCreation(
        uint _minTokensToCreate,
        uint _closingTime,
        address _privateCreation) {

        closingTime = _closingTime;
        minTokensToCreate = _minTokensToCreate;
        privateCreation = _privateCreation;
        extraBalance = new ManagedAccount(address(this), true);
    }

    function createTokenProxy(address _tokenHolder) returns (bool success) {
        if (now < closingTime && msg.value > 0
            && (privateCreation == 0 || privateCreation == msg.sender)) {

            uint token = (msg.value * 20) / divisor();
            extraBalance.call.value(msg.value - token)();
            balances[_tokenHolder] += token;
            totalSupply += token;
            weiGiven[_tokenHolder] += msg.value;
            CreatedToken(_tokenHolder, token);
            if (totalSupply >= minTokensToCreate && !isFueled) {
                isFueled = true;
                FuelingToDate(totalSupply);
            }
            return true;
        }
        throw;
    }

    function refund() noEther {
        if (now > closingTime && !isFueled) {
             
            if (extraBalance.balance >= extraBalance.accumulatedInput())
                extraBalance.payOut(address(this), extraBalance.accumulatedInput());

             
            if (msg.sender.call.value(weiGiven[msg.sender])()) {
                Refund(msg.sender, weiGiven[msg.sender]);
                totalSupply -= balances[msg.sender];
                balances[msg.sender] = 0;
                weiGiven[msg.sender] = 0;
            }
        }
    }

    function divisor() constant returns (uint divisor) {
            return 20;
    }
}


contract DAOInterface {

     
     
    uint constant creationGracePeriod = 40 days;
     
    uint constant minProposalDebatePeriod = 3 days;
     
    uint constant minSplitDebatePeriod = 0 days;
     
    uint constant splitExecutionPeriod = 1 days;
     
    uint constant quorumHalvingPeriod = 2 weeks;
     
     
    uint constant executeProposalPeriod = 2 days;
     
     
    uint constant maxDepositDivisor = 100;

     
    Proposal[] public proposals;
     
     
    uint public minQuorumDivisor;
     
    uint public lastTimeMinQuorumMet;

     
    address public curator;
     
    mapping (address => bool) public allowedRecipients;

     
     
     
     
    mapping (address => uint) public rewardToken;
     
    uint public totalRewardToken;

     
     
    ManagedAccount public rewardAccount;

     
     
    ManagedAccount public DAOrewardAccount;

     
    mapping (address => uint) public DAOpaidOut;

     
    mapping (address => uint) public paidOut;
     
     
    mapping (address => uint) public blocked;

     
     
    uint public proposalDeposit;

     
    uint sumOfProposalDeposits;

     
     
    DAO_Creator public daoCreator;

     
     
     
    struct Proposal {
         
         
         
        address recipient;
         
        uint amount;
         
        string description;
         
        uint votingDeadline;
         
        bool open;
         
         
        bool proposalPassed;
         
        bytes32 proposalHash;
         
         
        uint proposalDeposit;
         
        bool newCurator;
         
        SplitData[] splitData;
         
        uint yea;
         
        uint nay;
         
        mapping (address => bool) votedYes;
         
        mapping (address => bool) votedNo;
         
        address creator;
    }

     
    struct SplitData {
         
        uint splitBalance;
         
        uint totalSupply;
         
        uint rewardToken;
         
        MICRODAO newDAO;
    }

     
    modifier onlyTokenholders {}

     
     
     
     
     
     
     
     
     
     
     
     
     
         
         
         
         
         
         
     

     
     
    function () returns (bool success);


     
     
     
     
    function receiveEther() returns(bool);

     
     
     
     
     
     
     
     
     
     
     
     
     
    function newProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionData,
        uint _debatingPeriod,
        bool _newCurator
    ) onlyTokenholders returns (uint _proposalID);

     
     
     
     
     
     
     
     
    function checkProposalCode(
        uint _proposalID,
        address _recipient,
        uint _amount,
        bytes _transactionData
    ) constant returns (bool _codeChecksOut);

     
     
     
     
    function vote(
        uint _proposalID,
        bool _supportsProposal
    ) onlyTokenholders returns (uint _voteID);

     
     
     
     
     
     
    function executeProposal(
        uint _proposalID,
        bytes _transactionData
    ) returns (bool _success);

     
     
     
     
     
     
     
     
     
     
     
    function splitDAO(
        uint _proposalID,
        address _newCurator
    ) returns (bool _success);

     
     
     
     
    function newContract(address _newContract);


     
     
     
     
     
    function changeAllowedRecipients(address _recipient, bool _allowed) external returns (bool _success);


     
     
     
     
    function changeProposalDeposit(uint _proposalDeposit) external;

     
     
     
     
    function retrieveDAOReward(bool _toMembers) external returns (bool _success);

     
     
    function getMyReward() returns(bool _success);

     
     
     
    function withdrawRewardFor(address _account) internal returns (bool _success);

     
     
     
     
     
    function transferWithoutReward(address _to, uint256 _amount) returns (bool success);

     
     
     
     
     
     
    function transferFromWithoutReward(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success);

     
     
     
    function halveMinQuorum() returns (bool _success);

     
    function numberOfProposals() constant returns (uint _numberOfProposals);

     
     
    function getNewDAOAddress(uint _proposalID) constant returns (address _newDAO);

     
     
    function isBlocked(address _account) internal returns (bool);

     
     
     
    function unblockMe() returns (bool);

    event ProposalAdded(
        uint indexed proposalID,
        address recipient,
        uint amount,
        bool newCurator,
        string description
    );
    event Voted(uint indexed proposalID, bool position, address indexed voter);
    event ProposalTallied(uint indexed proposalID, bool result, uint quorum);
    event NewCurator(address indexed _newCurator);
    event AllowedRecipientChanged(address indexed _recipient, bool _allowed);
}

 
contract MICRODAO is DAOInterface, Token, TokenCreation {

     
    modifier onlyTokenholders {
        if (balanceOf(msg.sender) == 0) throw;
            _
    }

    function MICRODAO(
        address _curator,
        DAO_Creator _daoCreator,
        uint _proposalDeposit,
        uint _minTokensToCreate,
        uint _closingTime,
        address _privateCreation
    ) TokenCreation(_minTokensToCreate, _closingTime, _privateCreation) {

        curator = _curator;
        daoCreator = _daoCreator;
        proposalDeposit = _proposalDeposit;
        rewardAccount = new ManagedAccount(address(this), false);
        DAOrewardAccount = new ManagedAccount(address(this), false);
        if (address(rewardAccount) == 0)
            throw;
        if (address(DAOrewardAccount) == 0)
            throw;
        lastTimeMinQuorumMet = now;
        minQuorumDivisor = 5;  
        proposals.length = 1;  

        allowedRecipients[address(this)] = true;
        allowedRecipients[curator] = true;
    }

    function () returns (bool success) {
        if (now < closingTime + creationGracePeriod && msg.sender != address(extraBalance))
            return createTokenProxy(msg.sender);
        else
            return receiveEther();
    }


    function receiveEther() returns (bool) {
        return true;
    }


    function newProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionData,
        uint _debatingPeriod,
        bool _newCurator
    ) onlyTokenholders returns (uint _proposalID) {

         
        if (_newCurator && (
            _amount != 0
            || _transactionData.length != 0
            || _recipient == curator
            || msg.value > 0)) {
            throw;
        } else if (
            !_newCurator
            && (!isRecipientAllowed(_recipient) || (_debatingPeriod <  minProposalDebatePeriod))
        ) {
            throw;
        }

        if (_debatingPeriod > 8 weeks)
            throw;

        if (!isFueled
            || now < closingTime
            || (msg.value < proposalDeposit && !_newCurator)) {

            throw;
        }

        if (now + _debatingPeriod < now)  
            throw;

         
        if (msg.sender == address(this))
            throw;

         
        if (proposals.length == 1)  
            lastTimeMinQuorumMet = now;

        _proposalID = proposals.length++;
        Proposal p = proposals[_proposalID];
        p.recipient = _recipient;
        p.amount = _amount;
        p.description = _description;
        p.proposalHash = sha3(_recipient, _amount, _transactionData);
        p.votingDeadline = now + _debatingPeriod;
        p.open = true;
         
        p.newCurator = _newCurator;
        if (_newCurator)
            p.splitData.length++;
        p.creator = msg.sender;
        p.proposalDeposit = msg.value;

        sumOfProposalDeposits += msg.value;

        ProposalAdded(
            _proposalID,
            _recipient,
            _amount,
            _newCurator,
            _description
        );
    }


    function checkProposalCode(uint _proposalID, address _recipient, uint _amount, bytes _transactionData) noEther constant returns (bool _codeChecksOut) {
        Proposal p = proposals[_proposalID];
        return p.proposalHash == sha3(_recipient, _amount, _transactionData);
    }


    function vote(uint _proposalID, bool _supportsProposal) onlyTokenholders noEther returns (uint _voteID) {

        Proposal p = proposals[_proposalID];
        if (p.votedYes[msg.sender] || p.votedNo[msg.sender] || now >= p.votingDeadline) {
            throw;
        }

        if (_supportsProposal) {
            p.yea += balances[msg.sender];
            p.votedYes[msg.sender] = true;
        } else {
            p.nay += balances[msg.sender];
            p.votedNo[msg.sender] = true;
        }

        if (blocked[msg.sender] == 0) {
            blocked[msg.sender] = _proposalID;
        } else if (p.votingDeadline > proposals[blocked[msg.sender]].votingDeadline) {
             
             
            blocked[msg.sender] = _proposalID;
        }

        Voted(_proposalID, _supportsProposal, msg.sender);
    }


    function executeProposal(uint _proposalID, bytes _transactionData) noEther returns (bool _success) {

        Proposal p = proposals[_proposalID];

        uint waitPeriod = p.newCurator ? splitExecutionPeriod : executeProposalPeriod;
         
        if (p.open && now > p.votingDeadline + waitPeriod) {
            closeProposal(_proposalID);
            return;
        }

         
        if (now < p.votingDeadline || !p.open || p.proposalHash != sha3(p.recipient, p.amount, _transactionData)) {
            throw;
        }

        if (!isRecipientAllowed(p.recipient)) {
            closeProposal(_proposalID);
            p.creator.send(p.proposalDeposit);
            return;
        }

        bool proposalCheck = true;

        if (p.amount > actualBalance())
            proposalCheck = false;

        uint quorum = p.yea + p.nay;

         
        if (_transactionData.length >= 4 && _transactionData[0] == 0x68
            && _transactionData[1] == 0x37 && _transactionData[2] == 0xff
            && _transactionData[3] == 0x1e
            && quorum < minQuorum(actualBalance() + rewardToken[address(this)])) {

                proposalCheck = false;
        }

        if (quorum >= minQuorum(p.amount)) {
            if (!p.creator.send(p.proposalDeposit))
                throw;

            lastTimeMinQuorumMet = now;
             
            if (quorum > totalSupply / 5)
                minQuorumDivisor = 5;
        }

         
        if (quorum >= minQuorum(p.amount) && p.yea > p.nay && proposalCheck) {
            if (!p.recipient.call.value(p.amount)(_transactionData))
                throw;

            p.proposalPassed = true;
            _success = true;

            if (p.recipient != address(this) && p.recipient != address(rewardAccount)
                && p.recipient != address(DAOrewardAccount)
                && p.recipient != address(extraBalance)
                && p.recipient != address(curator)) {

                rewardToken[address(this)] += p.amount;
                totalRewardToken += p.amount;
            }
        }

        closeProposal(_proposalID);

         
        ProposalTallied(_proposalID, _success, quorum);
    }


    function closeProposal(uint _proposalID) internal {
        Proposal p = proposals[_proposalID];
        if (p.open)
            sumOfProposalDeposits -= p.proposalDeposit;
        p.open = false;
    }

    function splitDAO(uint _proposalID, address _newCurator) noEther onlyTokenholders returns (bool _success) {

        Proposal p = proposals[_proposalID];
        if (now < p.votingDeadline   
             
            || now > p.votingDeadline + splitExecutionPeriod
             
            || p.recipient != _newCurator
             
            || !p.newCurator
             
            || !p.votedYes[msg.sender]
             
            || (blocked[msg.sender] != _proposalID && blocked[msg.sender] != 0) )  {

            throw;
        }

         
         
        if (address(p.splitData[0].newDAO) == 0) {
            p.splitData[0].newDAO = createNewDAO(_newCurator);
             
            if (address(p.splitData[0].newDAO) == 0)
                throw;
             
            if (this.balance < sumOfProposalDeposits)
                throw;
            p.splitData[0].splitBalance = actualBalance();
            p.splitData[0].rewardToken = rewardToken[address(this)];
            p.splitData[0].totalSupply = totalSupply;
            p.proposalPassed = true;
        }

         
        uint fundsToBeMoved = (balances[msg.sender] * p.splitData[0].splitBalance) /
            p.splitData[0].totalSupply;
        if (p.splitData[0].newDAO.createTokenProxy.value(fundsToBeMoved)(msg.sender) == false)
            throw;

        uint rewardTokenToBeMoved = (balances[msg.sender] * p.splitData[0].rewardToken) /
            p.splitData[0].totalSupply;

        uint paidOutToBeMoved = DAOpaidOut[address(this)] * rewardTokenToBeMoved /
            rewardToken[address(this)];

        rewardToken[address(p.splitData[0].newDAO)] += rewardTokenToBeMoved;
        if (rewardToken[address(this)] < rewardTokenToBeMoved)
            throw;
        rewardToken[address(this)] -= rewardTokenToBeMoved;

        DAOpaidOut[address(p.splitData[0].newDAO)] += paidOutToBeMoved;
        if (DAOpaidOut[address(this)] < paidOutToBeMoved)
            throw;
        DAOpaidOut[address(this)] -= paidOutToBeMoved;

         
        Transfer(msg.sender, 0, balances[msg.sender]);
        withdrawRewardFor(msg.sender);  
        totalSupply -= balances[msg.sender];
        balances[msg.sender] = 0;
        paidOut[msg.sender] = 0;
        return true;
    }

    function newContract(address _newContract){
        if (msg.sender != address(this) || !allowedRecipients[_newContract]) return;
         
        if (!_newContract.call.value(address(this).balance)()) {
            throw;
        }

         
        rewardToken[_newContract] += rewardToken[address(this)];
        rewardToken[address(this)] = 0;
        DAOpaidOut[_newContract] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }


    function retrieveDAOReward(bool _toMembers) external noEther returns (bool _success) {
        MICRODAO dao = MICRODAO(msg.sender);

        if ((rewardToken[msg.sender] * DAOrewardAccount.accumulatedInput()) /
            totalRewardToken < DAOpaidOut[msg.sender])
            throw;

        uint reward = (rewardToken[msg.sender] * DAOrewardAccount.accumulatedInput()) /
            totalRewardToken - DAOpaidOut[msg.sender];

        reward = DAOrewardAccount.balance < reward ? DAOrewardAccount.balance : reward;

        if(_toMembers) {
            if (!DAOrewardAccount.payOut(dao.rewardAccount(), reward))
                throw;
            }
        else {
            if (!DAOrewardAccount.payOut(dao, reward))
                throw;
        }
        DAOpaidOut[msg.sender] += reward;
        return true;
    }

    function getMyReward() noEther returns (bool _success) {
        return withdrawRewardFor(msg.sender);
    }


    function withdrawRewardFor(address _account) noEther internal returns (bool _success) {
        if ((balanceOf(_account) * rewardAccount.accumulatedInput()) / totalSupply < paidOut[_account])
            throw;

        uint reward = (balanceOf(_account) * rewardAccount.accumulatedInput()) / totalSupply - paidOut[_account];

        reward = rewardAccount.balance < reward ? rewardAccount.balance : reward;

        if (!rewardAccount.payOut(_account, reward))
            throw;
        paidOut[_account] += reward;
        return true;
    }


    function transfer(address _to, uint256 _value) returns (bool success) {
        if (isFueled
            && now > closingTime
            && !isBlocked(msg.sender)
            && transferPaidOut(msg.sender, _to, _value)
            && super.transfer(_to, _value)) {

            return true;
        } else {
            throw;
        }
    }


    function transferWithoutReward(address _to, uint256 _value) returns (bool success) {
        if (!getMyReward())
            throw;
        return transfer(_to, _value);
    }


    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (isFueled
            && now > closingTime
            && !isBlocked(_from)
            && transferPaidOut(_from, _to, _value)
            && super.transferFrom(_from, _to, _value)) {

            return true;
        } else {
            throw;
        }
    }


    function transferFromWithoutReward(address _from, address _to, uint256 _value) returns (bool success) {

        if (!withdrawRewardFor(_from))
            throw;
        return transferFrom(_from, _to, _value);
    }


    function transferPaidOut(address _from, address _to, uint256 _value) internal returns (bool success) {

        uint transferPaidOut = paidOut[_from] * _value / balanceOf(_from);
        if (transferPaidOut > paidOut[_from])
            throw;
        paidOut[_from] -= transferPaidOut;
        paidOut[_to] += transferPaidOut;
        return true;
    }


    function changeProposalDeposit(uint _proposalDeposit) noEther external {
        if (msg.sender != address(this) || _proposalDeposit > (actualBalance() + rewardToken[address(this)])
            / maxDepositDivisor) {
            throw;
        }
        proposalDeposit = _proposalDeposit;
    }


    function changeAllowedRecipients(address _recipient, bool _allowed) noEther external returns (bool _success) {
        if (msg.sender != curator)
            throw;
        allowedRecipients[_recipient] = _allowed;
        AllowedRecipientChanged(_recipient, _allowed);
        return true;
    }


    function isRecipientAllowed(address _recipient) internal returns (bool _isAllowed) {
        if (allowedRecipients[_recipient] || (_recipient == address(extraBalance) && totalRewardToken > extraBalance.accumulatedInput()))
            return true;
        else
            return false;
    }

    function actualBalance() constant returns (uint _actualBalance) {
        return this.balance - sumOfProposalDeposits;
    }


    function minQuorum(uint _value) internal constant returns (uint _minQuorum) {
         
        return totalSupply / minQuorumDivisor +
            (_value * totalSupply) / (3 * (actualBalance() + rewardToken[address(this)]));
    }


    function halveMinQuorum() returns (bool _success) {

        if ((lastTimeMinQuorumMet < (now - quorumHalvingPeriod) || msg.sender == curator)
            && lastTimeMinQuorumMet < (now - minProposalDebatePeriod)
            && now >= closingTime
            && proposals.length > 1) {
            lastTimeMinQuorumMet = now;
            minQuorumDivisor *= 2;
            return true;
        } else {
            return false;
        }
    }

    function createNewDAO(address _newCurator) internal returns (MICRODAO _newDAO) {
        NewCurator(_newCurator);
        return daoCreator.createDAO(_newCurator, 0, 0, now + splitExecutionPeriod);
    }

    function numberOfProposals() constant returns (uint _numberOfProposals) {
         
        return proposals.length - 1;
    }

    function getNewDAOAddress(uint _proposalID) constant returns (address _newDAO) {
        return proposals[_proposalID].splitData[0].newDAO;
    }

    function isBlocked(address _account) internal returns (bool) {
        if (blocked[_account] == 0)
            return false;
        Proposal p = proposals[blocked[_account]];
        if (now > p.votingDeadline) {
            blocked[_account] = 0;
            return false;
        } else {
            return true;
        }
    }

    function unblockMe() returns (bool) {
        return isBlocked(msg.sender);
    }
}

contract DAO_Creator {
    function createDAO(address _curator, uint _proposalDeposit, uint _minTokensToCreate, uint _closingTime) returns (MICRODAO _newDAO) {

        return new MICRODAO(_curator, DAO_Creator(this), _proposalDeposit, _minTokensToCreate, _closingTime, msg.sender);
    }
}