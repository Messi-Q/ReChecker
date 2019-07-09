pragma solidity ^0.4.18;

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   
  function Ownable() {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract SAGAcrowdSale is Ownable {
	address  public SAGA;
	mapping (address => bool) public whiteList;
	uint256 public price = 80000;
	
	function SAGAcrowdSale (address _SAGA) {
		SAGA = _SAGA;
	}
	

	function addWhiteList (address[] _client) onlyOwner {
		for (uint i = 0; i < _client.length; i++) {
			whiteList[_client[i]] = true;
		}
	}
	
	function () public payable {
		buyTokens();
	}

	function buyTokens () public payable {
		require (whiteList[msg.sender]);
    require (msg.value >= 0.1 ether);
		uint256 tokenAmount = msg.value * price;
		require(ERC20Basic(SAGA).transfer(msg.sender, tokenAmount));
	}

	function endOfPreSale() onlyOwner {
		price = 60000;
	}

  function finalize (address _realOwner) public onlyOwner {
    ERC20Basic(SAGA).transfer(_realOwner, ERC20Basic(SAGA).balanceOf(this));
    _realOwner.transfer(this.balance);
  }
}