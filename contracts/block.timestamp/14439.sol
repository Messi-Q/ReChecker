// Copyright New Alchemy Limited, 2017. All rights reserved.

pragma solidity >=0.4.10;

// Just the bits of ERC20 that we need.
contract Token {
	function balanceOf(address addr) returns(uint);
	function transfer(address to, uint amount) returns(bool);
}

contract Sale {
	address public owner;    // contract owner
	address public newOwner; // new contract owner for two-way ownership handshake
	string public notice;    // arbitrary public notice text
	uint public start;       // start time of sale
	uint public end;         // end time of sale
	uint public cap;         // Ether hard cap
	bool public live;        // sale is live right now

	event StartSale();
	event EndSale();
	event EtherIn(address from, uint amount);

	function Sale() {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function () payable {
		require(block.timestamp >= start);

		// If we've reached end-of-sale conditions, accept
		// this as the last contribution and emit the EndSale event.
		// (Technically this means we allow exactly one contribution
		// after the end of the sale.)
		// Conversely, if we haven't started the sale yet, emit
		// the StartSale event.
		if (block.timestamp > end || this.balance > cap) {
			require(live);
			live = false;
			EndSale();
		} else if (!live) {
			live = true;
			StartSale();
		}
		EtherIn(msg.sender, msg.value);
	}

	function init(uint _start, uint _end, uint _cap) onlyOwner {
		start = _start;
		end = _end;
		cap = _cap;
	}

	function softCap(uint _newend) onlyOwner {
		require(_newend >= block.timestamp && _newend >= start && _newend <= end);
		end = _newend;
	}

	// 1st half of ownership change
	function changeOwner(address next) onlyOwner {
		newOwner = next;
	}

	// 2nd half of ownership change
	function acceptOwnership() {
		require(msg.sender == newOwner);
		owner = msg.sender;
		newOwner = 0;
	}

	// put some text in the contract
	function setNotice(string note) onlyOwner {
		notice = note;
	}

	// withdraw all of the Ether
	function withdraw() onlyOwner {
		msg.sender.transfer(this.balance);
	}

	// withdraw some of the Ether
	function withdrawSome(uint value) onlyOwner {
		require(value <= this.balance);
		msg.sender.transfer(value);
	}

	// withdraw tokens to owner
	function withdrawToken(address token) onlyOwner {
		Token t = Token(token);
		require(t.transfer(msg.sender, t.balanceOf(this)));
	}

	// refund early/late tokens
	function refundToken(address token, address sender, uint amount) onlyOwner {
		Token t = Token(token);
		require(t.transfer(sender, amount));
	}
}