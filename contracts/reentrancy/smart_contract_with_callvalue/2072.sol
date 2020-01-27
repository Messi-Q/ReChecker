pragma solidity ^0.4.16;
 
 
 
 
 
 
 
 
 
 

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract tokenRecipient {
    event receivedEther(address sender, uint amount);
    event receivedTokens(address _from, uint256 _value, address _token, bytes _extraData);

    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public {
        Token t = Token(_token);
        require(t.transferFrom(_from, this, _value));
        emit receivedTokens(_from, _value, _token, _extraData);
    }

    function () payable public {
        emit receivedEther(msg.sender, msg.value);
    }
}

contract Token {
    mapping (address => uint256) public balanceOf;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

 
contract Association is owned, tokenRecipient {

    uint public minimumQuorum;
    uint public debatingPeriodInMinutes;
    Proposal[] public proposals;
    uint public numProposals;
    Token public sharesTokenAddress;

    event ProposalAdded(uint proposalID, address recipient, uint amount, string description);
    event Voted(uint proposalID, bool position, address voter);
    event ProposalTallied(uint proposalID, uint result, uint quorum, bool active);
    event ChangeOfRules(uint newMinimumQuorum, uint newDebatingPeriodInMinutes, address newSharesTokenAddress);

    struct Proposal {
        address recipient;
        uint amount;
        string description;
        uint minExecutionDate;
        bool executed;
        bool proposalPassed;
        uint numberOfVotes;
        bytes32 proposalHash;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Vote {
        bool inSupport;
        address voter;
    }

     
    modifier onlyShareholders {
        require(sharesTokenAddress.balanceOf(msg.sender) > 0);
        _;
    }

     
    constructor(Token sharesAddress, uint minimumSharesToPassAVote, uint minutesForDebate) payable public {
        changeVotingRules(sharesAddress, minimumSharesToPassAVote, minutesForDebate);
    }

     
    function changeVotingRules(Token sharesAddress, uint minimumSharesToPassAVote, uint minutesForDebate) onlyOwner public {
        sharesTokenAddress = Token(sharesAddress);
        if (minimumSharesToPassAVote == 0 ) minimumSharesToPassAVote = 1;
        minimumQuorum = minimumSharesToPassAVote;
        debatingPeriodInMinutes = minutesForDebate;
        emit ChangeOfRules(minimumQuorum, debatingPeriodInMinutes, sharesTokenAddress);
    }

     
    function newProposal(
        address beneficiary,
        uint weiAmount,
        string jobDescription,
        bytes transactionBytecode
    )
        onlyShareholders public
        returns (uint proposalID)
    {
        proposalID = proposals.length++;
        Proposal storage p = proposals[proposalID];
        p.recipient = beneficiary;
        p.amount = weiAmount;
        p.description = jobDescription;
        p.proposalHash = keccak256(abi.encodePacked(beneficiary, weiAmount, transactionBytecode));
        p.minExecutionDate = now + debatingPeriodInMinutes * 1 minutes;
        p.executed = false;
        p.proposalPassed = false;
        p.numberOfVotes = 0;
        emit ProposalAdded(proposalID, beneficiary, weiAmount, jobDescription);
        numProposals = proposalID+1;

        return proposalID;
    }

     
    function newProposalInEther(
        address beneficiary,
        uint etherAmount,
        string jobDescription,
        bytes transactionBytecode
    )
        onlyShareholders public
        returns (uint proposalID)
    {
        return newProposal(beneficiary, etherAmount * 1 ether, jobDescription, transactionBytecode);
    }

     
    function checkProposalCode(
        uint proposalNumber,
        address beneficiary,
        uint weiAmount,
        bytes transactionBytecode
    )
        constant public
        returns (bool codeChecksOut)
    {
        Proposal storage p = proposals[proposalNumber];
        return p.proposalHash == keccak256(abi.encodePacked(beneficiary, weiAmount, transactionBytecode));
    }

     
    function vote(
        uint proposalNumber,
        bool supportsProposal
    )
        onlyShareholders public
        returns (uint voteID)
    {
        Proposal storage p = proposals[proposalNumber];
        require(p.voted[msg.sender] != true);

        voteID = p.votes.length++;
        p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
        p.voted[msg.sender] = true;
        p.numberOfVotes = voteID +1;
        emit Voted(proposalNumber,  supportsProposal, msg.sender);
        return voteID;
    }

     
    function executeProposal(uint proposalNumber, bytes transactionBytecode) public {
        Proposal storage p = proposals[proposalNumber];

        require(now > p.minExecutionDate && !p.executed && p.proposalHash == keccak256(abi.encodePacked(p.recipient, p.amount, transactionBytecode)));


         
        uint quorum = 0;
        uint yea = 0;
        uint nay = 0;

        for (uint i = 0; i <  p.votes.length; ++i) {
            Vote storage v = p.votes[i];
            uint voteWeight = sharesTokenAddress.balanceOf(v.voter);
            quorum += voteWeight;
            if (v.inSupport) {
                yea += voteWeight;
            } else {
                nay += voteWeight;
            }
        }

        require(quorum >= minimumQuorum);  

        if (yea > nay ) {
             

            p.executed = true;
            require(p.recipient.call.value(p.amount)(transactionBytecode));

            p.proposalPassed = true;
        } else {
             
            p.proposalPassed = false;
        }

         
        emit ProposalTallied(proposalNumber, yea - nay, quorum, p.proposalPassed);
    }
}