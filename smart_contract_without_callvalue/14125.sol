pragma solidity ^0.4.21;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract owned {
    address public owner;
    bool public ownershipTransferAllowed = false;

    function constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function allowTransferOwnership(bool flag ) public onlyOwner {
      ownershipTransferAllowed = flag;
    }
 
    function transferOwnership(address newOwner) public onlyOwner {
        require( newOwner != 0x0 );                                              
        require( ownershipTransferAllowed );                                 
        owner = newOwner;
        ownershipTransferAllowed = false;
    }
}

contract ECR20HoneycombToken is owned {
     
    string public name = "Honeycomb";
    string public symbol = "COMB";
    uint8 public decimals = 18;
    
     
    uint256 private tokenFactor = 10 ** uint256(decimals);
    uint256 private initialBuyPrice = 3141592650000000000000;                    
    uint256 private buyConst1 = 10000 * tokenFactor;                             
    uint256 private buyConst2 = 4;                                               
    
    uint256 public minimumPayout = 1000000000000000;							 
       
    uint256 public totalSupply;                                                  

	 
    uint256 public sellPrice;
    uint256 public buyPrice;

     
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    function ECR20HoneycombToken() public {
        totalSupply = 1048576 * tokenFactor;                                     
        balanceOf[msg.sender] = totalSupply;                                     
        owner = msg.sender;			                                             
        emit Transfer(0, owner, totalSupply);                                    
        _transfer(owner, this, totalSupply - (16384*tokenFactor));               
        _setPrices(_newPrice(balanceOf[this]));                                  
    }
     
    function _newPrice(uint256 tokenLeft) internal view returns (uint256 newPrice) {
        newPrice = initialBuyPrice 
            * ( tokenLeft * buyConst1 )
            / ( totalSupply*buyConst1 + totalSupply*tokenLeft/buyConst2 - tokenLeft*tokenLeft/buyConst2 ); 
        return newPrice;
    }

    function _setPrices(uint256 newPrice) internal {
        buyPrice = newPrice;
        sellPrice = buyPrice * 141421356 / 100000000;                            
    }

	 
	function buy() payable public returns (uint256 amountToken){
        amountToken = msg.value * buyPrice / tokenFactor;                        
        uint256 newPrice = _newPrice(balanceOf[this] - amountToken);             
        require( (2*newPrice) > sellPrice);                                      
        _transfer(this, msg.sender, amountToken);                                
        _setPrices( newPrice );                                                  
        return amountToken;
    }

     
	function () payable public {
	    buy();
    }

     
    function sell(uint256 amountToken) public returns (uint256 revenue){
        revenue = amountToken * tokenFactor / sellPrice;                         
        require( revenue >= minimumPayout );									 
        uint256 newPrice = _newPrice(balanceOf[this] + amountToken);             
        require( newPrice < sellPrice );                                         
        _transfer(msg.sender, this, amountToken);                                
        _setPrices( newPrice );                                                  
        msg.sender.transfer(revenue);                                            
        return revenue;
    }
		
     
    function transfer(address _to, uint256 _value) public {
        if ( _to  == address(this) )
        {
          sell(_value);                                                          
        }
        else
        {
          _transfer(msg.sender, _to, _value);
        }
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);      
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

     
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

	 
		function setMinimumPayout(uint256 amount) public onlyOwner {
		minimumPayout = amount;
    }
		
	 
		function save(uint256 amount) public onlyOwner {
        require( amount >= minimumPayout );	
        owner.transfer( amount);
    }
		
	 
		function restore(uint256 amount) public onlyOwner {
        uint256 newPrice = _newPrice(balanceOf[this] + amount);                  
        _transfer(owner, this, amount );                                         
        _setPrices( newPrice );                                                  
    }
		
	 
    function _transfer(address _from, address _to, uint _value) internal {
         
        require(_to != 0x0);
         
        require(balanceOf[_from] >= _value);
         
        require(balanceOf[_to] + _value > balanceOf[_to]);
         
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
         
        balanceOf[_from] -= _value;
         
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
         
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

}