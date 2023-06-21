// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployMyTokenUsingOz} from "../script/DeployMyTokenUsingOz.s.sol";
import {MyTokenUsingOZ} from "../src/MyTokenUsingOZ.sol";

contract MyTokenUsingOZTest is Test {
    MyTokenUsingOZ public myTokenUsingOZ;
    DeployMyTokenUsingOz public deployer;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    uint256 startingBalace = 100 ether;

    function setUp() public {
        deployer = new DeployMyTokenUsingOz();
        myTokenUsingOZ = deployer.run();

        vm.prank(msg.sender);
        myTokenUsingOZ.transfer(bob, startingBalace);
    }

    function testBobsBalance() public {
        assertEq(startingBalace, myTokenUsingOZ.balanceOf(bob));
    }

    function testInitialSupply() public {
        assertEq(myTokenUsingOZ.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    // function testUsersCantMint() public {
    //     vm.expectRevert();
    //     MintableToken(address(myTokenUsingOZ)).mint(address(this), 1);
    // }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        // Alice approves Bob to spend tokens on her behalf
        vm.prank(bob);
        myTokenUsingOZ.approve(alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(alice);
        myTokenUsingOZ.transferFrom(bob, alice, transferAmount);
        assertEq(myTokenUsingOZ.balanceOf(alice), transferAmount);
        assertEq(
            myTokenUsingOZ.balanceOf(bob),
            startingBalace - transferAmount
        );
    }
}
