require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hyperion: {
      url: process.env.HYPERION_RPC,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 513100
    }
  }
};