// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/GovernanceToken.sol";
import "../src/AMM.sol";
import "../src/Vault.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        GovernanceToken tokenA = new GovernanceToken();
        GovernanceToken tokenB = new GovernanceToken();
        console.log("TokenA:", address(tokenA));
        console.log("TokenB:", address(tokenB));

        AMM amm = new AMM(address(tokenA), address(tokenB));
        console.log("AMM:", address(amm));

        Vault vault = new Vault(address(tokenA));
        console.log("Vault:", address(vault));

        vm.stopBroadcast();
    }
}