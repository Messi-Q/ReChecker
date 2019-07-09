pragma solidity ^0.4.19;


 
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint a, uint b) internal returns (uint) {
     
    uint c = a / b;
     
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}


 
contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
}


 
contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

   
  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }

   
  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }

   
  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }
}


 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


 
contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;

   
  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
    var _allowance = allowed[_from][msg.sender];

     
     

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }

   
  function approve(address _spender, uint _value) {

     
     
     
     
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

   
  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

contract LULUToken is StandardToken {
  using SafeMath for uint256;

  string public name = "LULU Token";
  string public symbol = "LULU";
  string public releaseArr = '0000000000000000000';
 
  uint public decimals = 18;
  
  function LULUToken() {
    totalSupply = 100000000000 * 1000000000000000000;
    balances[msg.sender] = totalSupply / 5;
  }

  function tokenRelease() public returns (string) {
     
    uint256 y2019 = 1557936000;
    uint256 y2020 = 1589558400;
    uint256 y2021 = 1621094400;
    uint256 y2022 = 1652630400;
    uint256 y2023 = 1684166400;

    if (now > y2019 && now <= 1573833600 && bytes(releaseArr)[0] == '0') {
        bytes(releaseArr)[0] = '1';
        balances[msg.sender] = balances[msg.sender] + totalSupply / 10;
        return releaseArr;
    } else if (now > 1573833600 && now <= y2020 && bytes(releaseArr)[1] == '0') {
        bytes(releaseArr)[1] = '1';
        balances[msg.sender] = balances[msg.sender] + totalSupply / 10;
        return releaseArr;
    }
    
    if (now > y2020 && now <= 1605456000 && bytes(releaseArr)[2] == '0') {
        bytes(releaseArr)[2] = '1';
        balances[msg.sender] = balances[msg.sender] + totalSupply / 10;
        return releaseArr;
    } else if (now > 1605456000 && now <= y2021  && bytes(releaseArr)[3] == '0') {
        bytes(releaseArr)[3] = '1';
        balances[msg.sender] = balances[msg.sender] + totalSupply / 10;
        return releaseArr;
    }
    
    if (now > y2021 && now <= 1636992000 && bytes(releaseArr)[4] == '0') {
        bytes(releaseArr)[4] = '1';
        balances[msg.sender] = balances[msg.sender] + totalSupply / 10;
        return releaseArr;
    } else if (now > 1636992000 && now <= y2022 && bytes(releaseArr)[5] == '0') {
        bytes(releaseArr)[5] = '1';
        balances[msg.sender] = balances[msg.sender] + totalSupply / 10;
        return releaseArr;
    }
    
    if (now > y2022 && now <= 1668528000 && bytes(releaseArr)[6] == '0') {
        bytes(releaseArr)[6] = '1';
        balances[msg.sender] = balances[msg.sender] + totalSupply / 10;
        return releaseArr;
    }else if (now > 1668528000  && now <= y2023 && bytes(releaseArr)[7] == '0') {
        bytes(releaseArr)[7] = '1';
        balances[msg.sender] = balances[msg.sender] + totalSupply / 10;
        return releaseArr;
    }

    return releaseArr;
  }
}