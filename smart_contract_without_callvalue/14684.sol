pragma solidity ^0.4.21;

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
    function Ownable() public {
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

contract Vote is Ownable {
     
    event CandidateRegistered(uint candidateId, string candidateName, string candidateDescription);
     
    event VoteCast(uint candidateId);

    struct Candidate {
        uint candidateId;
        string candidateName;
        string candidateDescription;
    }

    uint internal salt;
    string public voteName;
    uint public totalVotes;

     
    mapping (uint => uint) public voteCount;
     
    mapping (bytes32 => bool) internal canVote;
     
    uint public nextCandidateId = 1;
    mapping (uint => Candidate) public candidateDirectory;

    function Vote(uint _salt, string _voteName, bytes32[] approvedHashes) public {
        salt = _salt;
        voteName = _voteName;
        totalVotes = approvedHashes.length;
        for (uint i; i < approvedHashes.length; i++) {
            canVote[approvedHashes[i]] = true;
        }
    }

     
    function registerCandidate(string candidateName, string candidateDescription) public onlyOwner {
        uint candidateId = nextCandidateId++;
        candidateDirectory[candidateId] = Candidate(candidateId, candidateName, candidateDescription);
        emit CandidateRegistered(candidateId, candidateName, candidateDescription);
    }

     
    function candidateInformation(uint candidateId) public view returns (string name, string description) {
        Candidate storage candidate = candidateDirectory[candidateId];
        return (candidate.candidateName, candidate.candidateDescription);
    }

     
    function castVote(uint secret, uint candidateId) public {
        bytes32 claimedApprovedHash = keccak256(secret, salt);  
        require(canVote[claimedApprovedHash]);
        canVote[claimedApprovedHash] = false;
        voteCount[candidateId] += 1;

        emit VoteCast(candidateId);
    }
}