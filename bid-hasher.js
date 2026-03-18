const { ethers } = require("ethers");

/**
 * Creates a blinded bid hash.
 * @param {number} value - The bid amount in wei.
 * @param {string} salt - A random secret string.
 */
function generateBlindedBid(value, salt) {
  return ethers.solidityPackedKeccak256(["uint256", "string"], [value, salt]);
}

module.exports = { generateBlindedBid };
