//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";


contract fundMe{
    mapping (address => uint256) public addressToAMountFunded;
    address public owner;
    address [] public funders ;
    
    constructor() public{
        owner = msg.sender;
    }
    
    function fund() public payable{
        uint256 minimumUSD = 50;
        require(getConversionRate(msg.value) >= minimumUSD, "You must add at least $50");
        addressToAMountFunded[msg.sender]+= msg.value;
        funders.push(msg.sender);
    }
    
    function getVersion() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
        =priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }
    
    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice *ethAmount);
        return ethAmountInUSD;
    }
    modifier onlyOwner (){
        require(msg.sender == owner);
        _;
    }
    
    function withdraw() payable onlyOwner public{
        msg.sender.transfer(address(this).balance);
        for (uint256 fundersIndex = 0; fundersIndex <= funders.length; fundersIndex++){
            addressToAMountFunded[funders[fundersIndex]]=0;
        }
        funders = new address[](0);
    }
    
}
