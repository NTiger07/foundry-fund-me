// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 price = getPrice(priceFeed); // already scaled to 1e18
        uint256 ethAmountInUsd = (ethAmount * price) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion(
        AggregatorV3Interface priceFeed
    ) public view returns (uint256) {
        return priceFeed.version();
    }
}
