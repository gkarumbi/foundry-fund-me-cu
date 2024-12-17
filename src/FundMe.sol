//Get funds from users
//withdraw funds
//set a mininum funding value in USD


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();
//Error should be outside contract declarion


/*interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}*/

contract FundMe{
    using PriceConverter for uint256;

    //uint256 public minimumUsd = 5e18;  // OR 5 *10e18 OR 5 * 10**
    
    //Array to track our funders
    address[] private s_funders;
    
    //Add a mapping to track the amount funded back to a funding address

    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;

    //address public owner;
    address private immutable i_owner;
    uint256 private constant MINIMUM_USD = 5 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;
    constructor(address priceFeed){

      i_owner = msg.sender;
      s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        //payable makes button red on remix and makes contract able to receive eth
        //Allows users to send $
        //Have a mininum  $ sent
        //Step 1. How do we send ETH to this contract
  

        //require(getConversionRate(msg.value) >= minimumUsd, "Tuma na ya kutoa");
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        //Each time money is sent to our contract the sender is added to our funders array
        s_funders.push(msg.sender);

        //addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    modifier onlyOwner(){
      require(msg.sender == i_owner);
      _;
    }

    function cheaperWithdrawal() public onlyOwner{
      uint256 fundersLength = s_funders.length; // now everytime we loop
      //we shall be reading from memory instead of storage
      for(uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++){

        address funder = s_funders[funderIndex];
        s_addressToAmountFunded[funder] = 0;

      }

      s_funders = new address[](0);

    }

    function withdraw() public onlyOwner{
      //Require the withdrawal function to only be called by the owner
      //require(msg.sender == owner, "Must be owner");
      for (uint256 funderIndex =0; funderIndex< s_funders.length; funderIndex++) 
      {
        address funder = s_funders[funderIndex];
        s_addressToAmountFunded[funder] = 0;
      }

      s_funders = new address[](0);
      //transfer
      //payable(msg.sender).transfer(address(this).balance);

      //send
      //bool sendSuccess = payable(msg.sender).send(address(this).balance);

      //call
      (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
      require(callSuccess, "Call failed");
    }
     // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

     fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
    /**
     * 
     * View/Pure functions (Gettters)  
     */

    function getAddressToAmountFunded(
      address fundingAddress
    ) external view returns(uint256){
      return s_addressToAmountFunded[fundingAddress];

    }

    function getFunder(uint256 index) external view returns(address){
      return s_funders[index];
    }

    /*function getPrice() public view  returns(uint256) {
      AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
      (,int256 price,,,) = priceFeed.latestRoundData();

      return uint256(price * 1e10);

    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
      uint256 ethPrice = getPrice();
      uint256 ethAmountInUSD = (ethAmount * ethPrice) / 1e18;
      return ethAmountInUSD;

    }*/

    function getVersion() public view returns (uint256){
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return s_priceFeed.version();
    } 

    function getOwner() external view returns(address){
      return i_owner;

    }
}