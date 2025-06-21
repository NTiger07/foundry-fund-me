// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5e18;
    address private immutable i_owner;
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;
    AggregatorV3Interface private immutable s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender; //msg.sender is the address that deploys the contract
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    event Funded(address indexed funder, uint256 amount);
    event Withdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Too less"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
        emit Funded(msg.sender, msg.value);
    }

    function withdraw() external onlyOwner {
        uint256 fundersCount = s_funders.length;
        uint256 totalBalance = address(this).balance;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersCount;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0; //withdrawing for each user
        }
        s_funders = new address[](0); //resetting the funders array

        // //transfer
        // payable(msg.sender).transfer(address(this).balance); //automatic revert if fails

        // //send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed"); //only reverts if require fails

        //call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed"); //only reverts if require fails
        emit Withdrawn(msg.sender, totalBalance);
    }

    function getVersion() external view returns (uint256) {
        return s_priceFeed.version();
    }

    /** VIEW / PURE FUNCTIONS (GETTERS) **/

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
