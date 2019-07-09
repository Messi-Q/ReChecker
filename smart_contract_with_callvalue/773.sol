pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;
pragma experimental "v0.5.0";

 
library SafeMath {
	int256 constant private INT256_MIN = -2**255;

	 
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		 
		 
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b);

		return c;
	}

	 
	function mul(int256 a, int256 b) internal pure returns (int256) {
		 
		 
		if (a == 0) {
			return 0;
		}

		require(!(a == -1 && b == INT256_MIN));  

		int256 c = a * b;
		require(c / a == b);

		return c;
	}

	 
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		 
		require(b > 0);
		uint256 c = a / b;
		 

		return c;
	}

	 
	function div(int256 a, int256 b) internal pure returns (int256) {
		require(b != 0);  
		require(!(b == -1 && a == INT256_MIN));  

		int256 c = a / b;

		return c;
	}

	 
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a);
		uint256 c = a - b;

		return c;
	}

	 
	function sub(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a - b;
		require((b >= 0 && c <= a) || (b < 0 && c > a));

		return c;
	}

	 
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a);

		return c;
	}

	 
	function add(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a + b;
		require((b >= 0 && c >= a) || (b < 0 && c < a));

		return c;
	}

	 
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b != 0);
		return a % b;
	}
}

 
library SafeMathFixedPoint {
	using SafeMath for uint256;

	function mul27(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x.mul(y).add(5 * 10**26).div(10**27);
	}
	function mul18(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x.mul(y).add(5 * 10**17).div(10**18);
	}

	function div18(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x.mul(10**18).add(y.div(2)).div(y);
	}
	function div27(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x.mul(10**27).add(y.div(2)).div(y);
	}
}

 
contract ERC20Basic {
	function totalSupply() public view returns (uint256);
	function balanceOf(address who) public view returns (uint256);
	function transfer(address to, uint256 value) public returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
}

 
contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) public view returns (uint256);
	function transferFrom(address from, address to, uint256 value) public returns (bool);
	function approve(address spender, uint256 value) public returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract Ownable {
	address public owner;

	event OwnershipRenounced(address indexed previousOwner);
	event OwnershipTransferred(
		address indexed previousOwner,
		address indexed newOwner
	);

	 
	constructor() public {
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

	 
	function renounceOwnership() public onlyOwner {
		emit OwnershipRenounced(owner);
		owner = address(0);
	}
}

 
contract Claimable is Ownable {
	address public pendingOwner;

	 
	modifier onlyPendingOwner() {
		require(msg.sender == pendingOwner);
		_;
	}

	 
	function transferOwnership(address newOwner) onlyOwner public {
		pendingOwner = newOwner;
	}

	 
	function claimOwnership() onlyPendingOwner public {
		emit OwnershipTransferred(owner, pendingOwner);
		owner = pendingOwner;
		pendingOwner = address(0);
	}
}

 
contract Pausable is Ownable {
	event Pause();
	event Unpause();

	bool public paused = false;


	 
	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	 
	modifier whenPaused() {
		require(paused);
		_;
	}

	 
	function pause() onlyOwner whenNotPaused public {
		paused = true;
		emit Pause();
	}

	 
	function unpause() onlyOwner whenPaused public {
		paused = false;
		emit Unpause();
	}
}

contract Dai is ERC20 {

}

contract Weth is ERC20 {
	function deposit() public payable;
	function withdraw(uint wad) public;
}

contract Mkr is ERC20 {

}

contract Peth is ERC20 {

}

contract MatchingMarket {
	function getBuyAmount(ERC20 tokenToBuy, ERC20 tokenToPay, uint256 amountToPay) external view returns(uint256 amountBought);
	function getPayAmount(ERC20 tokenToPay, ERC20 tokenToBuy, uint amountToBuy) public constant returns (uint amountPaid);
	function getBestOffer(ERC20 sell_gem, ERC20 buy_gem) public constant returns(uint offerId);
	function getWorseOffer(uint id) public constant returns(uint offerId);
	function getOffer(uint id) public constant returns (uint pay_amt, ERC20 pay_gem, uint buy_amt, ERC20 buy_gem);
	function sellAllAmount(ERC20 pay_gem, uint pay_amt, ERC20 buy_gem, uint min_fill_amount) public returns (uint fill_amt);
	function buyAllAmount(ERC20 buy_gem, uint buy_amt, ERC20 pay_gem, uint max_fill_amount) public returns (uint fill_amt);
}

contract DSValue {
	function read() external view returns(bytes32);
}

contract Maker {
	function sai() external view returns(Dai);
	function gem() external view returns(Weth);
	function gov() external view returns(Mkr);
	function skr() external view returns(Peth);
	function pip() external view returns(DSValue);
	function pep() external view returns(DSValue);

	 
	 uint256 public gap;

	struct Cup {
		 
		address lad;
		 
		uint256 ink;
		 
		uint256 art;
		 
		uint256 ire;
	}

	uint256 public cupi;
	mapping (bytes32 => Cup) public cups;

	function lad(bytes32 cup) public view returns (address);
	function per() public view returns (uint ray);
	function tab(bytes32 cup) public returns (uint);
	function ink(bytes32 cup) public returns (uint);
	function rap(bytes32 cup) public returns (uint);
	function chi() public returns (uint);

	function open() public returns (bytes32 cup);
	function give(bytes32 cup, address guy) public;
	function lock(bytes32 cup, uint wad) public;
	function free(bytes32 cup, uint wad) public;
	function draw(bytes32 cup, uint wad) public;
	function join(uint wad) public;
	function exit(uint wad) public;
	function wipe(bytes32 cup, uint wad) public;
}

contract DSProxy {
	 
	address public owner;

	function execute(address _target, bytes _data) public payable returns (bytes32 response);
}

contract ProxyRegistry {
	mapping(address => DSProxy) public proxies;
	function build(address owner) public returns (DSProxy proxy);
}

contract LiquidLong is Ownable, Claimable, Pausable {
	using SafeMath for uint256;
	using SafeMathFixedPoint for uint256;

	uint256 public providerFeePerEth;

	MatchingMarket public matchingMarket;
	Maker public maker;
	Dai public dai;
	Weth public weth;
	Peth public peth;
	Mkr public mkr;

	ProxyRegistry public proxyRegistry;

	struct CDP {
		uint256 id;
		uint256 debtInAttodai;
		uint256 lockedAttoeth;
		address owner;
		bool userOwned;
	}

	event NewCup(address user, uint256 cup);
	event CloseCup(address user, uint256 cup);

	constructor(MatchingMarket _matchingMarket, Maker _maker, ProxyRegistry _proxyRegistry) public payable {
		providerFeePerEth = 0.01 ether;

		matchingMarket = _matchingMarket;
		maker = _maker;
		dai = maker.sai();
		weth = maker.gem();
		peth = maker.skr();
		mkr = maker.gov();

		 
		dai.approve(address(_matchingMarket), uint256(-1));
		weth.approve(address(_matchingMarket), uint256(-1));
		 
		dai.approve(address(_maker), uint256(-1));
		mkr.approve(address(_maker), uint256(-1));
		 
		weth.approve(address(_maker), uint256(-1));
		 
		peth.approve(address(_maker), uint256(-1));

		proxyRegistry = _proxyRegistry;

		if (msg.value > 0) {
			weth.deposit.value(msg.value)();
		}
	}

	 
	function () external payable {
	}

	function wethDeposit() public payable {
		weth.deposit.value(msg.value)();
	}

	function wethWithdraw(uint256 _amount) public onlyOwner {
		weth.withdraw(_amount);
		owner.transfer(_amount);
	}

	function attowethBalance() public view returns (uint256 _attoweth) {
		return weth.balanceOf(address(this));
	}

	function ethWithdraw() public onlyOwner {
		uint256 _amount = address(this).balance;
		owner.transfer(_amount);
	}

	function transferTokens(ERC20 _token) public onlyOwner {
		_token.transfer(owner, _token.balanceOf(this));
	}

	function ethPriceInUsd() public view returns (uint256 _attousd) {
		return uint256(maker.pip().read());
	}

	function estimateDaiSaleProceeds(uint256 _attodaiToSell) public view returns (uint256 _daiPaid, uint256 _wethBought) {
		return getPayPriceAndAmount(dai, weth, _attodaiToSell);
	}

	 
	function getPayPriceAndAmount(ERC20 _payGem, ERC20 _buyGem, uint256 _payDesiredAmount) public view returns (uint256 _paidAmount, uint256 _boughtAmount) {
		uint256 _offerId = matchingMarket.getBestOffer(_buyGem, _payGem);
		while (_offerId != 0) {
			uint256 _payRemaining = _payDesiredAmount.sub(_paidAmount);
			(uint256 _buyAvailableInOffer,  , uint256 _payAvailableInOffer,) = matchingMarket.getOffer(_offerId);
			if (_payRemaining <= _payAvailableInOffer) {
				uint256 _buyRemaining = _payRemaining.mul(_buyAvailableInOffer).div(_payAvailableInOffer);
				_paidAmount = _paidAmount.add(_payRemaining);
				_boughtAmount = _boughtAmount.add(_buyRemaining);
				break;
			}
			_paidAmount = _paidAmount.add(_payAvailableInOffer);
			_boughtAmount = _boughtAmount.add(_buyAvailableInOffer);
			_offerId = matchingMarket.getWorseOffer(_offerId);
		}
		return (_paidAmount, _boughtAmount);
	}

	function estimateDaiPurchaseCosts(uint256 _attodaiToBuy) public view returns (uint256 _wethPaid, uint256 _daiBought) {
		return getBuyPriceAndAmount(weth, dai, _attodaiToBuy);
	}

	 
	function getBuyPriceAndAmount(ERC20 _payGem, ERC20 _buyGem, uint256 _buyDesiredAmount) public view returns (uint256 _paidAmount, uint256 _boughtAmount) {
		uint256 _offerId = matchingMarket.getBestOffer(_buyGem, _payGem);
		while (_offerId != 0) {
			uint256 _buyRemaining = _buyDesiredAmount.sub(_boughtAmount);
			(uint256 _buyAvailableInOffer, , uint256 _payAvailableInOffer,) = matchingMarket.getOffer(_offerId);
			if (_buyRemaining <= _buyAvailableInOffer) {
				 
				uint256 _payRemaining = _buyRemaining.mul(_payAvailableInOffer).div(_buyAvailableInOffer);
				_paidAmount = _paidAmount.add(_payRemaining);
				_boughtAmount = _boughtAmount.add(_buyRemaining);
				break;
			}
			_paidAmount = _paidAmount.add(_payAvailableInOffer);
			_boughtAmount = _boughtAmount.add(_buyAvailableInOffer);
			_offerId = matchingMarket.getWorseOffer(_offerId);
		}
		return (_paidAmount, _boughtAmount);
	}

	modifier wethBalanceIncreased() {
		uint256 _startingAttowethBalance = weth.balanceOf(this);
		_;
		require(weth.balanceOf(this) > _startingAttowethBalance);
	}

	 
	function openCdp(uint256 _leverage, uint256 _leverageSizeInAttoeth, uint256 _allowedFeeInAttoeth, address _affiliateAddress) public payable wethBalanceIncreased returns (bytes32 _cdpId) {
		require(_leverage >= 100 && _leverage <= 300);
		uint256 _lockedInCdpInAttoeth = _leverageSizeInAttoeth.mul(_leverage).div(100);
		uint256 _loanInAttoeth = _lockedInCdpInAttoeth.sub(_leverageSizeInAttoeth);
		uint256 _feeInAttoeth = _loanInAttoeth.mul18(providerFeePerEth);
		require(_feeInAttoeth <= _allowedFeeInAttoeth);
		uint256 _drawInAttodai = _loanInAttoeth.mul18(uint256(maker.pip().read()));
		uint256 _attopethLockedInCdp = _lockedInCdpInAttoeth.div27(maker.per());

		 
		weth.deposit.value(msg.value)();
		 
		_cdpId = maker.open();
		 
		maker.join(_attopethLockedInCdp);
		 
		maker.lock(_cdpId, _attopethLockedInCdp);
		 
		maker.draw(_cdpId, _drawInAttodai);
		 
		sellDai(_drawInAttodai, _lockedInCdpInAttoeth, _feeInAttoeth);
		 
		if (_affiliateAddress != address(0)) {
			 
			 
			weth.transfer(_affiliateAddress, _feeInAttoeth.div(2));
		}

		emit NewCup(msg.sender, uint256(_cdpId));

		giveCdpToProxy(msg.sender, _cdpId);
	}

	function giveCdpToProxy(address _ownerOfProxy, bytes32 _cdpId) private {
		DSProxy _proxy = proxyRegistry.proxies(_ownerOfProxy);
		if (_proxy == DSProxy(0) || _proxy.owner() != _ownerOfProxy) {
			_proxy = proxyRegistry.build(_ownerOfProxy);
		}
		 
		maker.give(_cdpId, _proxy);
	}

	 
	function sellDai(uint256 _drawInAttodai, uint256 _lockedInCdpInAttoeth, uint256 _feeInAttoeth) private {
		uint256 _wethBoughtInAttoweth = matchingMarket.sellAllAmount(dai, _drawInAttodai, weth, 0);
		 
		uint256 _refundDue = msg.value.add(_wethBoughtInAttoweth).sub(_lockedInCdpInAttoeth).sub(_feeInAttoeth);
		if (_refundDue > 0) {
			weth.withdraw(_refundDue);
			require(msg.sender.call.value(_refundDue)());
		}
	}

	 
	function closeCdp(LiquidLong _liquidLong, uint256 _cdpId, uint256 _minimumValueInAttoeth) external returns (uint256 _payoutOwnerInAttoeth) {
		address _owner = DSProxy(this).owner();
		uint256 _startingAttoethBalance = _owner.balance;

		 
		Maker _maker = _liquidLong.maker();

		 
		uint256 _lockedPethInAttopeth = _maker.ink(bytes32(_cdpId));
		if (_lockedPethInAttopeth == 0) return 0;

		_maker.give(bytes32(_cdpId), _liquidLong);
		_payoutOwnerInAttoeth = _liquidLong.closeGiftedCdp(bytes32(_cdpId), _minimumValueInAttoeth, _owner);

		require(_maker.lad(bytes32(_cdpId)) == address(this));
		require(_owner.balance > _startingAttoethBalance);
		return _payoutOwnerInAttoeth;
	}

	 
	function closeGiftedCdp(bytes32 _cdpId, uint256 _minimumValueInAttoeth, address _recipient) external wethBalanceIncreased returns (uint256 _payoutOwnerInAttoeth) {
		require(_recipient != address(0));
		uint256 _lockedPethInAttopeth = maker.ink(_cdpId);
		uint256 _debtInAttodai = maker.tab(_cdpId);

		 
		uint256 _lockedWethInAttoweth = _lockedPethInAttopeth.div27(maker.per());

		 
		 
		uint256 _wethSoldInAttoweth = matchingMarket.buyAllAmount(dai, _debtInAttodai, weth, _lockedWethInAttoweth);
		uint256 _providerFeeInAttoeth = _wethSoldInAttoweth.mul18(providerFeePerEth);

		 
		 
		 
		uint256 _mkrBalanceBeforeInAttomkr = mkr.balanceOf(this);
		maker.wipe(_cdpId, _debtInAttodai);
		uint256 _mkrBurnedInAttomkr = _mkrBalanceBeforeInAttomkr.sub(mkr.balanceOf(this));
		uint256 _ethValueOfBurnedMkrInAttoeth = _mkrBurnedInAttomkr.mul(uint256(maker.pep().read()))  
			.div(uint256(maker.pip().read()));  

		 
		_payoutOwnerInAttoeth = _lockedWethInAttoweth.sub(_wethSoldInAttoweth).sub(_providerFeeInAttoeth).sub(_ethValueOfBurnedMkrInAttoeth);

		 
		require(_payoutOwnerInAttoeth >= _minimumValueInAttoeth);

		 
		 
		maker.free(_cdpId, _lockedPethInAttopeth);
		maker.exit(_lockedPethInAttopeth);

		 
		maker.give(_cdpId, msg.sender);

		weth.withdraw(_payoutOwnerInAttoeth);
		require(_recipient.call.value(_payoutOwnerInAttoeth)());
		emit CloseCup(msg.sender, uint256(_cdpId));
	}

	 
	function getCdps(address _owner, uint32 _offset, uint32 _pageSize) public returns (CDP[] _cdps) {
		 
		DSProxy _cdpProxy = proxyRegistry.proxies(_owner);
		require(_cdpProxy != address(0));
		return getCdpsByAddresses(_owner, _cdpProxy, _offset, _pageSize);
	}

	 
	function getCdpsByAddresses(address _owner, address _proxy, uint32 _offset, uint32 _pageSize) public returns (CDP[] _cdps) {
		_cdps = new CDP[](getCdpCountByOwnerAndProxy(_owner, _proxy, _offset, _pageSize));
		uint256 _cdpCount = cdpCount();
		uint32 _matchCount = 0;
		for (uint32 _i = _offset; _i <= _cdpCount && _i < _offset + _pageSize; ++_i) {
			address _cdpOwner = maker.lad(bytes32(_i));
			if (_cdpOwner != _owner && _cdpOwner != _proxy) continue;
			_cdps[_matchCount] = getCdpDetailsById(_i, _owner);
			++_matchCount;
		}
		return _cdps;
	}

	function cdpCount() public view returns (uint32 _cdpCount) {
		uint256 count = maker.cupi();
		require(count < 2**32);
		return uint32(count);
	}

	function getCdpCountByOwnerAndProxy(address _owner, address _proxy, uint32 _offset, uint32 _pageSize) private view returns (uint32 _count) {
		uint256 _cdpCount = cdpCount();
		_count = 0;
		for (uint32 _i = _offset; _i <= _cdpCount && _i < _offset + _pageSize; ++_i) {
			address _cdpOwner = maker.lad(bytes32(_i));
			if (_cdpOwner != _owner && _cdpOwner != _proxy) continue;
			++_count;
		}
		return _count;
	}

	function getCdpDetailsById(uint32 _cdpId, address _owner) private returns (CDP _cdp) {
		(address _cdpOwner, uint256 _collateral,,) = maker.cups(bytes32(_cdpId));
		 
		uint256 _debtInAttodai = maker.tab(bytes32(_cdpId));
		 
		uint256 _lockedAttoeth = (_collateral + 1).mul27(maker.gap().mul18(maker.per()));
		_cdp = CDP({
			id: _cdpId,
			debtInAttodai: _debtInAttodai,
			lockedAttoeth: _lockedAttoeth,
			owner: _cdpOwner,
			userOwned: _cdpOwner == _owner
		});
		return _cdp;
	}
}