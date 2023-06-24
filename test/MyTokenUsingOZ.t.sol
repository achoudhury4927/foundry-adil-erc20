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

    uint256 constant startingBalace = 100 ether;
    uint256 constant initialAllowance = 1000;

    function setUp() public {
        deployer = new DeployMyTokenUsingOz();
        myTokenUsingOZ = deployer.run();

        vm.prank(msg.sender);
        myTokenUsingOZ.transfer(bob, startingBalace);

        // Alice approves Bob to spend tokens on her behalf
        vm.prank(bob);
        myTokenUsingOZ.approve(alice, initialAllowance);
    }

    function test_BobsBalance() public {
        assertEq(
            startingBalace,
            myTokenUsingOZ.balanceOf(bob),
            "Bobs starting balance set correctly"
        );
    }

    function test_AllowanceSetCorrectly() public {
        assertEq(
            initialAllowance,
            myTokenUsingOZ.allowance(bob, alice),
            "Allowance of Alice to spend Bobs tokens set correctly"
        );
    }

    function test_NameIsSetCorrectly() public {
        assertEq("My Token", myTokenUsingOZ.name(), "Name set correctly");
    }

    function test_SymbolIsSetCorrectly() public {
        assertEq("AMT", myTokenUsingOZ.symbol(), "Symbol set correctly");
    }

    function test_DecmialIsSetCorrectly() public {
        assertEq(18, myTokenUsingOZ.decimals(), "Decimal set correctly");
    }

    function test_InitialSupply() public {
        assertEq(
            myTokenUsingOZ.totalSupply(),
            deployer.INITIAL_SUPPLY(),
            "Initial supply set correctly"
        );
    }

    //################################## Transfer Tests ##################################
    function test_BalancesAfterTransfer() public {
        uint256 transferAmount = 10 ether;
        vm.prank(bob);
        myTokenUsingOZ.transfer(alice, transferAmount);
        assertEq(
            myTokenUsingOZ.balanceOf(alice),
            transferAmount,
            "Alice balance is transferAmount"
        );
        assertEq(
            myTokenUsingOZ.balanceOf(bob),
            startingBalace - transferAmount,
            "Bob balance is starting balance minus transfer amount"
        );
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    function test_EmitTransfer_AfterTransfer() public {
        uint256 transferAmount = 10 ether;
        vm.prank(bob);
        vm.expectEmit(true, true, true, true);
        emit Transfer(bob, alice, transferAmount);
        myTokenUsingOZ.transfer(alice, transferAmount);
    }

    function test_RevertIf_TransferFromAddressIsZeroAddress() public {
        vm.prank(address(0));
        vm.expectRevert(bytes("ERC20: transfer from the zero address"));
        myTokenUsingOZ.transfer(alice, 10 ether);
    }

    function test_RevertIf_TransferToAddressIsZeroAddress() public {
        vm.prank(bob);
        vm.expectRevert(bytes("ERC20: transfer to the zero address"));
        myTokenUsingOZ.transfer(address(0), 10 ether);
    }

    function test_RevertIf_TransferAmountExceedsBalance() public {
        vm.prank(bob);
        vm.expectRevert(bytes("ERC20: transfer amount exceeds balance"));
        myTokenUsingOZ.transfer(alice, 10000 ether);
    }

    // function testUsersCantMint() public {
    //     vm.expectRevert();
    //     MintableToken(address(myTokenUsingOZ)).mint(address(this), 1);
    // }
    function test_ApproveAddsToAllowanceMappingCorrectly() public {
        uint256 transferAmount = 500;
        vm.prank(alice);
        myTokenUsingOZ.approve(bob, transferAmount);
        assertEq(myTokenUsingOZ.allowance(alice, bob), transferAmount);
    }

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function test_EmitApproval_AfterApprove() public {
        uint256 transferAmount = 10 ether;
        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, bob, transferAmount);
        myTokenUsingOZ.approve(bob, transferAmount);
    }
}
