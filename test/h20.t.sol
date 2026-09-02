// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "lib/forge-std/src/console.sol";

contract H20Test is Test {
    H20 instance;

    // The CONSTRUCTOR stores `caller` (the HuffConfig helper) as the owner, so
    // we force OWNER_SLOT (0x01) after deployment to the address the tests prank as.
    address constant OWNER = 0xCe71065D4017F316EC606Fe4422e11eB2c47c246;
    uint256 constant OWNER_SLOT = 1;

    // Three distinct actors so `from`, `to` and `msg.sender` are never aliased.
    address constant SPENDER = address(0xBEEF);
    address constant RECIPIENT = address(0xCAFE);

    function setUp() public {
        instance = H20(HuffDeployer.deploy("H20"));
        vm.store(address(instance), bytes32(OWNER_SLOT), bytes32(uint256(uint160(OWNER))));
        vm.startPrank(OWNER);
        instance.mint(1000);
        instance.mint(1000);
        instance.approve(address(1), 10);
    }

    function testGetOwner() public {
        assertEq(instance.owner(), OWNER);
    }

    function testGetBalanceOf() public {
        assertEq(instance.balanceOf(address(1)), 0);
        assertEq(instance.balanceOf(OWNER), 2000);
    }

    function testMint() public {
        instance.mint(1000);
        assertEq(instance.balanceOf(OWNER), 3000);
        assertEq(instance.totalSupply(), 3000);
    }

    function testTotalSupply() public {
        assertEq(instance.totalSupply(), 2000);
    }

    function testTransfer() public {
        instance.transfer(address(1), 200);
        assertEq(instance.balanceOf(OWNER), 1800);
        assertEq(instance.balanceOf(address(1)), 200);
    }

    // NOTE: kept at 1000 (the amount this test always used). A true exact-balance
    // transfer of 2000 reverts because TRANSFER()'s equality check is broken --
    // after `gt` it does `dup2 dup2 eq`, which compares the gt-flag against
    // `balance` instead of `balance` against `value`. That is a TRANSFER() bug,
    // out of scope for the transferFrom work, and is reported separately.
    function testTransferEdge() public {
        instance.transfer(address(1), 1000);
        assertEq(instance.balanceOf(OWNER), 1000);
        assertEq(instance.balanceOf(address(1)), 1000);
    }

    function testTransferTooMuch() public {
        vm.expectRevert();
        instance.transfer(address(1), 200000);
        assertEq(instance.balanceOf(OWNER), 2000);
    }

    // Regression for the dispatcher fall-through: `transfer` used to run straight
    // on into APPROVE(), silently granting allowance[msg.sender][to] += value.
    function testTransferDoesNotGrantAllowance() public {
        instance.transfer(RECIPIENT, 200);
        assertEq(instance.balanceOf(RECIPIENT), 200);
        assertEq(instance.allowance(OWNER, RECIPIENT), 0);
        assertEq(instance.allowance(OWNER, address(1)), 10);
    }

    function testApprove() public {
        instance.approve(address(1), 500);
        // NOTE: APPROVE() increments rather than sets, and setUp() already approved 10.
        assertEq(instance.allowance(OWNER, address(1)), 510);
    }

    function testApproveEdge() public {
        instance.approve(address(1), 1000);
        assertEq(instance.allowance(OWNER, address(1)), 1010);
    }

    function testApproveFail() public {
        vm.expectRevert();
        instance.approve(address(1), 5000);
        assertEq(instance.allowance(OWNER, address(1)), 10);
    }

    /* -------------------------------------------------------------------- */
    /*                              transferFrom                            */
    /* -------------------------------------------------------------------- */

    function testTransferFromHappyPath() public {
        instance.approve(SPENDER, 500);
        vm.stopPrank();

        assertEq(instance.allowance(OWNER, SPENDER), 500);

        vm.prank(SPENDER);
        instance.transferFrom(OWNER, RECIPIENT, 200);

        assertEq(instance.balanceOf(OWNER), 1800);
        assertEq(instance.balanceOf(RECIPIENT), 200);
        assertEq(instance.allowance(OWNER, SPENDER), 300);
        assertEq(instance.totalSupply(), 2000);
    }

    // from, to and msg.sender are three different addresses. The allowance must
    // be keyed by the caller (SPENDER), never by the `to` argument.
    function testTransferFromThirdPartySpender() public {
        instance.approve(SPENDER, 500);
        vm.stopPrank();

        vm.prank(SPENDER);
        instance.transferFrom(OWNER, RECIPIENT, 300);

        assertEq(instance.balanceOf(OWNER), 1700);
        assertEq(instance.balanceOf(RECIPIENT), 300);
        assertEq(instance.balanceOf(SPENDER), 0);
        assertEq(instance.allowance(OWNER, SPENDER), 200);
        // The recipient was never approved for anything and must stay at zero.
        assertEq(instance.allowance(OWNER, RECIPIENT), 0);
    }

    function testTransferFromExactAllowance() public {
        instance.approve(SPENDER, 500);
        vm.stopPrank();

        vm.prank(SPENDER);
        instance.transferFrom(OWNER, RECIPIENT, 500);

        assertEq(instance.allowance(OWNER, SPENDER), 0);
        assertEq(instance.balanceOf(OWNER), 1500);
        assertEq(instance.balanceOf(RECIPIENT), 500);
    }

    function testTransferFromRevertsWhenValueExceedsAllowance() public {
        instance.approve(SPENDER, 100);
        vm.stopPrank();

        vm.prank(SPENDER);
        vm.expectRevert();
        instance.transferFrom(OWNER, RECIPIENT, 101);

        assertEq(instance.allowance(OWNER, SPENDER), 100);
        assertEq(instance.balanceOf(OWNER), 2000);
        assertEq(instance.balanceOf(RECIPIENT), 0);
    }

    // Allowance is sufficient but the `from` balance is not.
    function testTransferFromRevertsWhenBalanceInsufficient() public {
        instance.approve(SPENDER, 2000);
        instance.transfer(RECIPIENT, 1500); // OWNER is left with 500
        vm.stopPrank();

        assertEq(instance.balanceOf(OWNER), 500);
        assertEq(instance.allowance(OWNER, SPENDER), 2000);

        vm.prank(SPENDER);
        vm.expectRevert();
        instance.transferFrom(OWNER, RECIPIENT, 2000);

        assertEq(instance.balanceOf(OWNER), 500);
        assertEq(instance.balanceOf(RECIPIENT), 1500);
        assertEq(instance.allowance(OWNER, SPENDER), 2000);
    }

    // transferFrom must accept value == balance and value == allowance exactly.
    function testTransferFromExactBalance() public {
        instance.approve(SPENDER, 2000);
        vm.stopPrank();

        vm.prank(SPENDER);
        instance.transferFrom(OWNER, RECIPIENT, 2000);

        assertEq(instance.balanceOf(OWNER), 0);
        assertEq(instance.balanceOf(RECIPIENT), 2000);
        assertEq(instance.allowance(OWNER, SPENDER), 0);
        assertEq(instance.totalSupply(), 2000);
    }

    function testTransferFromZeroValue() public {
        vm.stopPrank();
        vm.prank(SPENDER);
        instance.transferFrom(OWNER, RECIPIENT, 0);

        assertEq(instance.balanceOf(OWNER), 2000);
        assertEq(instance.balanceOf(RECIPIENT), 0);
        assertEq(instance.allowance(OWNER, SPENDER), 0);
    }

    function testName() public {
        assertEq(instance.name(), "Token");
    }
}

interface H20 {
    function owner() external view returns (address);
    function totalSupply() external view returns (uint256);
    function mint(uint256) external;
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external;
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external;
    function transferFrom(address, address, uint256) external;
    function setName(string memory) external;
    function name() external view returns (string memory);
}
