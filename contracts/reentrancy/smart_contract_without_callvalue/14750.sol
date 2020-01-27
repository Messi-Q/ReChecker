pragma solidity ^0.4.21;

interface ExchangeInterface {

    event Subscribed(address indexed user);
    event Unsubscribed(address indexed user);

    event Cancelled(bytes32 indexed hash);

    event Traded(
        bytes32 indexed hash,
        address makerToken,
        uint makerTokenAmount,
        address takerToken,
        uint takerTokenAmount,
        address maker,
        address taker
    );

    event Ordered(
        address maker,
        address makerToken,
        address takerToken,
        uint makerTokenAmount,
        uint takerTokenAmount,
        uint expires,
        uint nonce
    );

    function subscribe() external;
    function unsubscribe() external;

    function trade(address[3] addresses, uint[4] values, bytes signature, uint maxFillAmount) external;
    function cancel(address[3] addresses, uint[4] values) external;
    function order(address[2] addresses, uint[4] values) external;

    function canTrade(address[3] addresses, uint[4] values, bytes signature)
        external
        view
        returns (bool);

    function isSubscribed(address subscriber) external view returns (bool);
    function availableAmount(address[3] addresses, uint[4] values) external view returns (uint);
    function filled(bytes32 hash) external view returns (uint);
    function isOrdered(address user, bytes32 hash) public view returns (bool);
    function vault() public view returns (VaultInterface);

}

interface VaultInterface {

    event Deposited(address indexed user, address token, uint amount);
    event Withdrawn(address indexed user, address token, uint amount);

    event Approved(address indexed user, address indexed spender);
    event Unapproved(address indexed user, address indexed spender);

    event AddedSpender(address indexed spender);
    event RemovedSpender(address indexed spender);

    function deposit(address token, uint amount) external payable;
    function withdraw(address token, uint amount) external;
    function transfer(address token, address from, address to, uint amount) external;
    function approve(address spender) external;
    function unapprove(address spender) external;
    function isApproved(address user, address spender) external view returns (bool);
    function addSpender(address spender) external;
    function removeSpender(address spender) external;
    function latestSpender() external view returns (address);
    function isSpender(address spender) external view returns (bool);
    function tokenFallback(address from, uint value, bytes data) public;
    function balanceOf(address token, address user) public view returns (uint);

}

library SafeMath {

    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint a, uint b) internal pure returns (uint) {
        return a >= b ? a : b;
    }

    function min256(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }
}

library SignatureValidator {

    enum SignatureMode {
        EIP712,
        GETH,
        TREZOR
    }

     
     
     
     
     
    function isValidSignature(bytes32 hash, address signer, bytes signature) internal pure returns (bool) {
        require(signature.length == 66);
        SignatureMode mode = SignatureMode(uint8(signature[0]));

        uint8 v = uint8(signature[1]);
        bytes32 r;
        bytes32 s;
        assembly {
            r := mload(add(signature, 34))
            s := mload(add(signature, 66))
        }

        if (mode == SignatureMode.GETH) {
            hash = keccak256("\x19Ethereum Signed Message:\n32", hash);
        } else if (mode == SignatureMode.TREZOR) {
            hash = keccak256("\x19Ethereum Signed Message:\n\x20", hash);
        }

        return ecrecover(hash, v, r, s) == signer;
    }
}

library OrderLibrary {

    bytes32 constant public HASH_SCHEME = keccak256(
        "address Taker Token",
        "uint Taker Token Amount",
        "address Maker Token",
        "uint Maker Token Amount",
        "uint Expires",
        "uint Nonce",
        "address Maker",
        "address Exchange"
    );

    struct Order {
        address maker;
        address makerToken;
        address takerToken;
        uint makerTokenAmount;
        uint takerTokenAmount;
        uint expires;
        uint nonce;
    }

     
     
     
    function hash(Order memory order) internal view returns (bytes32) {
        return keccak256(
            HASH_SCHEME,
            keccak256(
                order.takerToken,
                order.takerTokenAmount,
                order.makerToken,
                order.makerTokenAmount,
                order.expires,
                order.nonce,
                order.maker,
                this
            )
        );
    }

     
     
     
     
    function createOrder(address[3] addresses, uint[4] values) internal pure returns (Order memory) {
        return Order({
            maker: addresses[0],
            makerToken: addresses[1],
            takerToken: addresses[2],
            makerTokenAmount: values[0],
            takerTokenAmount: values[1],
            expires: values[2],
            nonce: values[3]
        });
    }
}

contract Ownable {

    address public owner;

    modifier onlyOwner {
        require(isOwner(msg.sender));
        _;
    }

    function Ownable() public {
        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function isOwner(address _address) public view returns (bool) {
        return owner == _address;
    }
}

interface ERC20 {

    function totalSupply() public view returns (uint);
    function balanceOf(address owner) public view returns (uint);
    function allowance(address owner, address spender) public view returns (uint);
    function transfer(address to, uint value) public returns (bool);
    function transferFrom(address from, address to, uint value) public returns (bool);
    function approve(address spender, uint value) public returns (bool);

}

interface HookSubscriber {

    function tradeExecuted(address token, uint amount) external;

}

contract Exchange is Ownable, ExchangeInterface {

    using SafeMath for *;
    using OrderLibrary for OrderLibrary.Order;

    address constant public ETH = 0x0;

    uint256 constant public MAX_FEE = 5000000000000000;  
    uint256 constant private MAX_ROUNDING_PERCENTAGE = 1000;  
    
    uint256 constant private MAX_HOOK_GAS = 40000;  

    VaultInterface public vault;

    uint public takerFee = 0;
    address public feeAccount;

    mapping (address => mapping (bytes32 => bool)) private orders;
    mapping (bytes32 => uint) private fills;
    mapping (bytes32 => bool) private cancelled;
    mapping (address => bool) private subscribed;

    function Exchange(uint _takerFee, address _feeAccount, VaultInterface _vault) public {
        require(address(_vault) != 0x0);
        setFees(_takerFee);
        setFeeAccount(_feeAccount);
        vault = _vault;
    }

     
     
     
    function withdraw(address token, uint amount) external onlyOwner {
        if (token == ETH) {
            msg.sender.transfer(amount);
            return;
        }

        ERC20(token).transfer(msg.sender, amount);
    }

     
    function subscribe() external {
        require(!subscribed[msg.sender]);
        subscribed[msg.sender] = true;
        emit Subscribed(msg.sender);
    }

     
    function unsubscribe() external {
        require(subscribed[msg.sender]);
        subscribed[msg.sender] = false;
        emit Unsubscribed(msg.sender);
    }

     
     
     
     
     
    function trade(address[3] addresses, uint[4] values, bytes signature, uint maxFillAmount) external {
        trade(OrderLibrary.createOrder(addresses, values), msg.sender, signature, maxFillAmount);
    }

     
     
     
    function cancel(address[3] addresses, uint[4] values) external {
        OrderLibrary.Order memory order = OrderLibrary.createOrder(addresses, values);

        require(msg.sender == order.maker);
        require(order.makerTokenAmount > 0 && order.takerTokenAmount > 0);

        bytes32 hash = order.hash();
        require(fills[hash] < order.takerTokenAmount);
        require(!cancelled[hash]);

        cancelled[hash] = true;
        emit Cancelled(hash);
    }

     
     
     
    function order(address[2] addresses, uint[4] values) external {
        OrderLibrary.Order memory order = OrderLibrary.createOrder(
            [msg.sender, addresses[0], addresses[1]],
            values
        );

        require(vault.isApproved(order.maker, this));
        require(vault.balanceOf(order.makerToken, order.maker) >= order.makerTokenAmount);
        require(order.makerToken != order.takerToken);
        require(order.makerTokenAmount > 0);
        require(order.takerTokenAmount > 0);

        bytes32 hash = order.hash();

        require(!orders[msg.sender][hash]);
        orders[msg.sender][hash] = true;

        emit Ordered(
            order.maker,
            order.makerToken,
            order.takerToken,
            order.makerTokenAmount,
            order.takerTokenAmount,
            order.expires,
            order.nonce
        );
    }

     
     
     
     
     
    function canTrade(address[3] addresses, uint[4] values, bytes signature)
        external
        view
        returns (bool)
    {
        OrderLibrary.Order memory order = OrderLibrary.createOrder(addresses, values);

        bytes32 hash = order.hash();

        return canTrade(order, signature, hash);
    }

     
     
     
    function isSubscribed(address subscriber) external view returns (bool) {
        return subscribed[subscriber];
    }

     
     
     
     
    function availableAmount(address[3] addresses, uint[4] values) external view returns (uint) {
        OrderLibrary.Order memory order = OrderLibrary.createOrder(addresses, values);
        return availableAmount(order, order.hash());
    }

     
     
     
    function filled(bytes32 hash) external view returns (uint) {
        return fills[hash];
    }

     
     
    function setFees(uint _takerFee) public onlyOwner {
        require(_takerFee <= MAX_FEE);
        takerFee = _takerFee;
    }

     
     
    function setFeeAccount(address _feeAccount) public onlyOwner {
        require(_feeAccount != 0x0);
        feeAccount = _feeAccount;
    }

    function vault() public view returns (VaultInterface) {
        return vault;
    }

     
     
     
     
    function isOrdered(address user, bytes32 hash) public view returns (bool) {
        return orders[user][hash];
    }

     
     
     
     
     
    function trade(OrderLibrary.Order memory order, address taker, bytes signature, uint maxFillAmount) internal {
        require(taker != order.maker);
        bytes32 hash = order.hash();

        require(order.makerToken != order.takerToken);
        require(canTrade(order, signature, hash));

        uint fillAmount = SafeMath.min256(maxFillAmount, availableAmount(order, hash));

        require(roundingPercent(fillAmount, order.takerTokenAmount, order.makerTokenAmount) <= MAX_ROUNDING_PERCENTAGE);
        require(vault.balanceOf(order.takerToken, taker) >= fillAmount);

        uint makeAmount = order.makerTokenAmount.mul(fillAmount).div(order.takerTokenAmount);
        uint tradeTakerFee = makeAmount.mul(takerFee).div(1 ether);

        if (tradeTakerFee > 0) {
            vault.transfer(order.makerToken, order.maker, feeAccount, tradeTakerFee);
        }

        vault.transfer(order.takerToken, taker, order.maker, fillAmount);
        vault.transfer(order.makerToken, order.maker, taker, makeAmount.sub(tradeTakerFee));

        fills[hash] = fills[hash].add(fillAmount);
        assert(fills[hash] <= order.takerTokenAmount);

        if (subscribed[order.maker]) {
            order.maker.call.gas(MAX_HOOK_GAS)(HookSubscriber(order.maker).tradeExecuted.selector, order.takerToken, fillAmount);
        }

        emit Traded(
            hash,
            order.makerToken,
            makeAmount,
            order.takerToken,
            fillAmount,
            order.maker,
            taker
        );
    }

     
     
     
     
     
    function canTrade(OrderLibrary.Order memory order, bytes signature, bytes32 hash)
        internal
        view
        returns (bool)
    {
         
        if (fills[hash] == 0) {
             
            if (!isOrdered(order.maker, hash) && !SignatureValidator.isValidSignature(hash, order.maker, signature)) {
                return false;
            }
        }

        if (cancelled[hash]) {
            return false;
        }

        if (!vault.isApproved(order.maker, this)) {
            return false;
        }

        if (order.takerTokenAmount == 0) {
            return false;
        }

        if (order.makerTokenAmount == 0) {
            return false;
        }

         
        if (availableAmount(order, hash) == 0) {
            return false;
        }

        return order.expires > now;
    }

     
     
     
     
    function availableAmount(OrderLibrary.Order memory order, bytes32 hash) internal view returns (uint) {
        return SafeMath.min256(
            order.takerTokenAmount.sub(fills[hash]),
            vault.balanceOf(order.makerToken, order.maker).mul(order.takerTokenAmount).div(order.makerTokenAmount)
        );
    }

     
     
     
     
     
    function roundingPercent(uint numerator, uint denominator, uint target) internal pure returns (uint) {
         
        uint remainder = mulmod(target, numerator, denominator);
        if (remainder == 0) {
            return 0;
        }

        return remainder.mul(1000000).div(numerator.mul(target));
    }
}