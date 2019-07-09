pragma solidity ^0.4.21;

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
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

   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

 
contract PullPayment {
  using SafeMath for uint256;

  mapping(address => uint256) public payments;
  uint256 public totalPayments;

   
  function withdrawPayments() public {
    address payee = msg.sender;
    uint256 payment = payments[payee];

    require(payment != 0);
    require(address(this).balance >= payment);

    totalPayments = totalPayments.sub(payment);
    payments[payee] = 0;

    payee.transfer(payment);
  }

   
  function asyncSend(address dest, uint256 amount) internal {
    payments[dest] = payments[dest].add(amount);
    totalPayments = totalPayments.add(amount);
  }

   
  function asyncDebit(address dest, uint256 amount) internal {
    payments[dest] = payments[dest].sub(amount);
    totalPayments = totalPayments.sub(amount);
  }
}

 
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
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
}

 
library SaleListLib {
  address public constant nullAddress = address(0);

  struct SaleList {
    address head;

    mapping(address => address) sellerListMapping;
    mapping(address => uint) sellerToPrice;
  }

  function getBest(SaleList storage self) public view returns (address, uint) {
    address head = self.head;
    return (head, self.sellerToPrice[head]);
  }

  function addSale(SaleList storage self, address seller, uint price) public {
    require(price != 0);
    require(seller != nullAddress);

    if (_contains(self, seller)) {
      removeSale(self, seller);
    }

    self.sellerToPrice[seller] = price;
    if (self.head == nullAddress || price <= self.sellerToPrice[self.head]) {
      self.sellerListMapping[seller] = self.head;
      self.head = seller;
    } else {
      address prev = self.head;
      address cur = self.sellerListMapping[prev];

      while (cur != nullAddress) {
        if (price <= self.sellerToPrice[cur]) {
          self.sellerListMapping[prev] = seller;
          self.sellerListMapping[seller] = cur;

          break;
        }

        prev = cur;
        cur = self.sellerListMapping[cur];
      }

       
      if (cur == nullAddress) {
        self.sellerListMapping[prev] = seller;
      }
    }
  }

  function removeSale(SaleList storage self, address seller) public returns (bool) {
    require(seller != nullAddress);

    if (!_contains(self, seller)) {
      return false;
    }

    if (seller == self.head) {
      self.head = self.sellerListMapping[seller];
      _remove(self, seller);
    } else {
      address prev = self.head;
      address cur = self.sellerListMapping[prev];

       
       
      while (cur != nullAddress && prev != seller) {
        if (cur == seller) {
          self.sellerListMapping[prev] = self.sellerListMapping[seller];
          _remove(self, seller);

          break;
        }

        prev = cur;
        cur = self.sellerListMapping[cur];
      }

       
      if (cur == nullAddress) {
        return false;
      }
    }

    return true;
  }

   
  function _remove(SaleList storage self, address seller) internal {
    self.sellerToPrice[seller] = 0;
    self.sellerListMapping[seller] = nullAddress;
  }

  function _contains(SaleList storage self, address seller) view internal returns (bool) {
    return self.sellerToPrice[seller] != 0;
  }
}

contract SaleRegistry is Ownable {
  using SafeMath for uint256;

   
   
   

  event SalePosted(
    address indexed _seller,
    bytes32 indexed _sig,
    uint256 _price
  );

  event SaleCancelled(
    address indexed _seller,
    bytes32 indexed _sig
  );

   
   
   

  mapping(bytes32 => SaleListLib.SaleList) _sigToSortedSales;

  mapping(address => mapping(bytes32 => uint256)) _addressToSigToSalePrice;

   
   
  mapping(bytes32 => uint256) _ownerSigToNumSales;

  mapping(bytes32 => uint256) public sigToNumSales;

   
   
   

   
  function getBestSale(bytes32 sig) public view returns (address, uint256) {
    return SaleListLib.getBest(_sigToSortedSales[sig]);
  }

   
  function getMySalePrice(bytes32 sig) public view returns (uint256) {
    return _addressToSigToSalePrice[msg.sender][sig];
  }

   
   
   

   
  function postGenesisSales(bytes32 sig, uint256 price, uint256 numSales) internal onlyOwner {
    SaleListLib.addSale(_sigToSortedSales[sig], owner, price);
    _addressToSigToSalePrice[owner][sig] = price;

    _ownerSigToNumSales[sig] = _ownerSigToNumSales[sig].add(numSales);
    sigToNumSales[sig] = sigToNumSales[sig].add(numSales);

    emit SalePosted(owner, sig, price);
  }

   
  function relistGenesisSales(bytes32 sig, uint256 newPrice) external onlyOwner {
    SaleListLib.addSale(_sigToSortedSales[sig], owner, newPrice);
    _addressToSigToSalePrice[owner][sig] = newPrice;

    emit SalePosted(owner, sig, newPrice);
  }

   
  function postSale(address seller, bytes32 sig, uint256 price) internal {
    SaleListLib.addSale(_sigToSortedSales[sig], seller, price);
    _addressToSigToSalePrice[seller][sig] = price;

    sigToNumSales[sig] = sigToNumSales[sig].add(1);

    if (seller == owner) {
      _ownerSigToNumSales[sig] = _ownerSigToNumSales[sig].add(1);
    }

    emit SalePosted(seller, sig, price);
  }

   
  function cancelSale(address seller, bytes32 sig) internal {
    if (seller == owner) {
      _ownerSigToNumSales[sig] = _ownerSigToNumSales[sig].sub(1);

      if (_ownerSigToNumSales[sig] == 0) {
        SaleListLib.removeSale(_sigToSortedSales[sig], seller);
        _addressToSigToSalePrice[seller][sig] = 0;
      }
    } else {
      SaleListLib.removeSale(_sigToSortedSales[sig], seller);
      _addressToSigToSalePrice[seller][sig] = 0;
    }
    sigToNumSales[sig] = sigToNumSales[sig].sub(1);

    emit SaleCancelled(seller, sig);
  }
}

contract OwnerRegistry {
  using SafeMath for uint256;

   
   
   

  event CardCreated(
    bytes32 indexed _sig,
    uint256 _numAdded
  );

  event CardsTransferred(
    bytes32 indexed _sig,
    address indexed _oldOwner,
    address indexed _newOwner,
    uint256 _count
  );

   
   
   

  bytes32[] _allSigs;
  mapping(address => mapping(bytes32 => uint256)) _ownerToSigToCount;
  mapping(bytes32 => uint256) _sigToCount;

   
   
   

  function addCardToRegistry(address owner, bytes32 sig, uint256 numToAdd) internal {
     
    require(_sigToCount[sig] == 0);

    _allSigs.push(sig);
    _ownerToSigToCount[owner][sig] = numToAdd;
    _sigToCount[sig] = numToAdd;

    emit CardCreated(sig, numToAdd);
  }

   
   
   

  function getAllSigs() public view returns (bytes32[]) {
    return _allSigs;
  }

  function getNumSigsOwned(bytes32 sig) public view returns (uint256) {
    return _ownerToSigToCount[msg.sender][sig];
  }

  function getNumSigs(bytes32 sig) public view returns (uint256) {
    return _sigToCount[sig];
  }

   
   
   

  function registryTransfer(address oldOwner, address newOwner, bytes32 sig, uint256 count) internal {
     
    require(count > 0);

     
    require(_ownerToSigToCount[oldOwner][sig] >= count);

    _ownerToSigToCount[oldOwner][sig] = _ownerToSigToCount[oldOwner][sig].sub(count);
    _ownerToSigToCount[newOwner][sig] = _ownerToSigToCount[newOwner][sig].add(count);

    emit CardsTransferred(sig, oldOwner, newOwner, count);
  }
}

contract ArtistRegistry {
  using SafeMath for uint256;

  mapping(bytes32 => address) _sigToArtist;

   
  mapping(bytes32 => uint256[2]) _sigToFeeTuple;

  function addArtistToRegistry(bytes32 sig,
                               address artist,
                               uint256 txFeePercent,
                               uint256 genesisSalePercent) internal {
     
    require(artist != address(0));

     
    require(_sigToArtist[sig] == address(0));

    _sigToArtist[sig] = artist;
    _sigToFeeTuple[sig] = [txFeePercent, genesisSalePercent];
  }

  function computeArtistTxFee(bytes32 sig, uint256 txFee) internal view returns (uint256) {
    uint256 feePercent = _sigToFeeTuple[sig][0];
    return (txFee.mul(feePercent)).div(100);
  }

  function computeArtistGenesisSaleFee(bytes32 sig, uint256 genesisSaleProfit) internal view returns (uint256) {
    uint256 feePercent = _sigToFeeTuple[sig][1];
    return (genesisSaleProfit.mul(feePercent)).div(100);
  }

  function getArtist(bytes32 sig) internal view returns (address) {
    return _sigToArtist[sig];
  }
}

contract PepeCore is PullPayment, OwnerRegistry, SaleRegistry, ArtistRegistry {
  using SafeMath for uint256;

  uint256 constant public totalTxFeePercent = 4;

   
   
   

   
   
  address public shareholder1;
  address public shareholder2;
  address public shareholder3;

   
  uint256 public numShareholders = 0;

   
  function addShareholderAddress(address newShareholder) external onlyOwner {
     
    require(newShareholder != address(0));

     
    require(newShareholder != owner);

     
    require(shareholder1 == address(0) || shareholder2 == address(0) || shareholder3 == address(0));

    if (shareholder1 == address(0)) {
      shareholder1 = newShareholder;
      numShareholders = numShareholders.add(1);
    } else if (shareholder2 == address(0)) {
      shareholder2 = newShareholder;
      numShareholders = numShareholders.add(1);
    } else if (shareholder3 == address(0)) {
      shareholder3 = newShareholder;
      numShareholders = numShareholders.add(1);
    }
  }

   
  function payShareholders(uint256 amount) internal {
     
    if (numShareholders > 0) {
      uint256 perShareholderFee = amount.div(numShareholders);

      if (shareholder1 != address(0)) {
        asyncSend(shareholder1, perShareholderFee);
      }

      if (shareholder2 != address(0)) {
        asyncSend(shareholder2, perShareholderFee);
      }

      if (shareholder3 != address(0)) {
        asyncSend(shareholder3, perShareholderFee);
      }
    }
  }

   
   
   

  function withdrawContractBalance() external onlyOwner {
    uint256 contractBalance = address(this).balance;
    uint256 withdrawableBalance = contractBalance.sub(totalPayments);

     
    require(withdrawableBalance > 0);

    msg.sender.transfer(withdrawableBalance);
  }

  function addCard(bytes32 sig,
                   address artist,
                   uint256 txFeePercent,
                   uint256 genesisSalePercent,
                   uint256 numToAdd,
                   uint256 startingPrice) external onlyOwner {
    addCardToRegistry(owner, sig, numToAdd);

    addArtistToRegistry(sig, artist, txFeePercent, genesisSalePercent);

    postGenesisSales(sig, startingPrice, numToAdd);
  }

   
   
   

  function createSale(bytes32 sig, uint256 price) external {
     
    require(price > 0);

     
    require(getNumSigsOwned(sig) > 0);

     
    require(msg.sender == owner || _addressToSigToSalePrice[msg.sender][sig] == 0);

    postSale(msg.sender, sig, price);
  }

  function removeSale(bytes32 sig) public {
     
    require(_addressToSigToSalePrice[msg.sender][sig] > 0);

    cancelSale(msg.sender, sig);
  }

  function computeTxFee(uint256 price) private pure returns (uint256) {
    return (price * totalTxFeePercent) / 100;
  }

   
  function paySellerFee(bytes32 sig, address seller, uint256 sellerProfit) private {
    if (seller == owner) {
      address artist = getArtist(sig);
      uint256 artistFee = computeArtistGenesisSaleFee(sig, sellerProfit);
      asyncSend(artist, artistFee);

      payShareholders(sellerProfit.sub(artistFee));
    } else {
      asyncSend(seller, sellerProfit);
    }
  }

   
  function payTxFees(bytes32 sig, uint256 txFee) private {
    uint256 artistFee = computeArtistTxFee(sig, txFee);
    address artist = getArtist(sig);
    asyncSend(artist, artistFee);

    payShareholders(txFee.sub(artistFee));
  }

   
  function buy(bytes32 sig) external payable {
    address seller;
    uint256 price;
    (seller, price) = getBestSale(sig);

     
    require(price > 0 && seller != address(0));

     
    uint256 availableEth = msg.value.add(payments[msg.sender]);
    require(availableEth >= price);

     
    if (msg.value < price) {
      asyncDebit(msg.sender, price.sub(msg.value));
    }

     
    uint256 txFee = computeTxFee(price);
    uint256 sellerProfit = price.sub(txFee);

     
    paySellerFee(sig, seller, sellerProfit);

     
    payTxFees(sig, txFee);

     
    cancelSale(seller, sig);

     
    registryTransfer(seller, msg.sender, sig, 1);
  }

   
  function transferSig(bytes32 sig, uint256 count, address newOwner) external {
    uint256 numOwned = getNumSigsOwned(sig);

     
    require(numOwned >= count);

     
    if (msg.sender == owner) {
      uint256 remaining = numOwned.sub(count);

      if (remaining < _ownerSigToNumSales[sig]) {
        uint256 numSalesToCancel = _ownerSigToNumSales[sig].sub(remaining);

        for (uint256 i = 0; i < numSalesToCancel; i++) {
          removeSale(sig);
        }
      }
    } else {
       
      if (numOwned == count && _addressToSigToSalePrice[msg.sender][sig] > 0) {
        removeSale(sig);
      }
    }

     
    registryTransfer(msg.sender, newOwner, sig, count);
  }
}