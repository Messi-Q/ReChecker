pragma solidity 0.4.22;

contract Controlled {
     
     
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() public { controller = msg.sender;}

     
     
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }
}

 
contract TokenController {
     
     
     
    function proxyPayment(address _owner) public payable returns(bool);

     
     
     
     
     
     
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

     
     
     
     
     
     
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);
}

 

 
 
 
 
 
 
 


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
}

 
 
 
contract MiniMeToken is Controlled {

    string public name;                 
    uint8 public decimals;              
    string public symbol;               
    string public version = 'MMT_0.2';  


     
     
     
    struct  Checkpoint {

         
        uint128 fromBlock;

         
        uint128 value;
    }

     
     
    MiniMeToken public parentToken;

     
     
    uint public parentSnapShotBlock;

     
    uint public creationBlock;

     
     
     
    mapping (address => Checkpoint[]) balances;

     
    mapping (address => mapping (address => uint256)) allowed;

     
    Checkpoint[] totalSupplyHistory;

     
    bool public transfersEnabled;

     
    MiniMeTokenFactory public tokenFactory;

 
 
 

     
     
     
     
     
     
     
     
     
     
     
     
     
    function MiniMeToken(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                  
        decimals = _decimalUnits;                           
        symbol = _tokenSymbol;                              
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }


 
 
 

     
     
     
     
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

     
     
     
     
     
     
    function transferFrom(address _from, address _to, uint256 _amount
    ) public returns (bool success) {

         
         
         
         
        if (msg.sender != controller) {
            require(transfersEnabled);

             
            require(allowed[_from][msg.sender] >= _amount);
            allowed[_from][msg.sender] -= _amount;
        }
        doTransfer(_from, _to, _amount);
        return true;
    }

     
     
     
     
     
     
    function doTransfer(address _from, address _to, uint _amount
    ) internal {

           if (_amount == 0) {
               emit Transfer(_from, _to, _amount);     
               return;
           }

           require(parentSnapShotBlock < block.number);

            
           require((_to != 0) && (_to != address(this)));

            
            
           uint previousBalanceFrom = balanceOfAt(_from, block.number);

           require(previousBalanceFrom >= _amount);

            
           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

            
            
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

            
            
           uint previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo);  
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

            
           emit Transfer(_from, _to, _amount);

    }

     
     
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

     
     
     
     
     
     
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);

         
         
         
         
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

         
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
        }

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

     
     
     
     
     
    function allowance(address _owner, address _spender
    ) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

     
     
     
     
     
     
     
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) public returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

     
     
    function totalSupply() public constant returns (uint) {
        return totalSupplyAt(block.number);
    }


 
 
 

     
     
     
     
    function balanceOfAt(address _owner, uint _blockNumber) public constant
        returns (uint) {

         
         
         
         
         
        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                 
                return 0;
            }

         
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

     
     
     
    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {

         
         
         
         
         
        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

         
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

 
 
 

     
     
     
     
     
     
     
     
     
     
    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) public returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

         
        emit NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

 
 
 

     
     
     
     
    function generateTokens(address _owner, uint _amount
    ) public onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply);  
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo);  
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        emit Transfer(0, _owner, _amount);
        return true;
    }


     
     
     
     
    function destroyTokens(address _owner, uint _amount
    ) onlyController public returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        emit Transfer(_owner, 0, _amount);
        return true;
    }

 
 
 


     
     
    function enableTransfers(bool _transfersEnabled) public onlyController {
        transfersEnabled = _transfersEnabled;
    }

 
 
 

     
     
     
     
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

         
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

         
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

     
     
     
     
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

     
     
     
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

     
    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

     
     
     
    function () public payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }

 
 
 

     
     
     
     
    function claimTokens(address _token) public onlyController {
        if (_token == 0x0) {
            controller.transfer(address(this).balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        emit ClaimedTokens(_token, controller, balance);
    }

 
 
 
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}


 
 
 

 
 
 
contract MiniMeTokenFactory {

     
     
     
     
     
     
     
     
     
     
    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public returns (MiniMeToken) {
        MiniMeToken newToken = new MiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}

 

contract DestructibleMiniMeToken is MiniMeToken {

  address terminator;

  function DestructibleMiniMeToken(
      address _tokenFactory,
      address _parentToken,
      uint _parentSnapShotBlock,
      string _tokenName,
      uint8 _decimalUnits,
      string _tokenSymbol,
      bool _transfersEnabled,
      address _terminator
  ) public MiniMeToken(
      _tokenFactory,
      _parentToken,
      _parentSnapShotBlock,
      _tokenName,
      _decimalUnits,
      _tokenSymbol,
      _transfersEnabled
    ) {
        terminator = _terminator;
      }

  function recycle() public {
    require(msg.sender == terminator);
    selfdestruct(terminator);
  }
}

contract DestructibleMiniMeTokenFactory {

     
     
     
     
     
     
     
     
     
     
    function createDestructibleCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public returns (DestructibleMiniMeToken) {
        DestructibleMiniMeToken newToken = new DestructibleMiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled,
            msg.sender
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}


contract Ownable {
  
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
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

}

 

 
 
contract TokenListingManager is Ownable {

    address constant NECTAR_TOKEN = 0xCc80C051057B774cD75067Dc48f8987C4Eb97A5e;
    address constant TOKEN_FACTORY = 0x6EB97237B8bc26E8057793200207bB0a2A83C347;
    uint constant VOTING_DURATION = 14;

    struct TokenProposal {
        address[10] consideredTokens;
        uint startBlock;
        uint startTime;
        uint duration;
        address votingToken;
        uint[10] yesVotes;
    }

    TokenProposal[] tokenBatches;

    DestructibleMiniMeTokenFactory public tokenFactory;
    address nectarToken;
    mapping(address => bool) admins;

    modifier onlyAdmins() {
        require(isAdmin(msg.sender));
        _;
    }

    function TokenListingManager() public {
        tokenFactory = DestructibleMiniMeTokenFactory(TOKEN_FACTORY);
        nectarToken = NECTAR_TOKEN;
        admins[msg.sender] = true;
    }

     
     
    function startTokenVotes(address[10] tokens) public onlyAdmins {
        uint _proposalId = tokenBatches.length;
        if(_proposalId > 0) {
          TokenProposal memory op = tokenBatches[_proposalId - 1];
          DestructibleMiniMeToken(op.votingToken).recycle();
        }
        tokenBatches.length++;
        TokenProposal storage p = tokenBatches[_proposalId];
        p.duration = VOTING_DURATION * (1 days);

        p.consideredTokens = tokens;

        p.votingToken = tokenFactory.createDestructibleCloneToken(
                nectarToken,
                getBlockNumber(),
                appendUintToString("EfxTokenVotes-", _proposalId),
                MiniMeToken(nectarToken).decimals(),
                appendUintToString("EfxTokenVotes-", _proposalId),
                true);

        p.startTime = now;
        p.startBlock = getBlockNumber();

        emit NewTokens(_proposalId);
    }

     
     
    function vote(uint _tokenIndex) public {
         
        require(tokenBatches.length > 0);
        uint _proposalId = tokenBatches.length - 1;
        require(_tokenIndex < 10);

        TokenProposal memory p = tokenBatches[_proposalId];

        require(now < p.startTime + p.duration);

        uint amount = DestructibleMiniMeToken(p.votingToken).balanceOf(msg.sender);
        require(amount > 0);

        require(DestructibleMiniMeToken(p.votingToken).transferFrom(msg.sender, address(this), amount));

        tokenBatches[_proposalId].yesVotes[_tokenIndex] += amount;

        emit Vote(_proposalId, msg.sender, tokenBatches[_proposalId].consideredTokens[_tokenIndex], amount);
    }

     
     
    function addAdmin(address _newAdmin) public onlyAdmins {
        admins[_newAdmin] = true;
    }

     
     
    function removeAdmin(address _admin) public onlyOwner {
        admins[_admin] = false;
    }

     
     
    function proposal(uint _proposalId) public view returns(
        uint _startBlock,
        uint _startTime,
        uint _duration,
        bool _active,
        bool _finalized,
        uint[10] _votes,
        address[10] _tokens,
        address _votingToken,
        bool _hasBalance
    ) {
        require(_proposalId < tokenBatches.length);

        TokenProposal memory p = tokenBatches[_proposalId];
        _startBlock = p.startBlock;
        _startTime = p.startTime;
        _duration = p.duration;
        _finalized = (_startTime+_duration < now);
        _active = !_finalized && (p.startBlock < getBlockNumber());
        _votes = p.yesVotes;
        _tokens = p.consideredTokens;
        _votingToken = p.votingToken;
        _hasBalance = (p.votingToken == 0x0) ? false : (DestructibleMiniMeToken(p.votingToken).balanceOf(msg.sender) > 0);
    }

    function appendUintToString(string inStr, uint v) private pure returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        if (v==0) {
            reversed[i++] = byte(48);
        } else {
            while (v != 0) {
                uint remainder = v % 10;
                v = v / 10;
                reversed[i++] = byte(48 + remainder);
            }
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j < i; j++) {
            s[j + inStrb.length] = reversed[i - 1 - j];
        }
        str = string(s);
    }

    function isAdmin(address _admin) public view returns(bool) {
        return admins[_admin];
    }

    function proxyPayment(address ) public payable returns(bool) {
        return false;
    }

    function onTransfer(address , address , uint ) public pure returns(bool) {
        return true;
    }

    function onApprove(address , address , uint ) public pure returns(bool) {
        return true;
    }

    function getBlockNumber() internal constant returns (uint) {
        return block.number;
    }

    event Vote(uint indexed idProposal, address indexed _voter, address chosenToken, uint amount);
    event NewTokens(uint indexed idProposal);
}