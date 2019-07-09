 
pragma solidity ^0.4.0;

 
contract Percept {

    mapping(bytes32 => Proof) public proofs;     

    struct Proof {               
         
        address creator;         
        bytes32 hash;            
        uint timestamp;          
        uint blockNum;           
        bytes32 proofMapping;    

         
        string release;          
        bool released;           
        uint releaseTime;        
        uint releaseBlockNum;    
    }

     
     
    function submitProof(bytes32 hash) public returns (bytes32) {
        uint timestamp = now;    
        uint blockNum = block.number;    

        bytes32 proofMapping = keccak256(abi.encodePacked(msg.sender, timestamp, blockNum, hash));     

         
        Proof memory proof = Proof(msg.sender, hash, timestamp, blockNum, proofMapping, "", false, 0, 0);

         
        proofs[proofMapping] = proof;
        
        return proofMapping;  
    }

     
     
     
    function releaseProof(bytes32 proofMapping, string release) public {
         
        Proof storage proof = proofs[proofMapping];

        require(msg.sender == proof.creator);        
        require(proof.hash == keccak256(abi.encodePacked(release)));   
        require(!proof.released);                    

        proof.release = release;                 
        proof.released = true;                   
        proof.releaseTime = now;                 
        proof.releaseBlockNum = block.number;    
    }

     
     
     
     
    function isValidProof(bytes32 proofMapping, string verify) public view returns (bool) {
        Proof memory proof = proofs[proofMapping];  

        require(proof.creator != 0);  

        return proof.hash == keccak256(abi.encodePacked(verify));  
    }

     
     
     
    function retrieveIncompleteProof(bytes32 proofMapping) public view returns (
        address creator,
        bytes32 hash,
        uint timestamp,
        uint blockNum
    ) {
        Proof memory proof = proofs[proofMapping];   
        require(proof.creator != 0);                 
        require(!proof.released);                    

         
        return (
            proof.creator,
            proof.hash,
            proof.timestamp,
            proof.blockNum
        );
    }

     
     
     
    function retrieveCompletedProof(bytes32 proofMapping) public view returns (
        address creator,
        string release,
        bytes32 hash,
        uint timestamp,
        uint releaseTime,
        uint blockNum,
        uint releaseBlockNum
    ) {
        Proof memory proof = proofs[proofMapping];   
        require(proof.creator != 0);                 
        require(proof.released);                     

         
        return (
            proof.creator,
            proof.release,
            proof.hash,
            proof.timestamp,
            proof.releaseTime,
            proof.blockNum,
            proof.releaseBlockNum
        );
    }

}