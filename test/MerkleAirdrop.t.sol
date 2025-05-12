//SPDX-License_identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BCUToken} from "../src/BCUToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    MerkleAirdrop public airdrop;
    BCUToken public token;

    bytes32 public ROOT =
        0xf0555dbb72c13b8f69fb49b4e2f2ba1b671b7f7c62448345438d0e33eb8c6d1b;
    uint256 public constant AMOUNT = 25e18;
    uint256 public constant AMOUNT_AVAILABLE = AMOUNT * 8;
    bytes32 proof1 =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2 =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32 proof3 =
        0x702e28c6b8f3f5d4686c6d5e2229deaf83e0663bf7781feab9e13cf40e9c74f2;
    bytes32[] public PROOF = [proof1, proof2, proof3];
    address user;
    uint256 userPrivKey;

    function setUp() external {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BCUToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_AVAILABLE);
            token.transfer(address(airdrop), AMOUNT_AVAILABLE); // transfer the tokens to the airdrop contract
        }
        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function testUserCanClaim() external {
        uint256 startingBal = token.balanceOf(user);
        console.log("Starting balance: ", startingBal);

        vm.prank(user);
        airdrop.claim(user, AMOUNT, PROOF);

        uint256 endingBal = token.balanceOf(user);
        console.log("Ending balance: ", endingBal);
        assertEq(endingBal - startingBal, AMOUNT);
    }
}
// 91992087827031385529631343486145185708010358789693783908930804305590475009462 - private key
