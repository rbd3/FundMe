// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {PriceConverter} from "./PriceConverter.sol";
error NotOwner();
error CallFailed();

contract FundMe {
    using PriceConverter for uint256;
    //uint256 public minimumUsd = 5;
    uint256 public constant MINIMUM_USD = 5e18; //gas optimization
    address[] public founders;
    mapping(address founder => uint256 amountFounded)
        public adressToAmountFounded;
    address private immutable i_owner; ////gas optimization

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        //require(msg.value > 1e18, "Didn't send ennough ether");
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Didn't send ennough ether"
        );
        //ETH/USD adress from https://docs.chain.link/data-feeds/price-feeds/addresses
        //0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        founders.push(msg.sender);
        //adressToAmountFounded[msg.sender] = adressToAmountFounded[msg.sender] + msg.value;
        adressToAmountFounded[msg.sender] += msg.value; //optimization
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Must be the owner");
        if (msg.sender != i_owner) {
            revert NotOwner();
        } //gaz optimization
        _; // execute require then code
    }

    function withdraw() public onlyOwner {
        // require(msg.sender == owner, "your not allowed to withdraw this account"); use modifier instead
        for (uint256 i = 0; i < founders.length; i++) {
            address founder = founders[i];
            adressToAmountFounded[founder] = 0; //reset adress
        }
        founders = new address[](0); //reset array or just  delete founders; // More gas-efficient than creating a new array
        //payable (msg.sender).transfer(address(this).balance);
        //bool success = payable (msg.sender).send(address(this).balance);
        //require(success, "Send failed");
        (bool callSucced, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        //require(callSucced, "call failed");
        if (!callSucced) {
            revert CallFailed();
        }
    }
    // https://chatgpt.com/share/678f4017-00c8-800a-a4ab-91942c081569

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
