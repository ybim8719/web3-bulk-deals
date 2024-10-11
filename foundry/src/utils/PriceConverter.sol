// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;


import { AggregatorV3Interface } from "chainlink-brownie-contracts/ ";
library PriceConverter {
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }

    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
         AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }
}
