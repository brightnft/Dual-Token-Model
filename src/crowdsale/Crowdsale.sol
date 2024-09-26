// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface Aggregator {
  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
  function decimals() external view returns (uint8);
}
contract Crowdsale is Initializable, OwnableUpgradeable, PausableUpgradeable {
  uint256 public tokenPrice;
  uint256 public totalTokensSold;
  uint256 public maxTokensToSell;
  uint256 public startTime;
  uint256 public endTime;
  uint256 public baseDecimals;
  uint256 public maxTokensToBuy;
  uint256 public usdRaised;
  address public paymentWallet;

  Aggregator public aggregatorInterface;

  mapping(address => uint256) public userDeposits;

  event SaleTimeSet(uint256 _start, uint256 _end, uint256 timestamp);
  event SaleTimeUpdated(bytes32 indexed key, uint256 prevValue, uint256 newValue, uint256 timestamp);
  event TokensBought(
    address indexed user,
    uint256 indexed tokensBought,
    address indexed purchaseToken,
    uint256 amountPaid,
    uint256 usdEq,
    uint256 timestamp
  );
  event MaxTokensUpdated(uint256 prevValue, uint256 newValue, uint256 timestamp);

  /**
   * @dev Initializes the contract and sets key parameters
   * @param _oracle Oracle contract to fetch metis/USDT price
   * @param _tokenPrice presale price of the token
   * @param _startTime start time of the presale
   * @param _endTime end time of the presale
   * @param _maxTokensToSell amount of max tokens to sell
   * @param _maxTokensToBuy amount of max tokens to buy
   * @param _paymentWallet address to recive payments
   */
  function initialize(
    address _oracle,
    uint256 _tokenPrice,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _maxTokensToSell,
    uint256 _maxTokensToBuy,
    address _paymentWallet
  ) external initializer {
    require(_oracle != address(0), "Zero aggregator address");
    require(_startTime > block.timestamp && _endTime > _startTime, "Invalid time");
    __Pausable_init_unchained();
    __Ownable_init_unchained(_msgSender());
    baseDecimals = (10 ** 18);
    aggregatorInterface = Aggregator(_oracle);
    tokenPrice = _tokenPrice;
    startTime = _startTime;
    endTime = _endTime;
    maxTokensToSell = _maxTokensToSell;
    maxTokensToBuy = _maxTokensToBuy;
    paymentWallet = _paymentWallet;
    emit SaleTimeSet(startTime, endTime, block.timestamp);
  }

  /**
   * @dev To pause the presale
   */
  function pause() external onlyOwner {
    _pause();
  }

  /**
   * @dev To unpause the presale
   */
  function unpause() external onlyOwner {
    _unpause();
  }

  /**
   * @dev To get latest metis price in 10**18 format
   */
  function getLatestPrice() public view returns (uint256) {
    (, int256 price, , , ) = aggregatorInterface.latestRoundData();
    uint8 priceDecimal = aggregatorInterface.decimals();
    return uint256(price) * (10 ** (18 - priceDecimal));
  }

  modifier checkSaleState(uint256 amount) {
    require(block.timestamp >= startTime && block.timestamp <= endTime, "Invalid time for buying");
    require(amount > 0, "Invalid sale amount");
    require(amount <= maxTokensToBuy, "Amount exceeds max tokens to buy");
    require(totalTokensSold + amount <= maxTokensToSell, "Amount exceeds tokens remaining for sale");
    _;
  }

  /**
   * @dev To buy into a presale using Metis
   * @param amount No of tokens to buy
   */
  function buyWithMetis(uint256 amount) external payable checkSaleState(amount) whenNotPaused returns (bool) {
    uint256 usdPrice = amount * tokenPrice;
    uint256 metisAmount = (usdPrice * baseDecimals) / getLatestPrice();
    require(msg.value >= metisAmount, "Less payment");
    totalTokensSold += amount;
    userDeposits[_msgSender()] += (amount * baseDecimals);
    usdRaised += usdPrice;
    sendValue(payable(paymentWallet), metisAmount);
    uint256 excess = msg.value - metisAmount;
    if (excess > 0) sendValue(payable(_msgSender()), excess);
    emit TokensBought(_msgSender(), amount, address(0), metisAmount, usdPrice, block.timestamp);
    return true;
  }

  /**
   * @dev Helper funtion to get METIS price for given amount
   * @param amount No of tokens to buy
   */
  function metisBuyHelper(uint256 amount) external view returns (uint256 metisAmount) {
    uint256 usdPrice = amount * tokenPrice;
    metisAmount = (usdPrice * baseDecimals) / getLatestPrice();
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Low balance");
    (bool success, ) = recipient.call{ value: amount }("");
    require(success, "metis Payment failed");
  }

  /**
   * @dev To update the sale times
   * @param _startTime New start time
   * @param _endTime New end time
   */
  function setSaleTimes(uint256 _startTime, uint256 _endTime) external onlyOwner {
    require(_startTime > 0 || _endTime > 0, "Invalid parameters");
    if (_startTime > 0) {
      require(block.timestamp < _startTime, "Sale time in past");
      require(_startTime < endTime, "Invalid startTime");
      uint256 prevValue = startTime;
      startTime = _startTime;
      emit SaleTimeUpdated(bytes32("START"), prevValue, _startTime, block.timestamp);
    }
    if (_endTime > 0) {
      require(_endTime > startTime, "Invalid endTime");
      uint256 prevValue = endTime;
      endTime = _endTime;
      emit SaleTimeUpdated(bytes32("END"), prevValue, _endTime, block.timestamp);
    }
  }

  function setMaxTokensToSell(uint256 _maxTokensToSell) external onlyOwner {
    require(_maxTokensToSell > 0, "Zero max tokens to sell value");
    maxTokensToSell = _maxTokensToSell;
  }

  function setMaxTokensToBuy(uint256 _maxTokensToBuy) external onlyOwner {
    require(_maxTokensToBuy > 0, "Zero max tokens to buy value");
    uint256 prevValue = maxTokensToBuy;
    maxTokensToBuy = _maxTokensToBuy;
    emit MaxTokensUpdated(prevValue, _maxTokensToBuy, block.timestamp);
  }

  /**
   * @dev To set payment wallet address
   * @param _newPaymentWallet new payment wallet address
   */
  function changePaymentWallet(address _newPaymentWallet) external onlyOwner {
    require(_newPaymentWallet != address(0), "address cannot be zero");
    paymentWallet = _newPaymentWallet;
  }

  /**
   * @dev to set the token price
   * @param _tokenPrice uint256
   */
  function setTokenPrice(uint256 _tokenPrice) external onlyOwner {
    tokenPrice = _tokenPrice;
  }
}
