pragma solidity 0.4.23;
 

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

 
contract IOwned {
     
    function owner() public view returns (address) {}

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}

 
contract IBancorConverter{

    function getReturn(address _fromToken, address _toToken, uint256 _amount) public view returns (uint256);
	function quickConvert(address[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);

}
 
contract IBancorQuickConverter {
    function convert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);
    function convertFor(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for) public payable returns (uint256);
    function convertForPrioritized(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for, uint256 _block, uint256 _nonce, uint8 _v, bytes32 _r, bytes32 _s) public payable returns (uint256);
}

 
contract IBancorGasPriceLimit {
    function gasPrice() public view returns (uint256) {}
    function validateGasPrice(uint256) public view;
}

 
contract ITokenConverter {
    function convertibleTokenCount() public view returns (uint16);
    function convertibleToken(uint16 _tokenIndex) public view returns (address);
    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public view returns (uint256);
    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
     
    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
}

 
contract IERC20Token {
     
    function name() public view returns (string) {}
    function symbol() public view returns (string) {}
    function decimals() public view returns (uint8) {}
    function totalSupply() public view returns (uint256) {}
    function balanceOf(address _owner) public view returns (uint256) { _owner; }
    function allowance(address _owner, address _spender) public view returns (uint256) { _owner; _spender; }

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

 
contract ISmartToken is IOwned, IERC20Token {
    function disableTransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}

 
contract admined {  
    address public admin;  

     
    constructor() internal {
        admin = msg.sender;  
        emit Admined(admin);
    }

    modifier onlyAdmin() {  
        require(msg.sender == admin);
        _;
    }

    
    function transferAdminship(address _newAdmin) onlyAdmin public {  
        require(_newAdmin != 0);
        admin = _newAdmin;
        emit TransferAdminship(admin);
    }

    event TransferAdminship(address newAdminister);
    event Admined(address administer);

}


 
contract MIB is admined,IERC20Token {  
    using SafeMath for uint256;  

 
 
 

    mapping (address => uint256) balances;  
    mapping (address => mapping (address => uint256)) allowed;  
    uint256 public totalSupply;
    
     
    function balanceOf(address _owner) public constant returns (uint256 bal) {
        return balances[_owner];
    }

     
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));  
        
        if(_to == address(this)){
        	sell(msg.sender,_value);
        	return true;
        } else {
            balances[msg.sender] = balances[msg.sender].sub(_value);
	        balances[_to] = balances[_to].add(_value);
    	    emit Transfer(msg.sender, _to, _value);
        	return true;

        }
    }

     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));  
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

     
    function approve(address _spender, uint256 _value) public returns (bool success) {
    	require((_value == 0) || (allowed[msg.sender][_spender] == 0));  
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

     
    function mintToken(address _target, uint256 _mintedAmount) private {
        balances[_target] = SafeMath.add(balances[_target], _mintedAmount);
        totalSupply = SafeMath.add(totalSupply, _mintedAmount);
        emit Transfer(0, this, _mintedAmount);
        emit Transfer(this, _target, _mintedAmount);
    }

     
    function burnToken(address _target, uint256 _burnedAmount) private {
        balances[_target] = SafeMath.sub(balances[_target], _burnedAmount);
        totalSupply = SafeMath.sub(totalSupply, _burnedAmount);
        emit Burned(_target, _burnedAmount);
    }

     
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burned(address indexed _target, uint256 _value);

 
 
 

	 
	IBancorConverter BancorConverter = IBancorConverter(0xc6725aE749677f21E4d8f85F41cFB6DE49b9Db29);
	IBancorQuickConverter Bancor = IBancorQuickConverter(0xcF1CC6eD5B653DeF7417E3fA93992c3FFe49139B);
	IBancorGasPriceLimit BancorGas = IBancorGasPriceLimit(0x607a5C47978e2Eb6d59C6C6f51bc0bF411f4b85a);
	 
	IERC20Token ETHToken = IERC20Token(0xc0829421C1d260BD3cB3E0F06cfE2D52db2cE315);
	 
	IERC20Token BNTToken = IERC20Token(0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C);
	 
	bool buyFlag = false;  
	 
	IERC20Token[8]	relays = [
			IERC20Token(0x507b06c23d7Cb313194dBF6A6D80297137fb5E01),
			IERC20Token(0x0F2318565f1996CB1eD2F88e172135791BC1FcBf),
			IERC20Token(0x5a4deB5704C1891dF3575d3EecF9471DA7F61Fa4),
			IERC20Token(0x564c07255AFe5050D82c8816F78dA13f2B17ac6D),
			IERC20Token(0xa7774F9386E1653645E1A08fb7Aae525B4DeDb24),
			IERC20Token(0xd2Deb679ed81238CaeF8E0c32257092cEcc8888b),
			IERC20Token(0x67563E7A0F13642068F6F999e48c690107A4571F),
			IERC20Token(0x168D7Bbf38E17941173a352f1352DF91a7771dF3)
		];
	 
	IERC20Token[8]	tokens = [
			IERC20Token(0x86Fa049857E0209aa7D9e616F7eb3b3B78ECfdb0),
			IERC20Token(0xbf2179859fc6D5BEE9Bf9158632Dc51678a4100e),
			IERC20Token(0xA15C7Ebe1f07CaF6bFF097D8a589fb8AC49Ae5B3),
			IERC20Token(0x6758B7d441a9739b98552B373703d8d3d14f9e62),
			IERC20Token(0x419c4dB4B9e25d6Db2AD9691ccb832C8D9fDA05E),
			IERC20Token(0x68d57c9a1C35f63E2c83eE8e49A64e9d70528D25),
			IERC20Token(0x39Bb259F66E1C59d5ABEF88375979b4D20D98022),
			IERC20Token(0x595832F8FC6BF59c85C527fEC3740A1b7a361269)
		];
	 
	mapping(uint8 => IERC20Token[]) paths;
	mapping(uint8 => IERC20Token[]) reversePaths;
	 
	address public feeWallet;
	uint256 public rate = 10000;
	 
	string public name = "MULTIPLE INVEST BNT";
    uint8 public decimals = 18;
    string public symbol = "MIB"; 
    string public version = '1';

	constructor(address _feeWallet) public {
		feeWallet = _feeWallet;

		paths[0] = [ETHToken,BNTToken,BNTToken,relays[0],relays[0],relays[0],tokens[0]];
    	paths[1] = [ETHToken,BNTToken,BNTToken,relays[1],relays[1],relays[1],tokens[1]];
    	paths[2] = [ETHToken,BNTToken,BNTToken,relays[2],relays[2],relays[2],tokens[2]];
    	paths[3] = [ETHToken,BNTToken,BNTToken,relays[3],relays[3],relays[3],tokens[3]];
    	paths[4] = [ETHToken,BNTToken,BNTToken,relays[4],relays[4],relays[4],tokens[4]];
    	paths[5] = [ETHToken,BNTToken,BNTToken,relays[5],relays[5],relays[5],tokens[5]];
    	paths[6] = [ETHToken,BNTToken,BNTToken,relays[6],relays[6],relays[6],tokens[6]];
    	paths[7] = [ETHToken,BNTToken,BNTToken,relays[7],relays[7],relays[7],tokens[7]];

    	reversePaths[0] = [tokens[0],relays[0],relays[0],relays[0],BNTToken,BNTToken,ETHToken];
    	reversePaths[1] = [tokens[1],relays[1],relays[1],relays[1],BNTToken,BNTToken,ETHToken];
    	reversePaths[2] = [tokens[2],relays[2],relays[2],relays[2],BNTToken,BNTToken,ETHToken];
    	reversePaths[3] = [tokens[3],relays[3],relays[3],relays[3],BNTToken,BNTToken,ETHToken];
    	reversePaths[4] = [tokens[4],relays[4],relays[4],relays[4],BNTToken,BNTToken,ETHToken];
    	reversePaths[5] = [tokens[5],relays[5],relays[5],relays[5],BNTToken,BNTToken,ETHToken];
    	reversePaths[6] = [tokens[6],relays[6],relays[6],relays[6],BNTToken,BNTToken,ETHToken];
    	reversePaths[7] = [tokens[7],relays[7],relays[7],relays[7],BNTToken,BNTToken,ETHToken];
	}

	function viewTokenName(uint8 _index) public view returns(string){
		return tokens[_index].name();
	}

	function viewMaxGasPrice() public view returns(uint256){
		return BancorGas.gasPrice();
	}

	function updateBancorContracts(
		IBancorConverter _BancorConverter,
		IBancorQuickConverter _Bancor,
		IBancorGasPriceLimit _BancorGas) public onlyAdmin{

		BancorConverter = _BancorConverter;
		Bancor = _Bancor;
		BancorGas = _BancorGas;
	}

	function valueOnContract() public view returns (uint256){

		ISmartToken smartToken;
        IERC20Token toToken;
        ITokenConverter converter;
        IERC20Token[] memory _path;
        uint256 pathLength;
        uint256 sumUp;
        uint256 _amount;
        IERC20Token _fromToken;

        for(uint8 j=0;j<8;j++){
        	_path = reversePaths[j];
        	 
	        pathLength = _path.length;
	        _fromToken = _path[0];
	        _amount = _fromToken.balanceOf(address(this));

	        for (uint256 i = 1; i < pathLength; i += 2) {
	            smartToken = ISmartToken(_path[i]);
	            toToken = _path[i + 1];
	            converter = ITokenConverter(smartToken.owner());

	             
	            _amount = converter.getReturn(_fromToken, toToken, _amount);
	            _fromToken = toToken;
	        }
	        
	        sumUp += _amount;
        }

        return sumUp;

	}

	function buy() public payable {
	    BancorGas.validateGasPrice(tx.gasprice);

	    if(totalSupply >= 10000000*10**18){
	    	buyFlag = true;
	    }

		if(buyFlag == false){
			tokenBuy = msg.value.mul(rate);
		} else {

			uint256 valueStored = valueOnContract();
			uint256 tokenBuy;

			if(totalSupply > valueStored){

				uint256 tempRate = totalSupply.div(valueStored);  
				tokenBuy = msg.value.mul(tempRate);  

			} else {
				
				uint256 tempPrice = valueStored.div(totalSupply);  
				tokenBuy = msg.value.div(tempPrice);  

			}
		}

		uint256 ethFee = msg.value.mul(5);
		ethFee = ethFee.div(1000);  
		uint256 ethToInvest = msg.value.sub(ethFee);
		 
		feeWallet.transfer(ethFee);
		 
		invest(ethToInvest);
		 
		mintToken(msg.sender,tokenBuy);

	}

	function invest(uint256 _amount) private {
		uint256 standarValue = _amount.div(8);  

		for(uint8 i=0; i<8; i++){ 
			Bancor.convertForPrioritized.value(standarValue)(paths[i],standarValue,1,address(this),0,0,0,0x0,0x0);
		}

	}

	function sell(address _target, uint256 _amount) private {
		uint256 tempBalance;
		uint256 tempFee;
		uint256 dividedSupply = totalSupply.div(1e5);  

		if(dividedSupply == 0 || _amount < dividedSupply) revert();
		
		uint256 factor = _amount.div(dividedSupply);

		if( factor == 0) revert();

		burnToken(_target, _amount);
		
		for(uint8 i=0;i<8;i++){
			tempBalance = tokens[i].balanceOf(this);
			tempBalance = tempBalance.mul(factor);
			tempBalance = tempBalance.div(1e5);
			tempFee = tempBalance.mul(5);
			tempFee = tempFee.div(1000);  
			tempBalance = tempBalance.sub(tempFee);

			tokens[i].transfer(feeWallet,tempFee);
			tokens[i].transfer(_target,tempBalance);
		}
		

	}
	
	function () public payable{
		buy();
	}

}