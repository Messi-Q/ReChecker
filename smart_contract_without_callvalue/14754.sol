pragma solidity ^0.4.23;


 
contract Ownable {
	
	 
	address private owner;
	
	 
	constructor() public {
		owner = msg.sender;
	}
	
	 
	modifier onlyOwner() {
		require( 
			msg.sender == owner,
			'Only the administrator can change this'
		);
		_;
	}
	
}


 
contract Blockchainedlove is Ownable {
	
	 
    string public partner_1_name;
    string public partner_2_name;
	string public contract_date;
	bool public is_active;
	
	 
	constructor() public {
		partner_1_name = 'Andrii Shekhirev';
		partner_2_name = 'Inga Berkovica';
		contract_date = '23 June 2009';
		is_active = true;
	}
	
	 
	function updateStatus(bool _status) public onlyOwner {
		is_active = _status;
		emit StatusChanged(is_active);
	}
	
	 
	event StatusChanged(bool NewStatus);
	
}