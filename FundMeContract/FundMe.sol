// SPDX-License-Identifier: MIT

// Smart contract that lets anyone deposit ETH into the contract
// Only the owner of the contract can withdraw the ETH
pragma solidity >=0.6.6 <0.9.0;

// Get the latest ETH/USD price from chainlink price feed
// https://github.com/smartcontractkit/chainlink/blob/d8982d45739a2157c3c5d73d2462b8b449165308/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
// interface AggregatorV3Interface {
//   function decimals() external view returns (uint8);

//   function description() external view returns (string memory);

//   function version() external view returns (uint256);

//   // getRoundData and latestRoundData should both raise "No data present"
//   // if they do not have data to report, instead of returning unset values
//   // which could be misinterpreted as actual reported values.
//   function getRoundData(uint80 _roundId)
//     external
//     view
//     returns (
//       uint80 roundId,
//       int256 answer,
//       uint256 startedAt,
//       uint256 updatedAt,
//       uint80 answeredInRound
//     );

//   function latestRoundData()
//     external
//     view
//     returns (
//       uint80 roundId,
//       int256 answer,
//       uint256 startedAt,
//       uint256 updatedAt,
//       uint80 answeredInRound
//     );
// }
// safe math for not accuring the opverflow
// https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/vendor/SafeMathChainlink.sol
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
	// safe math library check uint256 for integer overflows
    using SafeMathChainlink for uint256;
    
    //mapping to store which address depositeded how much ETH
    mapping(address => uint256) public addressToAmountFunded;
    // array of addresses who deposited
    address[] public funders;
    //address of the owner (who deployed the contract)
    address public owner;
    
    // the first person to deploy the contract is
    // the owner
    // running wwhen first deployment
    constructor() public {
        owner = msg.sender;
    }
    
    // Payable is a function that will use for requesting deduction in eth
    function fund() public payable {
    	// 18 digit number to be compared with donated amount 
        uint256 minimumUSD = 50 * 10 ** 18;
        //is the donated amount less than 50USD?
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");
        //if not, add to mapping and funders array
        // msg is for getting data of the transaction
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    //function to get the version of the chainlink pricefeed
    // https://docs.chain.link/docs/ethereum-addresses/ getting the data in here
    function getVersion() public view returns (uint256){
        // https://docs.chain.link/docs/get-the-latest-price/ documentation for getting latest price
        // https://docs.chain.link/docs/ethereum-addresses/
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
         // ETH/USD rate in 18 digit 
         return uint256(answer * 10000000000);
    }
    
    // 1000000000
    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        // the actual ETH/USD conversation rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }
    
    //modifier: https://medium.com/coinmonks/solidity-tutorial-all-about-modifiers-a86cf81c14cb
    modifier onlyOwner {
    	//is the message sender owner of the contract?
        require(msg.sender == owner);
        _;
    }
    
    // onlyOwner modifer will first check the condition inside it 
    // and 
    // if true, withdraw function will be executed 
    function withdraw() payable onlyOwner public {
    
    	// If you are using version eight (v0.8) of chainlink aggregator interface,
	// you will need to change the code below to
	// payable(msg.sender).transfer(address(this).balance);
        msg.sender.transfer(address(this).balance);

        
        //iterate through all the mappings and make them 0
        //since all the deposited amount has been withdrawn
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //funders array will be initialized to 0
        funders = new address[](0);
    }
}

// Note How To know the ETH conversion to eth
// Chain Link is an third party that use for knowing and eth data roce
// interfaces is for making the function is callable from another interface