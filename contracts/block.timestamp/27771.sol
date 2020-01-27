pragma solidity ^0.4.18;

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    function DSAuth() public {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
    public
    auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
    public
    auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}
contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}
contract DSStop is DSNote, DSAuth {

    bool public stopped;

    modifier stoppable {
        require(!stopped);
        _;
    }
    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }

}
contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
}

contract ERC20 {
    /// @return total amount of tokens
    function totalSupply() constant public returns (uint256 supply);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant public returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract Coin is ERC20, DSStop {
    string internal c_name;
    string internal c_symbol;
    uint8 internal c_decimals = 0;
    uint256 internal c_totalSupply;
    mapping(address => uint256) internal c_balances;
    mapping(address => mapping(address => uint256)) internal c_approvals;

    function init(uint256 total_lemos, string token_name, string token_symbol) internal {
        c_balances[msg.sender] = total_lemos;
        c_totalSupply = total_lemos;
        c_name = token_name;
        c_symbol = token_symbol;
    }

    function() public {
        assert(false);
    }

    function name() constant public returns (string) {
        return c_name;
    }

    function symbol() constant public returns (string) {
        return c_symbol;
    }

    function decimals() constant public returns (uint8) {
        return c_decimals;
    }

    function totalSupply() constant public returns (uint256) {
        return c_totalSupply;
    }

    function balanceOf(address _owner) constant public returns (uint256) {
        return c_balances[_owner];
    }

    function approve(address _spender, uint256 _value) public stoppable returns (bool) {
        // uint never less than 0. The negative number will become to a big positive number
        require(_value < c_totalSupply);

        c_approvals[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return c_approvals[_owner][_spender];
    }

}

contract FreezerAuthority is DSAuthority {
    address[] internal c_freezers;
    // sha3("setFreezing(address,uint256,uint256,uint8)").slice(0,10)
    bytes4 constant setFreezingSig = bytes4(0x51c3b8a6);
    // sha3("transferAndFreezing(address,uint256,uint256,uint256,uint8)").slice(0,10)
    bytes4 constant transferAndFreezingSig = bytes4(0xb8a1fdb6);

    function canCall(address caller, address, bytes4 sig) public view returns (bool) {
        // freezer can call setFreezing, transferAndFreezing
        if (isFreezer(caller) && sig == setFreezingSig || sig == transferAndFreezingSig) {
            return true;
        } else {
            return false;
        }
    }

    function addFreezer(address freezer) public {
        int i = indexOf(c_freezers, freezer);
        if (i < 0) {
            c_freezers.push(freezer);
        }
    }

    function removeFreezer(address freezer) public {
        int index = indexOf(c_freezers, freezer);
        if (index >= 0) {
            uint i = uint(index);
            while (i < c_freezers.length - 1) {
                c_freezers[i] = c_freezers[i + 1];
            }
            c_freezers.length--;
        }
    }

    /** Finds the index of a given value in an array. */
    function indexOf(address[] values, address value) internal pure returns (int) {
        uint i = 0;
        while (i < values.length) {
            if (values[i] == value) {
                return int(i);
            }
            i++;
        }
        return int(- 1);
    }

    function isFreezer(address addr) public constant returns (bool) {
        return indexOf(c_freezers, addr) >= 0;
    }
}

contract LemoCoin is Coin, DSMath {
    enum freezing_type_enum {
        FUND_RAISING_FREEZING,
        VIP_FREEZING
    }

    //freezing struct
    struct FreezingNode {
        uint end_stamp;
        uint num_lemos;
        freezing_type_enum freezing_type;
    }

    //freezing account list
    mapping(address => FreezingNode []) internal c_freezing_list;

    function LemoCoin(uint256 total_lemos, string token_name, string token_symbol) public {
        init(total_lemos, token_name, token_symbol);
        setAuthority(new FreezerAuthority());
    }

    function addFreezer(address freezer) auth public {
        FreezerAuthority(authority).addFreezer(freezer);
    }

    function removeFreezer(address freezer) auth public {
        FreezerAuthority(authority).removeFreezer(freezer);
    }

    event ClearExpiredFreezingEvent(address addr);
    event SetFreezingEvent(address addr, uint end_stamp, uint num_lemos, freezing_type_enum freezing_type);

    function clearExpiredFreezing(address addr) public {
        var nodes = c_freezing_list[addr];
        uint length = nodes.length;

        // find first expired index
        uint left = 0;
        while (left < length) {
            // not freezing any more
            if (nodes[left].end_stamp <= block.timestamp) {
                break;
            }
            left++;
        }

        // next frozen index
        uint right = left + 1;
        while (left < length && right < length) {
            // still freezing
            if (nodes[right].end_stamp > block.timestamp) {
                nodes[left] = nodes[right];
                left++;
            }
            right++;
        }
        if (length != left) {
            nodes.length = left;
            ClearExpiredFreezingEvent(addr);
        }
    }

    function validBalanceOf(address addr) constant public returns (uint) {
        var nodes = c_freezing_list[addr];
        uint length = nodes.length;
        uint total_lemos = balanceOf(addr);

        for (uint i = 0; i < length; ++i) {
            if (nodes[i].end_stamp > block.timestamp) {
                total_lemos = sub(total_lemos, nodes[i].num_lemos);
            }
        }

        return total_lemos;
    }

    function freezingBalanceNumberOf(address addr) constant public returns (uint) {
        return c_freezing_list[addr].length;
    }

    function freezingBalanceInfoOf(address addr, uint index) constant public returns (uint, uint, uint8) {
        return (c_freezing_list[addr][index].end_stamp, c_freezing_list[addr][index].num_lemos, uint8(c_freezing_list[addr][index].freezing_type));
    }

    function setFreezing(address addr, uint end_stamp, uint num_lemos, uint8 freezing_type) auth stoppable public {
        require(block.timestamp < end_stamp);
        // uint never less than 0. The negative number will become to a big positive number
        require(num_lemos < c_totalSupply);
        clearExpiredFreezing(addr);
        uint valid_balance = validBalanceOf(addr);
        require(valid_balance >= num_lemos);

        FreezingNode memory node = FreezingNode(end_stamp, num_lemos, freezing_type_enum(freezing_type));
        c_freezing_list[addr].push(node);

        SetFreezingEvent(addr, end_stamp, num_lemos, freezing_type_enum(freezing_type));
    }

    function transferAndFreezing(address _to, uint256 _value, uint256 freezeAmount, uint end_stamp, uint8 freezing_type) auth stoppable public returns (bool) {
        // uint never less than 0. The negative number will become to a big positive number
        require(_value < c_totalSupply);
        require(freezeAmount <= _value);

        transfer(_to, _value);
        setFreezing(_to, end_stamp, freezeAmount, freezing_type);

        return true;
    }

    function transfer(address _to, uint256 _value) stoppable public returns (bool) {
        // uint never less than 0. The negative number will become to a big positive number
        require(_value < c_totalSupply);
        clearExpiredFreezing(msg.sender);
        uint from_lemos = validBalanceOf(msg.sender);

        require(from_lemos >= _value);

        c_balances[msg.sender] = sub(c_balances[msg.sender], _value);
        c_balances[_to] = add(c_balances[_to], _value);

        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) stoppable public returns (bool) {
        // uint never less than 0. The negative number will become to a big positive number
        require(_value < c_totalSupply);
        require(c_approvals[_from][msg.sender] >= _value);

        clearExpiredFreezing(_from);
        uint from_lemos = validBalanceOf(_from);

        require(from_lemos >= _value);

        c_approvals[_from][msg.sender] = sub(c_approvals[_from][msg.sender], _value);
        c_balances[_from] = sub(c_balances[_from], _value);
        c_balances[_to] = add(c_balances[_to], _value);

        Transfer(_from, _to, _value);
        return true;
    }
}