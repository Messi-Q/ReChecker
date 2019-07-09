pragma solidity 0.4.23;

 
contract Ownable {
  address public owner;

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);

    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract Proxied is Ownable {
    address public target;
    mapping (address => bool) public initialized;

    event EventUpgrade(address indexed newTarget, address indexed oldTarget, address indexed admin);
    event EventInitialized(address indexed target);

    function upgradeTo(address _target) public;
}

contract Upgradeable is Proxied {
     
    modifier initializeOnceOnly() {
         if(!initialized[target]) {
             initialized[target] = true;
             emit EventInitialized(target);
             _;
         } else revert();
     }

     
    function upgradeTo(address) public {
        assert(false);
    }

     
    function initialize() initializeOnceOnly public {
         
    }
}

 
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


   
  modifier whenNotPaused() {
    require (!paused);
    _;
  }

   
  modifier whenPaused {
    require (paused) ;
    _;
  }

   
  function pause() onlyOwner whenNotPaused public returns (bool) {
    paused = true;
    Pause();
    return true;
  }

   
  function unpause() onlyOwner whenPaused public returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

interface IClaims  {

    event ClaimCreated(uint indexed claimId);

    function createClaim(address[] _voters, uint _votingDeadline,
    address _claimantAddress) external;

    function castVote(uint _claimId, uint _pType, bytes32 _hash, string _url,
    bytes32 _tokenHash) external;
    
    function register(uint _claimId, uint _pType, bytes32 _hash, string _url,
    bytes32 _tokenHash) external;
}

contract NaiveClaims is Upgradeable, Pausable, IClaims  {

    struct Claim {
        address[] voters;
        mapping(address => Vote) votes;
        address claimantAddress;
        uint votingDeadline;
    }

    struct Vote {
        uint pType;
        bytes32 hash;
        string url;
        bool exists;
        bytes32 tokenHash;
    }

    mapping (uint => Claim) public claims;
    event ClaimCreated(uint indexed claimId);
    uint256 public claimsCreated;

     
    function createClaim(address[] _voters, uint _votingDeadline, address _claimantAddress) external whenNotPaused {

        claims[claimsCreated].voters = _voters;
        claims[claimsCreated].claimantAddress = _claimantAddress;
        claims[claimsCreated].votingDeadline = _votingDeadline;

        emit ClaimCreated(claimsCreated);
        claimsCreated++;
    }

     
    function castVote(uint _claimId, uint _pType, bytes32 _hash, string _url,
    bytes32 _tokenHash) external {
        Claim storage claim = claims[_claimId];
        Vote storage vote = claim.votes[msg.sender];

        require(vote.exists != true, "Voters can only vote once");
        require(now < claim.votingDeadline, "Cannot vote after the dealine has passed");

        claims[_claimId].votes[msg.sender] = Vote(_pType, _hash, _url, true, _tokenHash);
    }

    function getVote(uint _claimId, address _voter)  constant external returns (uint ,bytes32,
    string ,bool ,bytes32){
        return (claims[_claimId].votes[_voter].pType,
        claims[_claimId].votes[_voter].hash,
        claims[_claimId].votes[_voter].url,
        claims[_claimId].votes[_voter].exists,
        claims[_claimId].votes[_voter].tokenHash);
    }

    function getVoter(uint _claimId, uint _index) external constant returns (address) {
        return claims[_claimId].voters[_index];
    }

    function getVoterCount(uint _claimId) external constant returns (uint) {
        return claims[_claimId].voters.length;
    }

    function initialize() initializeOnceOnly public {
        claimsCreated = 0;  
    }

    function register(uint _claimId, uint _pType, bytes32 _hash, string _url,
    bytes32 _tokenHash) external {
        revert("Unsupported operation");
    }
}

contract NaiveTallyCalculator {
    
    bytes32 public yesHash = keccak256("YES");
    bytes32 public noHash = keccak256("NO");

    function calculateTally(address _claimsAddress, uint _claimId) constant returns (bool) {
        NaiveClaims claimsContract = NaiveClaims(_claimsAddress);
    
        uint votingDeadline;
        (,votingDeadline) = claimsContract.claims(_claimId);

        uint voterCount = claimsContract.getVoterCount(_claimId);
        require(votingDeadline < now);

        uint indorsements;

        for (uint voterIndex = 0; voterIndex < voterCount; voterIndex++) {
            address voter = claimsContract.getVoter(_claimId, voterIndex);
            
            var (, hash,,voteExists,) = claimsContract.getVote(_claimId, voter);

            if (voteExists == true) {
                if (hash == yesHash) {
                    indorsements++;
                }
            }
        }

        return indorsements > 5;
    }
}