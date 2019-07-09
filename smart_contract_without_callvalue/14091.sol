pragma solidity ^0.4.18;

 
library SafeMath {
  function mul(uint a, uint b) pure internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) pure internal returns (uint) {
     
    uint c = a / b;
     
    return c;
  }

  function sub(uint a, uint b) pure internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) pure internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) pure internal returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) pure internal returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) pure internal returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) pure internal returns (uint256) {
    return a < b ? a : b;
  }
}

 
contract Ownable {
  address public owner;


   
  constructor() public {
    owner = msg.sender;
  }


   
  modifier onlyOwner() {
      require(msg.sender == owner);
    _;
  }


   
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

 
interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external;  
    function transferFrom(address _from, address _to, uint _value) external;  
    function approve(address _spender, uint _value) external;  
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

 
interface KULAPTradingProxy {
     
     
     
     
     
     
    event Trade( ERC20 src, uint srcAmount, ERC20 dest, uint destAmount);

     
     
     
     
     
     
    function trade(
        ERC20 src,
        ERC20 dest,
        uint srcAmount
    )
        external
        payable
        returns(uint);
    
     
     
     
     
     
     
    function rate(
        ERC20 src, 
        ERC20 dest, 
        uint srcAmount
    ) 
        external 
        view 
        returns(uint, uint);
}

contract KulapDex is Ownable {
    event Trade(
         
        address indexed _srcAsset,
        uint256         _srcAmount,

         
        address indexed _destAsset,
        uint256         _destAmount,

         
        address indexed _trader, 

         
        uint256          fee
    );

    using SafeMath for uint256;
    ERC20 public etherERC20 = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

     

     
    KULAPTradingProxy[] public tradingProxies;

    function _tradeEtherToToken(
        uint256 tradingProxyIndex, 
        uint256 srcAmount, 
        ERC20 dest
        ) 
        private 
        returns(uint256)  {
         
        KULAPTradingProxy tradingProxy = tradingProxies[tradingProxyIndex];

         
        uint256 destAmount = tradingProxy.trade.value(srcAmount)(
            etherERC20,
            dest,
            srcAmount
        );

        return destAmount;
    }

     
    function () public payable {

    }

    function _tradeTokenToEther(
        uint256 tradingProxyIndex, 
        ERC20 src, 
        uint256 srcAmount
        ) 
        private 
        returns(uint256)  {
         
        KULAPTradingProxy tradingProxy = tradingProxies[tradingProxyIndex];

         
        src.approve(tradingProxy, srcAmount);

         
        uint256 destAmount = tradingProxy.trade(
            src, 
            etherERC20,
            srcAmount
        );
        
        return destAmount;
    }

     
     
     
     
     
    function _trade(
        uint256             _tradingProxyIndex, 
        ERC20               _src, 
        uint256             _srcAmount, 
        ERC20               _dest, 
        uint256             _minDestAmount
    ) private returns(uint256)  {
         
        uint256 destAmount;

         
        uint256 srcAmountBefore;
        uint256 destAmountBefore;
         
        if (etherERC20 == _src) {
            srcAmountBefore = address(this).balance;
        } else {
            srcAmountBefore = _src.balanceOf(this);
        }
         
        if (etherERC20 == _dest) {
            destAmountBefore = address(this).balance;
        } else {
            destAmountBefore = _dest.balanceOf(this);
        }

         
        if (etherERC20 == _src) {
            destAmount = _tradeEtherToToken(_tradingProxyIndex, _srcAmount, _dest);
        
         
        } else if (etherERC20 == _dest) {
            destAmount = _tradeTokenToEther(_tradingProxyIndex, _src, _srcAmount);

         
         
        } else {
            revert();
        }

         
         
        if (etherERC20 == _src) {
            assert(address(this).balance == srcAmountBefore.sub(_srcAmount));
        } else {
            assert(_src.balanceOf(this) == srcAmountBefore.sub(_srcAmount));
        }
         
        if (etherERC20 == _dest) {
            assert(address(this).balance == destAmountBefore.add(destAmount));
        } else {
            assert(_dest.balanceOf(this) == destAmountBefore.add(destAmount));
        }

         
        assert(destAmount >= _minDestAmount);

        return destAmount;
    }

     
     
     
     
     
    function trade(uint256 tradingProxyIndex, ERC20 src, uint256 srcAmount, ERC20 dest, uint256 minDestAmount) payable public returns(uint256)  {
        uint256 destAmount;

         
        if (etherERC20 == src) {
            destAmount = _trade(tradingProxyIndex, src, srcAmount, dest, 1);

             
            assert(destAmount >= minDestAmount);

             
             
             
            dest.transfer(msg.sender, destAmount);
        
         
        } else if (etherERC20 == dest) {
             
            src.transferFrom(msg.sender, address(this), srcAmount);

            destAmount = _trade(tradingProxyIndex, src, srcAmount, dest, 1);

             
            assert(destAmount >= minDestAmount);

             
             
            msg.sender.transfer(destAmount);

         
         
        } else {
            revert();
        }

        emit Trade( src, srcAmount, dest, destAmount, msg.sender, 0);
        

        return destAmount;
    }

     
     
     
     
     
     
     
     
     
    function tradeRoutes(ERC20 src, uint256 srcAmount, ERC20 dest, uint256 minDestAmount, address[] _tradingPaths) payable public returns(uint256)  {
        uint256 destAmount;

        if (etherERC20 != src) {
             
            src.transferFrom(msg.sender, address(this), srcAmount);
        }

        uint256 pathSrcAmount = srcAmount;
        for (uint i=0; i < _tradingPaths.length; i+=3) {
            uint256 tradingProxyIndex =         uint256(_tradingPaths[i]);
            ERC20 pathSrc =                     ERC20(_tradingPaths[i+1]);
            ERC20 pathDest =                    ERC20(_tradingPaths[i+2]);

            destAmount = _trade(tradingProxyIndex, pathSrc, pathSrcAmount, pathDest, 1);
            pathSrcAmount = destAmount;
        }

         
        assert(destAmount >= minDestAmount);

         
        if (etherERC20 == dest) {
             
             
            msg.sender.transfer(destAmount);
        
         
        } else {
             
             
             
            dest.transfer(msg.sender, destAmount);
        }

        emit Trade( src, srcAmount, dest, destAmount, msg.sender, 0);

        return destAmount;
    }

     
     
     
     
     
     
     
    function rate(uint256 tradingProxyIndex, ERC20 src, ERC20 dest, uint srcAmount) public view returns(uint, uint) {
         
        KULAPTradingProxy tradingProxy = tradingProxies[tradingProxyIndex];

        return tradingProxy.rate(src, dest, srcAmount);
    }

     
    function addTradingProxy(
        KULAPTradingProxy _proxyAddress
    ) public onlyOwner returns (uint256) {

        tradingProxies.push( _proxyAddress );

        return tradingProxies.length;
    }
}