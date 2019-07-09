14169.sol
function sign(string _documentHash) public {
signatureMap[_documentHash].push(msg.sender);
function sign(string _documentHash) public {
signatureMap[_documentHash].push(msg.sender);
function sign(string _documentHash) public {
signatureMap[_documentHash].push(msg.sender);
function getSignatureAtIndex(string _documentHash, uint _index) public constant returns (address) {
return signatureMap[_documentHash][_index];
function getSignatureAtIndex(string _documentHash, uint _index) public constant returns (address) {
return signatureMap[_documentHash][_index];
function getSignatureAtIndex(string _documentHash, uint _index) public constant returns (address) {
return signatureMap[_documentHash][_index];
function getSignatures(string _documentHash) public constant returns (address[]) {
return signatureMap[_documentHash];
function getSignatures(string _documentHash) public constant returns (address[]) {
return signatureMap[_documentHash];
function getSignatures(string _documentHash) public constant returns (address[]) {
return signatureMap[_documentHash];
function getSignatures(string _documentHash) public constant returns (address[]) {
return signatureMap[_documentHash];
