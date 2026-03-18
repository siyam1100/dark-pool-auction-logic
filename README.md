# Dark Pool Sealed-Bid Auction

This repository provides a secure framework for **Sealed-Bid Auctions** on-chain. In a standard auction, visible bids allow for "bid-sniping" and front-running. This contract mitigates those issues using a two-phase process.

## The Two-Phase Process
1.  **Commit Phase:** Bidders submit a `keccak256` hash of their bid (Value + Secret Salt) along with a deposit. The actual bid value remains hidden.
2.  **Reveal Phase:** After the bidding window closes, bidders provide their original Value and Salt. The contract verifies the hash and logs the valid bid.

## Key Features
* **MEV Resistant:** Bots cannot see the bid amounts to front-run them.
* **Integrity Checks:** Ensures the reveal matches the original commitment.
* **Automatic Refunds:** Unsuccessful bidders can reclaim their deposits after the winner is declared.

## Usage
1.  **Commit:** `commitBid(bytes32 hashedBid)`
2.  **Reveal:** `revealBid(uint256 value, string memory salt)`
3.  **End:** `auctionEnd()`
