// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {PriceConverter} from "./PriceConverter.sol";
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5e18;
    address public immutable i_owner;
    address[] funders;
    mapping(address funder => uint amountFunded) public addressToAmountFunded;

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        // require(msg.sender == i_owner, "Only owner can call this function");
        _;
    }

    constructor() {
        i_owner = msg.sender; //msg.sender is the address that deploys the contract
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Too less");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0; //withdrawing for each user
        }
        funders = new address[](0); //resetting the funders array

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
    }
}
