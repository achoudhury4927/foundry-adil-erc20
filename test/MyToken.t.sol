// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public myToken;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    uint256 public constant INITIAL_SUPPLY = 1000 ether;
    uint256 startingBalace = 100 ether;

    function setUp() public {
        myToken = new MyToken();
    }

    function test_Name() public {
        assertEq("My Token", myToken.name());
    }

    function test_Symbol() public {
        assertEq("AMT", myToken.symbol());
    }

    function test_Decimals() public {
        assertEq(3, myToken.decimals());
    }

    function test_TotalSupply() public {
        assertEq(1000, myToken.totalSupply());
    }

    function test_BalanceOf() public {
        assertEq(0, myToken.balanceOf(msg.sender));
    }

    //This test fails highlighting the contract is unuseable as an ERC-20
    function testFail_Transfer() public {
        myToken.transfer(alice, 1);
    }

    //The problem with testing my blind attempt is there is no way
    //to transfer balance to another address as the tokens havent been minted to an address
    //Using the standards on OpenZepplin, the whole supply is minted to the deployer of the token.
}
