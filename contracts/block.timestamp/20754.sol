// WELCOME TO THE EOSBET.IO BUG BOUNTY CONTRACTS!
// GOOD LUCK... YOU'LL NEED IT!

pragma solidity ^0.4.21;

// <ORACLIZE_API>
/*
Copyright (c) 2015-2016 Oraclize SRL
Copyright (c) 2016 Oraclize LTD



Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

// This api is currently targeted at 0.4.18, please import oraclizeAPI_pre0.4.sol or oraclizeAPI_0.4 where necessary
pragma solidity ^0.4.18;

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);
    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);
    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);
    function getPrice(string _datasource) public returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);
    function setProofType(byte _proofType) external;
    function setCustomGasPrice(uint _gasPrice) external;
    function randomDS_getSessionPubKeyHash() external constant returns(bytes32);
}
contract OraclizeAddrResolverI {
    function getAddress() public returns (address _addr);
}
contract usingOraclize {
    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofType_Android = 0x20;
    byte constant proofType_Ledger = 0x30;
    byte constant proofType_Native = 0xF0;
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;

    OraclizeI oraclize;
    modifier oraclizeAPI {
        if((address(OAR)==0)||(getCodeSize(address(OAR))==0))
            oraclize_setNetwork(networkID_auto);

        if(address(oraclize) != OAR.getAddress())
            oraclize = OraclizeI(OAR.getAddress());

        _;
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        _;
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
      return oraclize_setNetwork();
      networkID; // silence the warning and remain backwards compatible
    }
    function oraclize_setNetwork() internal returns(bool){
        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
            oraclize_setNetworkName("eth_mainnet");
            return true;
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
            oraclize_setNetworkName("eth_ropsten3");
            return true;
        }
        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet
            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
            oraclize_setNetworkName("eth_kovan");
            return true;
        }
        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet
            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
            oraclize_setNetworkName("eth_rinkeby");
            return true;
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
            return true;
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide
            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
            return true;
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity
            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
            return true;
        }
        return false;
    }

    function __callback(bytes32 myid, string result) public {
        __callback(myid, result, new bytes(0));
    }
    function __callback(bytes32 myid, string result, bytes proof) public {
      return;
      myid; result; proof; // Silence compiler warnings
    }

    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource);
    }

    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource, gaslimit);
    }

    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        return oraclize.setProofType(proofP);
    }
    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {
        return oraclize.setCustomGasPrice(gasPrice);
    }

    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){
        return oraclize.randomDS_getSessionPubKeyHash();
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }

    function parseAddr(string _a) internal pure returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }

    function strCompare(string _a, string _b) internal pure returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

    function indexOf(string _haystack, string _needle) internal pure returns (int) {
        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if(h.length < 1 || n.length < 1 || (n.length > h.length))
            return -1;
        else if(h.length > (2**128 -1))
            return -1;
        else
        {
            uint subindex = 0;
            for (uint i = 0; i < h.length; i ++)
            {
                if (h[i] == n[0])
                {
                    subindex = 1;
                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])
                    {
                        subindex++;
                    }
                    if(subindex == n.length)
                        return int(i);
                }
            }
            return -1;
        }
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal pure returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal pure returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    // parseInt
    function parseInt(string _a) internal pure returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal pure returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10**_b;
        return mint;
    }

    function uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    function stra2cbor(string[] arr) internal pure returns (bytes) {
            uint arrlen = arr.length;

            // get correct cbor output length
            uint outputlen = 0;
            bytes[] memory elemArray = new bytes[](arrlen);
            for (uint i = 0; i < arrlen; i++) {
                elemArray[i] = (bytes(arr[i]));
                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types
            }
            uint ctr = 0;
            uint cborlen = arrlen + 0x80;
            outputlen += byte(cborlen).length;
            bytes memory res = new bytes(outputlen);

            while (byte(cborlen).length > ctr) {
                res[ctr] = byte(cborlen)[ctr];
                ctr++;
            }
            for (i = 0; i < arrlen; i++) {
                res[ctr] = 0x5F;
                ctr++;
                for (uint x = 0; x < elemArray[i].length; x++) {
                    // if there's a bug with larger strings, this may be the culprit
                    if (x % 23 == 0) {
                        uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
                        elemcborlen += 0x40;
                        uint lctr = ctr;
                        while (byte(elemcborlen).length > ctr - lctr) {
                            res[ctr] = byte(elemcborlen)[ctr - lctr];
                            ctr++;
                        }
                    }
                    res[ctr] = elemArray[i][x];
                    ctr++;
                }
                res[ctr] = 0xFF;
                ctr++;
            }
            return res;
        }

    function ba2cbor(bytes[] arr) internal pure returns (bytes) {
            uint arrlen = arr.length;

            // get correct cbor output length
            uint outputlen = 0;
            bytes[] memory elemArray = new bytes[](arrlen);
            for (uint i = 0; i < arrlen; i++) {
                elemArray[i] = (bytes(arr[i]));
                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types
            }
            uint ctr = 0;
            uint cborlen = arrlen + 0x80;
            outputlen += byte(cborlen).length;
            bytes memory res = new bytes(outputlen);

            while (byte(cborlen).length > ctr) {
                res[ctr] = byte(cborlen)[ctr];
                ctr++;
            }
            for (i = 0; i < arrlen; i++) {
                res[ctr] = 0x5F;
                ctr++;
                for (uint x = 0; x < elemArray[i].length; x++) {
                    // if there's a bug with larger strings, this may be the culprit
                    if (x % 23 == 0) {
                        uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
                        elemcborlen += 0x40;
                        uint lctr = ctr;
                        while (byte(elemcborlen).length > ctr - lctr) {
                            res[ctr] = byte(elemcborlen)[ctr - lctr];
                            ctr++;
                        }
                    }
                    res[ctr] = elemArray[i][x];
                    ctr++;
                }
                res[ctr] = 0xFF;
                ctr++;
            }
            return res;
        }


    string oraclize_network_name;
    function oraclize_setNetworkName(string _network_name) internal {
        oraclize_network_name = _network_name;
    }

    function oraclize_getNetworkName() internal view returns (string) {
        return oraclize_network_name;
    }

    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){
        require((_nbytes > 0) && (_nbytes <= 32));
        // Convert from seconds to ledger timer ticks
        _delay *= 10; 
        bytes memory nbytes = new bytes(1);
        nbytes[0] = byte(_nbytes);
        bytes memory unonce = new bytes(32);
        bytes memory sessionKeyHash = new bytes(32);
        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();
        assembly {
            mstore(unonce, 0x20)
            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))
            mstore(sessionKeyHash, 0x20)
            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)
        }
        bytes memory delay = new bytes(32);
        assembly { 
            mstore(add(delay, 0x20), _delay) 
        }
        
        bytes memory delay_bytes8 = new bytes(8);
        copyBytes(delay, 24, 8, delay_bytes8, 0);

        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];
        bytes32 queryId = oraclize_query("random", args, _customGasLimit);
        
        bytes memory delay_bytes8_left = new bytes(8);
        
        assembly {
            let x := mload(add(delay_bytes8, 0x20))
            mstore8(add(delay_bytes8_left, 0x27), div(x, 0x100000000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x26), div(x, 0x1000000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x25), div(x, 0x10000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x24), div(x, 0x100000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x23), div(x, 0x1000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x22), div(x, 0x10000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x21), div(x, 0x100000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x20), div(x, 0x1000000000000000000000000000000000000000000000000))

        }
        
        oraclize_randomDS_setCommitment(queryId, keccak256(delay_bytes8_left, args[1], sha256(args[0]), args[2]));
        return queryId;
    }
    
    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {
        oraclize_randomDS_args[queryId] = commitment;
    }

    mapping(bytes32=>bytes32) oraclize_randomDS_args;
    mapping(bytes32=>bool) oraclize_randomDS_sessionKeysHashVerified;

    function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){
        bool sigok;
        address signer;

        bytes32 sigr;
        bytes32 sigs;

        bytes memory sigr_ = new bytes(32);
        uint offset = 4+(uint(dersig[3]) - 0x20);
        sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);
        bytes memory sigs_ = new bytes(32);
        offset += 32 + 2;
        sigs_ = copyBytes(dersig, offset+(uint(dersig[offset-1]) - 0x20), 32, sigs_, 0);

        assembly {
            sigr := mload(add(sigr_, 32))
            sigs := mload(add(sigs_, 32))
        }


        (sigok, signer) = safer_ecrecover(tosignh, 27, sigr, sigs);
        if (address(keccak256(pubkey)) == signer) return true;
        else {
            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);
            return (address(keccak256(pubkey)) == signer);
        }
    }

    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes proof, uint sig2offset) internal returns (bool) {
        bool sigok;

        // Step 6: verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)
        bytes memory sig2 = new bytes(uint(proof[sig2offset+1])+2);
        copyBytes(proof, sig2offset, sig2.length, sig2, 0);

        bytes memory appkey1_pubkey = new bytes(64);
        copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);

        bytes memory tosign2 = new bytes(1+65+32);
        tosign2[0] = byte(1); //role
        copyBytes(proof, sig2offset-65, 65, tosign2, 1);
        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";
        copyBytes(CODEHASH, 0, 32, tosign2, 1+65);
        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);

        if (sigok == false) return false;


        // Step 7: verify the APPKEY1 provenance (must be signed by Ledger)
        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";

        bytes memory tosign3 = new bytes(1+65);
        tosign3[0] = 0xFE;
        copyBytes(proof, 3, 65, tosign3, 1);

        bytes memory sig3 = new bytes(uint(proof[3+65+1])+2);
        copyBytes(proof, 3+65, sig3.length, sig3, 0);

        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);

        return sigok;
    }

    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {
        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)
        require((_proof[0] == "L") && (_proof[1] == "P") && (_proof[2] == 1));

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        require(proofVerified);

        _;
    }

    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){
        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)
        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        if (proofVerified == false) return 2;

        return 0;
    }

    function matchBytes32Prefix(bytes32 content, bytes prefix, uint n_random_bytes) internal pure returns (bool){
        bool match_ = true;
        
        require(prefix.length == n_random_bytes);

        for (uint256 i=0; i< n_random_bytes; i++) {
            if (content[i] != prefix[i]) match_ = false;
        }

        return match_;
    }

    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){

        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)
        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;
        bytes memory keyhash = new bytes(32);
        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);
        if (!(keccak256(keyhash) == keccak256(sha256(context_name, queryId)))) return false;

        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);
        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);

        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)
        if (!matchBytes32Prefix(sha256(sig1), result, uint(proof[ledgerProofLength+32+8]))) return false;

        // Step 4: commitment match verification, keccak256(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.
        // This is to verify that the computed args match with the ones specified in the query.
        bytes memory commitmentSlice1 = new bytes(8+1+32);
        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);

        bytes memory sessionPubkey = new bytes(64);
        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;
        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);

        bytes32 sessionPubkeyHash = sha256(sessionPubkey);
        if (oraclize_randomDS_args[queryId] == keccak256(commitmentSlice1, sessionPubkeyHash)){ //unonce, nbytes and sessionKeyHash match
            delete oraclize_randomDS_args[queryId];
        } else return false;


        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)
        bytes memory tosign1 = new bytes(32+8+1+32);
        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);
        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) return false;

        // verify if sessionPubkeyHash was verified already, if not.. let's do it!
        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){
            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);
        }

        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal pure returns (bytes) {
        uint minLength = length + toOffset;

        // Buffer too small
        require(to.length >= minLength); // Should be a better way?

        // NOTE: the offset 32 is added to skip the `size` field of both bytes variables
        uint i = 32 + fromOffset;
        uint j = 32 + toOffset;

        while (i < (32 + fromOffset + length)) {
            assembly {
                let tmp := mload(add(from, i))
                mstore(add(to, j), tmp)
            }
            i += 32;
            j += 32;
        }

        return to;
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    // Duplicate Solidity's ecrecover, but catching the CALL return value
    function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {
        // We do our own memory management here. Solidity uses memory offset
        // 0x40 to store the current end of memory. We write past it (as
        // writes are memory extensions), but don't update the offset so
        // Solidity will reuse it. The memory used here is only needed for
        // this context.

        // FIXME: inline assembly can't access return values
        bool ret;
        address addr;

        assembly {
            let size := mload(0x40)
            mstore(size, hash)
            mstore(add(size, 32), v)
            mstore(add(size, 64), r)
            mstore(add(size, 96), s)

            // NOTE: we can reuse the request memory because we deal with
            //       the return code
            ret := call(3000, 1, 0, size, 128, size, 32)
            addr := mload(size)
        }

        return (ret, addr);
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65)
          return (false, 0);

        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))

            // Here we are loading the last 32 bytes. We exploit the fact that
            // 'mload' will pad with zeroes if we overread.
            // There is no 'mload8' to do this, but that would be nicer.
            v := byte(0, mload(add(sig, 96)))

            // Alternative solution:
            // 'byte' is not working due to the Solidity parser, so lets
            // use the second best option, 'and'
            // v := and(mload(add(sig, 65)), 255)
        }

        // albeit non-transactional signatures are not specified by the YP, one would expect it
        // to match the YP range of [27, 28]
        //
        // geth uses [0, 1] and some clients have followed. This might change, see:
        //  https://github.com/ethereum/go-ethereum/issues/2053
        if (v < 27)
          v += 27;

        if (v != 27 && v != 28)
            return (false, 0);

        return safer_ecrecover(hash, v, r, s);
    }

}
// </ORACLIZE_API>

contract EOSBetGameInterface {
	uint256 public DEVELOPERSFUND;
	uint256 public LIABILITIES;
	function payDevelopersFund(address developer) public;
	function receivePaymentForOraclize() payable public;
	function getMaxWin() public view returns(uint256);
}

contract EOSBetBankrollInterface {
	function payEtherToWinner(uint256 amtEther, address winner) public;
	function receiveEtherFromGameAddress() payable public;
	function payOraclize(uint256 amountToPay) public;
	function getBankroll() public view returns(uint256);
}

contract ERC20 {
	function totalSupply() constant public returns (uint supply);
	function balanceOf(address _owner) constant public returns (uint balance);
	function transfer(address _to, uint _value) public returns (bool success);
	function transferFrom(address _from, address _to, uint _value) public returns (bool success);
	function approve(address _spender, uint _value) public returns (bool success);
	function allowance(address _owner, address _spender) constant public returns (uint remaining);
	event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract EOSBetBankroll is ERC20, EOSBetBankrollInterface {

	using SafeMath for *;

	// constants for EOSBet Bankroll

	address public OWNER;
	uint256 public MAXIMUMINVESTMENTSALLOWED;
	uint256 public WAITTIMEUNTILWITHDRAWORTRANSFER;
	uint256 public DEVELOPERSFUND;

	// this will be initialized as the trusted game addresses which will forward their ether
	// to the bankroll contract, and when players win, they will request the bankroll contract 
	// to send these players their winnings.
	// Feel free to audit these contracts on etherscan...
	mapping(address => bool) public TRUSTEDADDRESSES;

	address public DICE;
	address public SLOTS;

	// mapping to log the last time a user contributed to the bankroll 
	mapping(address => uint256) contributionTime;

	// constants for ERC20 standard
	string public constant name = "EOSBet Stake Tokens";
	string public constant symbol = "EOSBETST";
	uint8 public constant decimals = 18;
	// variable total supply
	uint256 public totalSupply;

	// mapping to store tokens
	mapping(address => uint256) public balances;
	mapping(address => mapping(address => uint256)) public allowed;

	// events
	event FundBankroll(address contributor, uint256 etherContributed, uint256 tokensReceived);
	event CashOut(address contributor, uint256 etherWithdrawn, uint256 tokensCashedIn);
	event FailedSend(address sendTo, uint256 amt);

	// checks that an address is a "trusted address of a legitimate EOSBet game"
	modifier addressInTrustedAddresses(address thisAddress){

		require(TRUSTEDADDRESSES[thisAddress]);
		_;
	}

	// initialization function 
	function EOSBetBankroll(address dice, address slots) public payable {
		// function is payable, owner of contract MUST "seed" contract with some ether, 
		// so that the ratios are correct when tokens are being minted
		require (msg.value > 0);

		OWNER = msg.sender;

		// 100 tokens/ether is the inital seed amount, so:
		uint256 initialTokens = msg.value * 100;
		balances[msg.sender] = initialTokens;
		totalSupply = initialTokens;

		// log a mint tokens event
		emit Transfer(0x0, msg.sender, initialTokens);

		// insert given game addresses into the TRUSTEDADDRESSES mapping, and save the addresses as global variables
		TRUSTEDADDRESSES[dice] = true;
		TRUSTEDADDRESSES[slots] = true;

		DICE = dice;
		SLOTS = slots;

		////////////////////////////////////////////////
		// CHANGE TO 6 HOURS ON LIVE DEPLOYMENT
		////////////////////////////////////////////////
		WAITTIMEUNTILWITHDRAWORTRANSFER = 0 seconds;
		MAXIMUMINVESTMENTSALLOWED = 500 ether;
	}

	///////////////////////////////////////////////
	// VIEW FUNCTIONS
	/////////////////////////////////////////////// 

	function checkWhenContributorCanTransferOrWithdraw(address bankrollerAddress) view public returns(uint256){
		return contributionTime[bankrollerAddress];
	}

	function getBankroll() view public returns(uint256){
		// returns the total balance minus the developers fund, as the amount of active bankroll
		return SafeMath.sub(address(this).balance, DEVELOPERSFUND);
	}

	///////////////////////////////////////////////
	// BANKROLL CONTRACT <-> GAME CONTRACTS functions
	/////////////////////////////////////////////// 

	function payEtherToWinner(uint256 amtEther, address winner) public addressInTrustedAddresses(msg.sender){
		// this function will get called by a game contract when someone wins a game
		// try to send, if it fails, then send the amount to the owner
		// note, this will only happen if someone is calling the betting functions with
		// a contract. They are clearly up to no good, so they can contact us to retreive 
		// their ether
		// if the ether cannot be sent to us, the OWNER, that means we are up to no good, 
		// and the ether will just be given to the bankrollers as if the player/owner lost 

		if (! winner.send(amtEther)){

			emit FailedSend(winner, amtEther);

			if (! OWNER.send(amtEther)){

				emit FailedSend(OWNER, amtEther);
			}
		}
	}

	function receiveEtherFromGameAddress() payable public addressInTrustedAddresses(msg.sender){
		// this function will get called from the game contracts when someone starts a game.
	}

	function payOraclize(uint256 amountToPay) public addressInTrustedAddresses(msg.sender){
		// this function will get called when a game contract must pay payOraclize
		EOSBetGameInterface(msg.sender).receivePaymentForOraclize.value(amountToPay)();
	}

	///////////////////////////////////////////////
	// BANKROLL CONTRACT MAIN FUNCTIONS
	///////////////////////////////////////////////


	// this function ADDS to the bankroll of EOSBet, and credits the bankroller a proportional
	// amount of tokens so they may withdraw their tokens later
	// also if there is only a limited amount of space left in the bankroll, a user can just send as much 
	// ether as they want, because they will be able to contribute up to the maximum, and then get refunded the rest.
	function () public payable {

		// save in memory for cheap access.
		// this represents the total bankroll balance before the function was called.
		uint256 currentTotalBankroll = SafeMath.sub(getBankroll(), msg.value);
		uint256 maxInvestmentsAllowed = MAXIMUMINVESTMENTSALLOWED;

		require(currentTotalBankroll < maxInvestmentsAllowed && msg.value != 0);

		uint256 currentSupplyOfTokens = totalSupply;
		uint256 contributedEther;

		bool contributionTakesBankrollOverLimit;
		uint256 ifContributionTakesBankrollOverLimit_Refund;

		uint256 creditedTokens;

		if (SafeMath.add(currentTotalBankroll, msg.value) > maxInvestmentsAllowed){
			// allow the bankroller to contribute up to the allowed amount of ether, and refund the rest.
			contributionTakesBankrollOverLimit = true;
			// set contributed ether as (MAXIMUMINVESTMENTSALLOWED - BANKROLL)
			contributedEther = SafeMath.sub(maxInvestmentsAllowed, currentTotalBankroll);
			// refund the rest of the ether, which is (original amount sent - (maximum amount allowed - bankroll))
			ifContributionTakesBankrollOverLimit_Refund = SafeMath.sub(msg.value, contributedEther);
		}
		else {
			contributedEther = msg.value;
		}
        
		if (currentSupplyOfTokens != 0){
			// determine the ratio of contribution versus total BANKROLL.
			creditedTokens = SafeMath.mul(contributedEther, currentSupplyOfTokens) / currentTotalBankroll;
		}
		else {
			// edge case where ALL money was cashed out from bankroll
			// so currentSupplyOfTokens == 0
			// currentTotalBankroll can == 0 or not, if someone mines/selfdestruct's to the contract
			// but either way, give all the bankroll to person who deposits ether
			creditedTokens = SafeMath.mul(contributedEther, 100);
		}
		
		// now update the total supply of tokens and bankroll amount
		totalSupply = SafeMath.add(currentSupplyOfTokens, creditedTokens);

		// now credit the user with his amount of contributed tokens 
		balances[msg.sender] = SafeMath.add(balances[msg.sender], creditedTokens);

		// update his contribution time for stake time locking
		contributionTime[msg.sender] = block.timestamp;

		// now look if the attempted contribution would have taken the BANKROLL over the limit, 
		// and if true, refund the excess ether.
		if (contributionTakesBankrollOverLimit){
			msg.sender.transfer(ifContributionTakesBankrollOverLimit_Refund);
		}

		// log an event about funding bankroll
		emit FundBankroll(msg.sender, contributedEther, creditedTokens);

		// log a mint tokens event
		emit Transfer(0x0, msg.sender, creditedTokens);
	}

	function cashoutEOSBetStakeTokens(uint256 _amountTokens) public {
		// In effect, this function is the OPPOSITE of the un-named payable function above^^^
		// this allows bankrollers to "cash out" at any time, and receive the ether that they contributed, PLUS
		// a proportion of any ether that was earned by the smart contact when their ether was "staking", However
		// this works in reverse as well. Any net losses of the smart contract will be absorbed by the player in like manner.
		// Of course, due to the constant house edge, a bankroller that leaves their ether in the contract long enough
		// is effectively guaranteed to withdraw more ether than they originally "staked"

		// save in memory for cheap access.
		uint256 tokenBalance = balances[msg.sender];
		// verify that the contributor has enough tokens to cash out this many, and has waited the required time.
		require(_amountTokens <= tokenBalance 
			&& contributionTime[msg.sender] + WAITTIMEUNTILWITHDRAWORTRANSFER <= block.timestamp
			&& _amountTokens > 0);

		// save in memory for cheap access.
		// again, represents the total balance of the contract before the function was called.
		uint256 currentTotalBankroll = getBankroll();
		uint256 currentSupplyOfTokens = totalSupply;

		// calculate the token withdraw ratio based on current supply 
		uint256 withdrawEther = SafeMath.mul(_amountTokens, currentTotalBankroll) / currentSupplyOfTokens;

		// developers take 1% of withdrawls 
		uint256 developersCut = withdrawEther / 100;
		uint256 contributorAmount = SafeMath.sub(withdrawEther, developersCut);

		// now update the total supply of tokens by subtracting the tokens that are being "cashed in"
		totalSupply = SafeMath.sub(currentSupplyOfTokens, _amountTokens);

		// and update the users supply of tokens 
		balances[msg.sender] = SafeMath.sub(tokenBalance, _amountTokens);

		// update the developers fund based on this calculated amount 
		DEVELOPERSFUND = SafeMath.add(DEVELOPERSFUND, developersCut);

		// lastly, transfer the ether back to the bankroller. Thanks for your contribution!
		msg.sender.transfer(contributorAmount);

		// log an event about cashout
		emit CashOut(msg.sender, contributorAmount, _amountTokens);

		// log a destroy tokens event
		emit Transfer(msg.sender, 0x0, _amountTokens);
	}

	// TO CALL THIS FUNCTION EASILY, SEND A 0 ETHER TRANSACTION TO THIS CONTRACT WITH EXTRA DATA: 0x7a09588b
	function cashoutEOSBetStakeTokens_ALL() public {

		// just forward to cashoutEOSBetStakeTokens with input as the senders entire balance
		cashoutEOSBetStakeTokens(balances[msg.sender]);
	}

	////////////////////
	// OWNER FUNCTIONS:
	////////////////////
	// Please, be aware that the owner ONLY can change:
		// 1. The owner can increase or decrease the target amount for a game. They can then call the updater function to give/receive the ether from the game.
		// 1. The wait time until a user can withdraw or transfer their tokens after purchase through the default function above ^^^
		// 2. The owner can change the maximum amount of investments allowed. This allows for early contributors to guarantee
		// 		a certain percentage of the bankroll so that their stake cannot be diluted immediately. However, be aware that the 
		//		maximum amount of investments allowed will be raised over time. This will allow for higher bets by gamblers, resulting
		// 		in higher dividends for the bankrollers
		// 3. The owner can freeze payouts to bettors. This will be used in case of an emergency, and the contract will reject all
		//		new bets as well. This does not mean that bettors will lose their money without recompense. They will be allowed to call the 
		// 		"refund" function in the respective game smart contract once payouts are un-frozen.
		// 4. Finally, the owner can modify and withdraw the developers reward, which will fund future development, including new games, a sexier frontend,
		// 		and TRUE DAO governance so that onlyOwner functions don't have to exist anymore ;) and in order to effectively react to changes 
		// 		in the market (lower the percentage because of increased competition in the blockchain casino space, etc.)

	function transferOwnership(address newOwner) public {
		require(msg.sender == OWNER);

		OWNER = newOwner;
	}

	function changeWaitTimeUntilWithdrawOrTransfer(uint256 waitTime) public {
		// waitTime MUST be less than or equal to 10 weeks
		require (msg.sender == OWNER && waitTime <= 6048000);

		WAITTIMEUNTILWITHDRAWORTRANSFER = waitTime;
	}

	function changeMaximumInvestmentsAllowed(uint256 maxAmount) public {
		require(msg.sender == OWNER);

		MAXIMUMINVESTMENTSALLOWED = maxAmount;
	}


	function withdrawDevelopersFund(address receiver) public {
		require(msg.sender == OWNER);

		// first get developers fund from each game 
        EOSBetGameInterface(DICE).payDevelopersFund(receiver);
		EOSBetGameInterface(SLOTS).payDevelopersFund(receiver);

		// now send the developers fund from the main contract.
		uint256 developersFund = DEVELOPERSFUND;

		// set developers fund to zero
		DEVELOPERSFUND = 0;

		// transfer this amount to the owner!
		receiver.transfer(developersFund);
	}

	// Can be removed after some testing...
	function emergencySelfDestruct() public {
		require(msg.sender == OWNER);

		selfdestruct(msg.sender);
	}

	///////////////////////////////
	// BASIC ERC20 TOKEN OPERATIONS
	///////////////////////////////

	function totalSupply() constant public returns(uint){
		return totalSupply;
	}

	function balanceOf(address _owner) constant public returns(uint){
		return balances[_owner];
	}

	// don't allow transfers before the required wait-time
	// and don't allow transfers to this contract addr, it'll just kill tokens
	function transfer(address _to, uint256 _value) public returns (bool success){
		if (balances[msg.sender] >= _value 
			&& _value > 0 
			&& contributionTime[msg.sender] + WAITTIMEUNTILWITHDRAWORTRANSFER <= block.timestamp
			&& _to != address(this)){

			// safely subtract
			balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
			balances[_to] = SafeMath.add(balances[_to], _value);

			// log event 
			emit Transfer(msg.sender, _to, _value);
			return true;
		}
		else {
			return false;
		}
	}

	// don't allow transfers before the required wait-time
	// and don't allow transfers to the contract addr, it'll just kill tokens
	function transferFrom(address _from, address _to, uint _value) public returns(bool){
		if (allowed[_from][msg.sender] >= _value 
			&& balances[_from] >= _value 
			&& _value > 0 
			&& contributionTime[_from] + WAITTIMEUNTILWITHDRAWORTRANSFER <= block.timestamp
			&& _to != address(this)){

			// safely add to _to and subtract from _from, and subtract from allowed balances.
			balances[_to] = SafeMath.add(balances[_to], _value);
	   		balances[_from] = SafeMath.sub(balances[_from], _value);
	  		allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);

	  		// log event
    		emit Transfer(_from, _to, _value);
    		return true;
   		} 
    	else { 
    		return false;
    	}
	}
	
	function approve(address _spender, uint _value) public returns(bool){
		if(_value > 0){

			allowed[msg.sender][_spender] = _value;
			emit Approval(msg.sender, _spender, _value);
			// log event
			return true;
		}
		else {
			return false;
		}
	}
	
	function allowance(address _owner, address _spender) constant public returns(uint){
		return allowed[_owner][_spender];
	}
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract EOSBetSlots is usingOraclize, EOSBetGameInterface {

	using SafeMath for *;

	// events
	event BuyCredits(bytes32 indexed oraclizeQueryId);
	event LedgerProofFailed(bytes32 indexed oraclizeQueryId);
	event Refund(bytes32 indexed oraclizeQueryId, uint256 amount);
	event SlotsLargeBet(bytes32 indexed oraclizeQueryId, uint256 data1, uint256 data2, uint256 data3, uint256 data4, uint256 data5, uint256 data6, uint256 data7, uint256 data8);
	event SlotsSmallBet(uint256 data1, uint256 data2, uint256 data3, uint256 data4, uint256 data5, uint256 data6, uint256 data7, uint256 data8);

	// slots game structure
	struct SlotsGameData {
		address player;
		bool paidOut;
		uint256 start;
		uint256 etherReceived;
		uint8 credits;
	}

	mapping (bytes32 => SlotsGameData) public slotsData;

	// ether in this contract can be in one of two locations:
	uint256 public LIABILITIES;
	uint256 public DEVELOPERSFUND;

	// counters for frontend statistics
	uint256 public AMOUNTWAGERED;
	uint256 public DIALSSPUN;
	
	// togglable values
	uint256 public ORACLIZEQUERYMAXTIME;
	uint256 public MINBET_forORACLIZE;
	uint256 public MINBET;
	uint256 public ORACLIZEGASPRICE;
	uint256 public INITIALGASFORORACLIZE;
	uint16 public MAXWIN_inTHOUSANDTHPERCENTS;

	// togglable functionality of contract
	bool public GAMEPAUSED;
	bool public REFUNDSACTIVE;

	// owner of contract
	address public OWNER;

	// bankroller address
	address public BANKROLLER;

	// constructor
	function EOSBetSlots() public {
		// ledger proof is ALWAYS verified on-chain
		oraclize_setProof(proofType_Ledger);

		// gas prices for oraclize call back, can be changed
		oraclize_setCustomGasPrice(10000000000);
		ORACLIZEGASPRICE = 10000000000;
		INITIALGASFORORACLIZE = 225000;

		AMOUNTWAGERED = 0;
		DIALSSPUN = 0;

		GAMEPAUSED = false;
		REFUNDSACTIVE = true;

		ORACLIZEQUERYMAXTIME = 6 hours;
		MINBET_forORACLIZE = 350 finney; // 0.35 ether is the max bet to avoid miner cheating. see python sim. on our github
		MINBET = 1 finney; // currently, this is ~40-50c a spin, which is pretty average slots. This is changeable by OWNER 
        MAXWIN_inTHOUSANDTHPERCENTS = 300; // 300/1000 so a jackpot can take 30% of bankroll (extremely rare)
        OWNER = msg.sender;
	}

	////////////////////////////////////
	// INTERFACE CONTACT FUNCTIONS
	////////////////////////////////////

	function payDevelopersFund(address developer) public {
		require(msg.sender == BANKROLLER);

		uint256 devFund = DEVELOPERSFUND;

		DEVELOPERSFUND = 0;

		developer.transfer(devFund);
	}

	// just a function to receive eth, only allow the bankroll to use this
	function receivePaymentForOraclize() payable public {
		require(msg.sender == BANKROLLER);
	}

	////////////////////////////////////
	// VIEW FUNCTIONS
	////////////////////////////////////

	function getMaxWin() public view returns(uint256){
		return (SafeMath.mul(EOSBetBankrollInterface(BANKROLLER).getBankroll(), MAXWIN_inTHOUSANDTHPERCENTS) / 1000);
	}

	////////////////////////////////////
	// OWNER ONLY FUNCTIONS
	////////////////////////////////////

	// WARNING!!!!! Can only set this function once!
	function setBankrollerContractOnce(address bankrollAddress) public {
		// require that BANKROLLER address == 0x0 (address not set yet), and coming from owner.
		require(msg.sender == OWNER && BANKROLLER == address(0));

		// check here to make sure that the bankroll contract is legitimate
		// just make sure that calling the bankroll contract getBankroll() returns non-zero

		require(EOSBetBankrollInterface(bankrollAddress).getBankroll() != 0);

		BANKROLLER = bankrollAddress;
	}

	function transferOwnership(address newOwner) public {
		require(msg.sender == OWNER);

		OWNER = newOwner;
	}

	function setOraclizeQueryMaxTime(uint256 newTime) public {
		require(msg.sender == OWNER);

		ORACLIZEQUERYMAXTIME = newTime;
	}

	// store the gas price as a storage variable for easy reference,
	// and thne change the gas price using the proper oraclize function
	function setOraclizeQueryGasPrice(uint256 gasPrice) public {
		require(msg.sender == OWNER);

		ORACLIZEGASPRICE = gasPrice;
		oraclize_setCustomGasPrice(gasPrice);
	}

	// should be ~160,000 to save eth
	function setInitialGasForOraclize(uint256 gasAmt) public {
		require(msg.sender == OWNER);

		INITIALGASFORORACLIZE = gasAmt;
	}

	function setGamePaused(bool paused) public {
		require(msg.sender == OWNER);

		GAMEPAUSED = paused;
	}

	function setRefundsActive(bool active) public {
		require(msg.sender == OWNER);

		REFUNDSACTIVE = active;
	}

	// setting this to 0 would just force all bets through oraclize, and setting to MAX_UINT_256 would never use oraclize 
	function setMinBetForOraclize(uint256 minBet) public {
		require(msg.sender == OWNER);

		MINBET_forORACLIZE = minBet;
	}

	function setMinBet(uint256 minBet) public {
		require(msg.sender == OWNER && minBet > 1000);

		MINBET = minBet;
	}

	function setMaxwin(uint16 newMaxWinInThousandthPercents) public {
		require(msg.sender == OWNER && newMaxWinInThousandthPercents <= 333); // cannot set max win greater than 1/3 of the bankroll (a jackpot is very rare)

		MAXWIN_inTHOUSANDTHPERCENTS = newMaxWinInThousandthPercents;
	}

	// this can be deleted after some testing.
	function emergencySelfDestruct() public {
		require(msg.sender == OWNER);

		selfdestruct(msg.sender);
	}

	function refund(bytes32 oraclizeQueryId) public {
		// save into memory for cheap access
		SlotsGameData memory data = slotsData[oraclizeQueryId];

		//require that the query time is too slow, bet has not been paid out, and either contract owner or player is calling this function.
		require(SafeMath.sub(block.timestamp, data.start) >= ORACLIZEQUERYMAXTIME
			&& (msg.sender == OWNER || msg.sender == data.player)
			&& (!data.paidOut)
			&& data.etherReceived <= LIABILITIES
			&& data.etherReceived > 0
			&& REFUNDSACTIVE);

		// set contract data
		slotsData[oraclizeQueryId].paidOut = true;

		// subtract etherReceived from these two values because the bet is being refunded
		LIABILITIES = SafeMath.sub(LIABILITIES, data.etherReceived);

		// then transfer the original bet to the player.
		data.player.transfer(data.etherReceived);

		// finally, log an event saying that the refund has processed.
		emit Refund(oraclizeQueryId, data.etherReceived);
	}

	function play(uint8 credits) public payable {
		// save for future use / gas efficiency
		uint256 betPerCredit = msg.value / credits;

		// require that the game is unpaused, and that the credits being purchased are greater than 0 and less than the allowed amount, default: 100 spins 
		// verify that the bet is less than or equal to the bet limit, so we don't go bankrupt, and that the etherreceived is greater than the minbet.
		require(!GAMEPAUSED
			&& msg.value > 0
			&& betPerCredit >= MINBET
			&& credits > 0 
			&& credits <= 224
			&& SafeMath.mul(betPerCredit, 5000) <= getMaxWin()); // 5000 is the jackpot payout (max win on a roll)

		// if each bet is relatively small, resolve the bet in-house
		if (betPerCredit < MINBET_forORACLIZE){

			// randomness will be determined by keccak256(blockhash, nonce)
			// store these into memory for cheap access
			bytes32 blockHash = block.blockhash(block.number);

			// use dialsSpun as a nonce for the oraclize return random bytes.
			uint256 dialsSpun;

			// dial1, dial2, dial3 are the items that the wheel lands on, represented by uints 0-6
			// these are then echoed to the front end by data1, data2, data3
			uint8 dial1;
			uint8 dial2;
			uint8 dial3;

			// these are used ONLY for log data for the frontend
			// each dial of the machine can be between 0 and 6 (see below table for distribution)
			// therefore, each dial takes 3 BITS of space -> uint(bits('111')) == 7, uint(bits('000')) == 0
			// so dataX can hold 256 bits/(3 bits * 3 dials) = 28.444 -> 28 spins worth of data 
			uint256[] memory logsData = new uint256[](8);

			// this is incremented every time a player hits a spot of the wheel that pays out
			// at the end this is multiplied by the betPerCredit amount to determine how much the game should payout.
			uint256 payout;

			// Now, loop over each credit.
			// Please note that this loop is almost identical to the loop in the __callback from oraclize
			// Modular-izing the loops into a single function is impossible because solidity can only store 16 variables into memory
			// also, it would cost increased gas for each spin.
			for (uint8 i = 0; i < credits; i++){

				// spin the first dial
				dialsSpun += 1;
				dial1 = uint8(uint(keccak256(blockHash, dialsSpun)) % 64);
				// spin the second dial
				dialsSpun += 1;
				dial2 = uint8(uint(keccak256(blockHash, dialsSpun)) % 64);
				// spin the third dial
				dialsSpun += 1;
				dial3 = uint8(uint(keccak256(blockHash, dialsSpun)) % 64);

				// dial 1, based on above table
				dial1 = getDial1Type(dial1);

				// dial 2, based on above table
				dial2 = getDial2Type(dial2);

				// dial 3, based on above table
				dial3 = getDial3Type(dial3);

				// determine the payouts (all in uint8)

				payout += determinePayout(dial1, dial2, dial3);

				// Here we assemble uint256's of log data so that the frontend can "replay" the spins
				// each "dial" is a uint8 but can only be between 0-6, so would only need 3 bits to store this. uint(bits('111')) = 7
				// 2 ** 3 is the bitshift operator for three bits 
				if (i <= 27){
					// in logsData0
					logsData[0] += uint256(dial1) * uint256(2) ** (3 * ((3 * (27 - i)) + 2));
					logsData[0] += uint256(dial2) * uint256(2) ** (3 * ((3 * (27 - i)) + 1));
					logsData[0] += uint256(dial3) * uint256(2) ** (3 * ((3 * (27 - i))));
				}
				else if (i <= 55){
					// in logsData1
					logsData[1] += uint256(dial1) * uint256(2) ** (3 * ((3 * (55 - i)) + 2));
					logsData[1] += uint256(dial2) * uint256(2) ** (3 * ((3 * (55 - i)) + 1));
					logsData[1] += uint256(dial3) * uint256(2) ** (3 * ((3 * (55 - i))));
				}
				else if (i <= 83) {
					// in logsData2
					logsData[2] += uint256(dial1) * uint256(2) ** (3 * ((3 * (83 - i)) + 2));
					logsData[2] += uint256(dial2) * uint256(2) ** (3 * ((3 * (83 - i)) + 1));
					logsData[2] += uint256(dial3) * uint256(2) ** (3 * ((3 * (83 - i))));
				}
				else if (i <= 111) {
					// in logsData3
					logsData[3] += uint256(dial1) * uint256(2) ** (3 * ((3 * (111 - i)) + 2));
					logsData[3] += uint256(dial2) * uint256(2) ** (3 * ((3 * (111 - i)) + 1));
					logsData[3] += uint256(dial3) * uint256(2) ** (3 * ((3 * (111 - i))));
				}
				else if (i <= 139){
					// in logsData4
					logsData[4] += uint256(dial1) * uint256(2) ** (3 * ((3 * (139 - i)) + 2));
					logsData[4] += uint256(dial2) * uint256(2) ** (3 * ((3 * (139 - i)) + 1));
					logsData[4] += uint256(dial3) * uint256(2) ** (3 * ((3 * (139 - i))));
				}
				else if (i <= 167){
					// in logsData5
					logsData[5] += uint256(dial1) * uint256(2) ** (3 * ((3 * (167 - i)) + 2));
					logsData[5] += uint256(dial2) * uint256(2) ** (3 * ((3 * (167 - i)) + 1));
					logsData[5] += uint256(dial3) * uint256(2) ** (3 * ((3 * (167 - i))));
				}
				else if (i <= 195){
					// in logsData6
					logsData[6] += uint256(dial1) * uint256(2) ** (3 * ((3 * (195 - i)) + 2));
					logsData[6] += uint256(dial2) * uint256(2) ** (3 * ((3 * (195 - i)) + 1));
					logsData[6] += uint256(dial3) * uint256(2) ** (3 * ((3 * (195 - i))));
				}
				else {
					// in logsData7
					logsData[7] += uint256(dial1) * uint256(2) ** (3 * ((3 * (223 - i)) + 2));
					logsData[7] += uint256(dial2) * uint256(2) ** (3 * ((3 * (223 - i)) + 1));
					logsData[7] += uint256(dial3) * uint256(2) ** (3 * ((3 * (223 - i))));
				}
			}

			// add these new dials to the storage variable DIALSSPUN
			DIALSSPUN += dialsSpun;

			// and add the amount wagered
			AMOUNTWAGERED = SafeMath.add(AMOUNTWAGERED, msg.value);

			// calculate amount for the developers fund.
			// this is: value of ether * (5% house edge) * (20% cut)
			uint256 developersCut = msg.value / 100;

			// add this to the developers fund.
			DEVELOPERSFUND = SafeMath.add(DEVELOPERSFUND, developersCut);

			// transfer the (msg.value - developersCut) to the bankroll
			EOSBetBankrollInterface(BANKROLLER).receiveEtherFromGameAddress.value(SafeMath.sub(msg.value, developersCut))();

			// now payout ether
			uint256 etherPaidout = SafeMath.mul(betPerCredit, payout);

			// make the bankroll transfer the paidout amount to the player
			EOSBetBankrollInterface(BANKROLLER).payEtherToWinner(etherPaidout, msg.sender);

			// and lastly, log an event
			// log the data logs that were created above, we will not use event watchers here, but will use the txReceipt to get logs instead.
			emit SlotsSmallBet(logsData[0], logsData[1], logsData[2], logsData[3], logsData[4], logsData[5], logsData[6], logsData[7]);

		}
		// if the bet amount is OVER the oraclize query limit, we must get the randomness from oraclize.
		// This is because miners are inventivized to interfere with the block.blockhash, in an attempt
		// to get more favorable rolls/slot spins/etc.
		else {
			// oraclize_newRandomDSQuery(delay in seconds, bytes of random data, gas for callback function)
			bytes32 oraclizeQueryId;

			// equation for gas to oraclize is:
			// gas = (some fixed gas amt) + 3270 * credits
			
			uint256 gasToSend = INITIALGASFORORACLIZE + (uint256(3270) * credits);

			EOSBetBankrollInterface(BANKROLLER).payOraclize(oraclize_getPrice('random', gasToSend));

			oraclizeQueryId = oraclize_newRandomDSQuery(0, 30, gasToSend);

			// add the new slots data to a mapping so that the oraclize __callback can use it later
			slotsData[oraclizeQueryId] = SlotsGameData({
				player : msg.sender,
				paidOut : false,
				start : block.timestamp,
				etherReceived : msg.value,
				credits : credits
			});

			// add the sent value into liabilities. this should NOT go into the bankroll yet
			// and must be quarantined here to prevent timing attacks
			LIABILITIES = SafeMath.add(LIABILITIES, msg.value);

			emit BuyCredits(oraclizeQueryId);
		}
	}

	function __callback(bytes32 _queryId, string _result, bytes _proof) public {
		// get the game data and put into memory
		SlotsGameData memory data = slotsData[_queryId];

		require(msg.sender == oraclize_cbAddress() 
			&& !data.paidOut 
			&& data.player != address(0) 
			&& LIABILITIES >= data.etherReceived);

		// if the proof has failed, immediately refund the player the original bet.
		if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0){

			if (REFUNDSACTIVE){
				// set contract data
				slotsData[_queryId].paidOut = true;

				// subtract from liabilities and amount wagered, because this bet is being refunded.
				LIABILITIES = SafeMath.sub(LIABILITIES, data.etherReceived);

				// transfer the original bet back
				data.player.transfer(data.etherReceived);

				// log the refund
				emit Refund(_queryId, data.etherReceived);
			}
			// log the ledger proof fail 
			emit LedgerProofFailed(_queryId);
			
		}
		else {
			// again, this block is almost identical to the previous block in the play(...) function 
			// instead of duplicating documentation, we will just point out the changes from the other block 
			uint256 dialsSpun;
			
			uint8 dial1;
			uint8 dial2;
			uint8 dial3;
			
			uint256[] memory logsData = new uint256[](8);
			
			uint256 payout;
			
			// must use data.credits instead of credits.
			for (uint8 i = 0; i < data.credits; i++){

				// all dials now use _result, instead of blockhash, this is the main change, and allows Slots to 
				// accomodate bets of any size, free of possible miner interference 
				dialsSpun += 1;
				dial1 = uint8(uint(keccak256(_result, dialsSpun)) % 64);
				
				dialsSpun += 1;
				dial2 = uint8(uint(keccak256(_result, dialsSpun)) % 64);
				
				dialsSpun += 1;
				dial3 = uint8(uint(keccak256(_result, dialsSpun)) % 64);

				// dial 1
				dial1 = getDial1Type(dial1);

				// dial 2
				dial2 = getDial2Type(dial2);

				// dial 3
				dial3 = getDial3Type(dial3);

				// determine the payout
				payout += determinePayout(dial1, dial2, dial3);
				
				// assembling log data
				if (i <= 27){
					// in logsData0
					logsData[0] += uint256(dial1) * uint256(2) ** (3 * ((3 * (27 - i)) + 2));
					logsData[0] += uint256(dial2) * uint256(2) ** (3 * ((3 * (27 - i)) + 1));
					logsData[0] += uint256(dial3) * uint256(2) ** (3 * ((3 * (27 - i))));
				}
				else if (i <= 55){
					// in logsData1
					logsData[1] += uint256(dial1) * uint256(2) ** (3 * ((3 * (55 - i)) + 2));
					logsData[1] += uint256(dial2) * uint256(2) ** (3 * ((3 * (55 - i)) + 1));
					logsData[1] += uint256(dial3) * uint256(2) ** (3 * ((3 * (55 - i))));
				}
				else if (i <= 83) {
					// in logsData2
					logsData[2] += uint256(dial1) * uint256(2) ** (3 * ((3 * (83 - i)) + 2));
					logsData[2] += uint256(dial2) * uint256(2) ** (3 * ((3 * (83 - i)) + 1));
					logsData[2] += uint256(dial3) * uint256(2) ** (3 * ((3 * (83 - i))));
				}
				else if (i <= 111) {
					// in logsData3
					logsData[3] += uint256(dial1) * uint256(2) ** (3 * ((3 * (111 - i)) + 2));
					logsData[3] += uint256(dial2) * uint256(2) ** (3 * ((3 * (111 - i)) + 1));
					logsData[3] += uint256(dial3) * uint256(2) ** (3 * ((3 * (111 - i))));
				}
				else if (i <= 139){
					// in logsData4
					logsData[4] += uint256(dial1) * uint256(2) ** (3 * ((3 * (139 - i)) + 2));
					logsData[4] += uint256(dial2) * uint256(2) ** (3 * ((3 * (139 - i)) + 1));
					logsData[4] += uint256(dial3) * uint256(2) ** (3 * ((3 * (139 - i))));
				}
				else if (i <= 167){
					// in logsData5
					logsData[5] += uint256(dial1) * uint256(2) ** (3 * ((3 * (167 - i)) + 2));
					logsData[5] += uint256(dial2) * uint256(2) ** (3 * ((3 * (167 - i)) + 1));
					logsData[5] += uint256(dial3) * uint256(2) ** (3 * ((3 * (167 - i))));
				}
				else if (i <= 195){
					// in logsData6
					logsData[6] += uint256(dial1) * uint256(2) ** (3 * ((3 * (195 - i)) + 2));
					logsData[6] += uint256(dial2) * uint256(2) ** (3 * ((3 * (195 - i)) + 1));
					logsData[6] += uint256(dial3) * uint256(2) ** (3 * ((3 * (195 - i))));
				}
				else if (i <= 223){
					// in logsData7
					logsData[7] += uint256(dial1) * uint256(2) ** (3 * ((3 * (223 - i)) + 2));
					logsData[7] += uint256(dial2) * uint256(2) ** (3 * ((3 * (223 - i)) + 1));
					logsData[7] += uint256(dial3) * uint256(2) ** (3 * ((3 * (223 - i))));
				}
			}

			// track that these spins were made
			DIALSSPUN += dialsSpun;

			// and add the amount wagered
			AMOUNTWAGERED = SafeMath.add(AMOUNTWAGERED, data.etherReceived);

			// IMPORTANT: we must change the "paidOut" to TRUE here to prevent reentrancy/other nasty effects.
			// this was not needed with the previous loop/code block, and is used because variables must be written into storage
			slotsData[_queryId].paidOut = true;

			// decrease LIABILITIES when the spins are made
			LIABILITIES = SafeMath.sub(LIABILITIES, data.etherReceived);

			// get the developers cut, and send the rest of the ether received to the bankroller contract
			uint256 developersCut = data.etherReceived / 100;

			DEVELOPERSFUND = SafeMath.add(DEVELOPERSFUND, developersCut);

			EOSBetBankrollInterface(BANKROLLER).receiveEtherFromGameAddress.value(SafeMath.sub(data.etherReceived, developersCut))();

			// get the ether to be paid out, and force the bankroller contract to pay out the player
			uint256 etherPaidout = SafeMath.mul((data.etherReceived / data.credits), payout);

			EOSBetBankrollInterface(BANKROLLER).payEtherToWinner(etherPaidout, data.player);

			// log en event with indexed query id
			emit SlotsLargeBet(_queryId, logsData[0], logsData[1], logsData[2], logsData[3], logsData[4], logsData[5], logsData[6], logsData[7]);
		}
	}
	
	// HELPER FUNCTIONS TO:
	// calculate the result of the dials based on the hardcoded slot data: 

	// STOPS			REEL#1	REEL#2	REEL#3
	///////////////////////////////////////////
	// gold ether 	0 //  1  //  3   //   1  //	
	// silver ether 1 //  7  //  1   //   6  //
	// bronze ether 2 //  1  //  7   //   6  //
	// gold planet  3 //  5  //  7   //   6  //
	// silverplanet 4 //  9  //  6   //   7  //
	// bronzeplanet 5 //  9  //  8   //   6  //
	// ---blank---  6 //  32 //  32  //   32 //
	///////////////////////////////////////////

	// note that dial1 / 2 / 3 will go from mod 64 to mod 7 in this manner
	
	function getDial1Type(uint8 dial1Location) internal pure returns(uint8) {
	    if (dial1Location == 0) 							        { return 0; }
		else if (dial1Location >= 1 && dial1Location <= 7) 			{ return 1; }
		else if (dial1Location == 8) 						        { return 2; }
		else if (dial1Location >= 9 && dial1Location <= 13) 		{ return 3; }
		else if (dial1Location >= 14 && dial1Location <= 22) 		{ return 4; }
		else if (dial1Location >= 23 && dial1Location <= 31) 		{ return 5; }
		else 										                { return 6; }
	}
	
	function getDial2Type(uint8 dial2Location) internal pure returns(uint8) {
	    if (dial2Location >= 0 && dial2Location <= 2) 				{ return 0; }
		else if (dial2Location == 3) 						        { return 1; }
		else if (dial2Location >= 4 && dial2Location <= 10)			{ return 2; }
		else if (dial2Location >= 11 && dial2Location <= 17) 		{ return 3; }
		else if (dial2Location >= 18 && dial2Location <= 23) 		{ return 4; }
		else if (dial2Location >= 24 && dial2Location <= 31) 		{ return 5; }
		else 										                { return 6; }
	}
	
	function getDial3Type(uint8 dial3Location) internal pure returns(uint8) {
	    if (dial3Location == 0) 							        { return 0; }
		else if (dial3Location >= 1 && dial3Location <= 6)			{ return 1; }
		else if (dial3Location >= 7 && dial3Location <= 12) 		{ return 2; }
		else if (dial3Location >= 13 && dial3Location <= 18)		{ return 3; }
		else if (dial3Location >= 19 && dial3Location <= 25) 		{ return 4; }
		else if (dial3Location >= 26 && dial3Location <= 31) 		{ return 5; }
		else 										                { return 6; }
	}
	
	// HELPER FUNCTION TO:
	// determine the payout given dial locations based on this table
	
	// hardcoded payouts data:
	// 			LANDS ON 				//	PAYS  //
	////////////////////////////////////////////////
	// Bronze E -> Silver E -> Gold E	//	5000  //
	// 3x Gold Ether					//	1777  //
	// 3x Silver Ether					//	250   //
	// 3x Bronze Ether					//	250   //
	//  3x any Ether 					//	95    //
	// Bronze P -> Silver P -> Gold P	//	90    //
	// 3x Gold Planet 					//	50    //
	// 3x Silver Planet					//	25    //
	// Any Gold P & Silver P & Bronze P //	20    //
	// 3x Bronze Planet					//	10    //
	// Any 3 planet type				//	3     //
	// Any 3 gold						//	3     //
	// Any 3 silver						//	2     //
	// Any 3 bronze						//	2     //
	// Blank, blank, blank				//	1     //
	// else								//  0     //
	////////////////////////////////////////////////
	
	function determinePayout(uint8 dial1, uint8 dial2, uint8 dial3) internal pure returns(uint256) {
		if (dial1 == 6 || dial2 == 6 || dial3 == 6){
			// all blank
			if (dial1 == 6 && dial2 == 6 && dial3 == 6)
				return 1;
		}
		else if (dial1 == 5){
			// bronze planet -> silver planet -> gold planet
			if (dial2 == 4 && dial3 == 3) 
				return 90;

			// one gold planet, one silver planet, one bronze planet, any order!
			// note: other order covered above, return 90
			else if (dial2 == 3 && dial3 == 4)
				return 20;

			// all bronze planet 
			else if (dial2 == 5 && dial3 == 5) 
				return 10;

			// any three planet type 
			else if (dial2 >= 3 && dial2 <= 5 && dial3 >= 3 && dial3 <= 5)
				return 3;

			// any three bronze 
			else if ((dial2 == 2 || dial2 == 5) && (dial3 == 2 || dial3 == 5))
				return 2;
		}
		else if (dial1 == 4){
			// all silver planet
			if (dial2 == 4 && dial3 == 4)
				return 25;

			// one gold planet, one silver planet, one bronze planet, any order!
			else if ((dial2 == 3 && dial3 == 5) || (dial2 == 5 && dial3 == 3))
				return 20;

			// any three planet type 
			else if (dial2 >= 3 && dial2 <= 5 && dial3 >= 3 && dial3 <= 5)
				return 3;

			// any three silver
			else if ((dial2 == 1 || dial2 == 4) && (dial3 == 1 || dial3 == 4))
				return 2;
		}
		else if (dial1 == 3){
			// all gold planet
			if (dial2 == 3 && dial3 == 3)
				return 50;

			// one gold planet, one silver planet, one bronze planet, any order!
			else if ((dial2 == 4 && dial3 == 5) || (dial2 == 5 && dial3 == 4))
				return 20;

			// any three planet type 
			else if (dial2 >= 3 && dial2 <= 5 && dial3 >= 3 && dial3 <= 5)
				return 3;

			// any three gold
			else if ((dial2 == 0 || dial2 == 3) && (dial3 == 0 || dial3 == 3))
				return 3;
		}
		else if (dial1 == 2){
			if (dial2 == 1 && dial3 == 0)
				return 5000; // jackpot!!!!

			// all bronze ether
			else if (dial2 == 2 && dial3 == 2)
				return 250;

			// all some type of ether
			else if (dial2 >= 0 && dial2 <= 2 && dial3 >= 0 && dial3 <= 2)
				return 95;

			// any three bronze
			else if ((dial2 == 2 || dial2 == 5) && (dial3 == 2 || dial3 == 5))
				return 2;
		}
		else if (dial1 == 1){
			// all silver ether 
			if (dial2 == 1 && dial3 == 1)
				return 250;

			// all some type of ether
			else if (dial2 >= 0 && dial2 <= 2 && dial3 >= 0 && dial3 <= 2)
				return 95;

			// any three silver
			else if ((dial2 == 1 || dial2 == 4) && (dial3 == 1 || dial3 == 4))
				return 3;
		}
		else if (dial1 == 0){
			// all gold ether
			if (dial2 == 0 && dial3 == 0)
				return 1777;

			// all some type of ether
			else if (dial2 >= 0 && dial2 <= 2 && dial3 >= 0 && dial3 <= 2)
				return 95;

			// any three gold
			else if ((dial2 == 0 || dial2 == 3) && (dial3 == 0 || dial3 == 3))
				return 3;
		}
		return 0;
	}

}