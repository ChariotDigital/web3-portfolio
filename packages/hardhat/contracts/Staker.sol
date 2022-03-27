// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  uint256 public constant threshold = 1 ether;
  mapping (address => uint256) balances;
  uint256 public deadline = block.timestamp + 30 seconds;

  modifier deadlineReached( bool requireReached ) {
    uint256 timeRemaining = timeLeft();
    if( requireReached ) {
      require(timeRemaining == 0, "Deadline is not reached yet");
    } else {
      // require(timeRemaining > 0, "Deadline is already reached");
    }
    _;
  }



   modifier stakeNotCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "staking process already completed");
    _;
  }


  event Stake(address,uint);

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  function stake() public payable deadlineReached(false) stakeNotCompleted   returns (bool) {
    uint256 start = block.timestamp;
    deadline = block.timestamp + 1 minutes;


    balances[msg.sender] = msg.value;

    emit Stake(msg.sender, msg.value);

    return true;
    
  } 

  function recieve() public payable {
    balances[msg.sender] += msg.value;
  }

  function execute() public stakeNotCompleted deadlineReached(true)  {
    if (address(this).balance >= threshold) {
      address(exampleExternalContract).call{value: address(this).balance}(abi.encodeWithSignature("complete()"));
    }
  } 

  function contractAmt() public returns (uint256) {
    return address(this).balance;
  }

  function timeLeft() public view returns (uint256 timeleft) {
    if( block.timestamp >= deadline ) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }

    
  }

  // Function to allow the sender to withdraw all Ether from this contract.
  function withdraw() public deadlineReached(true) stakeNotCompleted {
      // get the amount of Ether stored in this contract
      require((contractAmt() >= threshold), 'Threshold has been reached, funds cannot be withdrawn');
      uint256 amount = balances[msg.sender];
      require(amount > 0, "No ETH in from user");
      balances[msg.sender] = 0;

      // send all Ether to owner
      // Owner can receive Ether since the address of owner is payable
      (bool success, ) = msg.sender.call{value: amount}("");
      require(success, "Failed to send Ether");
  }



  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()


}
