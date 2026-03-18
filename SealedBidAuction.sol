// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SealedBidAuction is ReentrancyGuard {
    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
    }

    address payable public beneficiary;
    uint256 public biddingEnd;
    uint256 public revealEnd;
    
    address public highestBidder;
    uint256 public highestBid;

    mapping(address => Bid) public bids;
    mapping(address => uint256) public pendingReturns;

    constructor(uint256 _biddingTime, uint256 _revealTime, address payable _beneficiary) {
        beneficiary = _beneficiary;
        biddingEnd = block.timestamp + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }

    function commitBid(bytes32 _blindedBid) external payable {
        require(block.timestamp < biddingEnd, "Bidding already ended");
        require(bids[msg.sender].blindedBid == 0, "Bid already committed");
        bids[msg.sender] = Bid({blindedBid: _blindedBid, deposit: msg.value});
    }

    function reveal(uint256 _value, string memory _salt) external {
        require(block.timestamp > biddingEnd, "Bidding not ended");
        require(block.timestamp < revealEnd, "Reveal period ended");

        Bid storage bidToCheck = bids[msg.sender];
        bytes32 hash = keccak256(abi.encodePacked(_value, _salt));
        
        require(bidToCheck.blindedBid == hash, "Invalid reveal");
        require(bidToCheck.deposit >= _value, "Deposit less than bid value");

        uint256 refund = bidToCheck.deposit;
        if (_value > highestBid) {
            if (highestBidder != address(0)) {
                pendingReturns[highestBidder] += highestBid;
            }
            highestBid = _value;
            highestBidder = msg.sender;
            refund -= _value;
        }
        
        bidToCheck.blindedBid = 0; // Prevent double reveal
        payable(msg.sender).transfer(refund);
    }

    function withdraw() external {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

    function auctionEnd() external {
        require(block.timestamp > revealEnd, "Reveal period not over");
        beneficiary.transfer(highestBid);
    }
}
