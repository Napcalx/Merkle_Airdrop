// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BCUToken} from "../src/BCUToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot =
        0xf0555dbb72c13b8f69fb49b4e2f2ba1b671b7f7c62448345438d0e33eb8c6d1b;
    uint256 public constant s_transferAmount = 8 * 25e18;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BCUToken) {
        vm.startBroadcast();
        BCUToken token = new BCUToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(
            s_merkleRoot,
            IERC20(address(token))
        );
        token.mint(token.owner(), s_transferAmount);
        token.transfer(address(airdrop), s_transferAmount); // transfer the tokens to the airdrop contract
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() external returns (MerkleAirdrop, BCUToken) {
        return deployMerkleAirdrop();
    }
}
