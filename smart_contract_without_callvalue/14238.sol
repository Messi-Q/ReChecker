 

contract OraclizeAddrResolver {

    address public addr;

    address owner;

    function OraclizeAddrResolver(){
        owner = msg.sender;
    }

    function changeOwner(address newowner){
        if (msg.sender != owner) throw;
        owner = newowner;
    }

    function getAddress() returns (address oaddr){
        return addr;
    }

    function setAddr(address newaddr){
        if (msg.sender != owner) throw;
        addr = newaddr;
    }

}