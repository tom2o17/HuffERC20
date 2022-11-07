// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "lib/forge-std/src/console.sol";

contract H20Test is Test {
    H20 instance; 

    function setUp() public {
        instance = H20(HuffDeployer.deploy("H20"));
        vm.startPrank(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        instance.mint(1000);
        instance.mint(1000);
        instance.approve(address(1), 10);
        // instance.mint(1000);
        // vm.stopPrank();
        // vm.stopPrank();
    }   

    function testGetOwner() public {
        // console.log(address(1));
        console.log(instance.owner());
    }

    function testGetBalanceOf() public {
        console.log(instance.balanceOf(address(1)));
    }

    function testMint() public {
        // vm.startPrank(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        instance.mint(1000);
        // console.log(instance.balanceOf(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246)));
    }


    function testTotalSupply() public {
        // vm.startPrank(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        // instance.mint(1000);
        console.log(instance.totalSupply());
    }

    function testTransfer() public {
        // vm.startPrank(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        // instance.mint(1000);
        // instance.mint(1000);
        instance.transfer(address(1), 200);
        console.log(instance.balanceOf(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246)));
        console.log(instance.balanceOf(address(1)));
    }

    function testTransferEdge() public {
        // vm.startPrank(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        // instance.mint(1000);
        // instance.mint(1000);
        instance.transfer(address(1), 1000);
        console.log(instance.balanceOf(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246)));
    }

    function test_transferFrom() public {
        // instance.mint(100);
        
        vm.stopPrank();
        vm.prank(address(1));
        instance.transferFrom(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246), address(1), 10);
        console.log(instance.balanceOf(address(1)));
        console.log(instance.balanceOf(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246)));
    }


    function testTransferTooMuch() public {
        // vm.startPrank(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        // instance.mint(1000);
        // instance.mint(1000);
        vm.expectRevert();
        instance.transfer(address(1), 200000);
        console.log(instance.balanceOf(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246)));
    }

    function testApprove() public {
        // vm.prank(0xCe71065D4017F316EC606Fe4422e11eB2c47c246);
        instance.approve(address(1), 500);
        // console.log(instance.allowance(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246), address(1)));
    }
    function testApproveEdge() public {
        // vm.startPrank(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        // instance.mint(1000);
        instance.approve(address(1), 1000);
        console.log(instance.allowance(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246), address(1)));
    }
    function testApproveFail() public {
        // vm.startPrank(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        // instance.mint(1000);
        vm.expectRevert();
        instance.approve(address(1), 5000);
        console.log(instance.allowance(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246), address(1)));
    }

    // TODO fix this 
    function testTransferFrom() public {
        // vm.startPrank(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        // instance.mint(1000);
        console.log(instance.balanceOf(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246)));
        instance.approve(address(1), 500);
        vm.stopPrank();
        console.log(instance.allowance(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246), address(1)));
        vm.prank(address(1));
        instance.transferFrom(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246), address(1), 500);
        console.log("Should be 1500");
        console.log(instance.balanceOf(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246)));
        assert(instance.balanceOf(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246)) == 1500);
        console.log("Should be 500");
        console.log(instance.balanceOf(address(1)));
        assert(instance.balanceOf(address(1)) == 500);
        console.log("Should be 0");
        console.log(instance.allowance(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246), address(1)));
        console.log(instance.allowance(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246), address(1)) == 0);
    }

    function testName() public {
        // instance.setName("TAC");
        // console.log(instance.name());
        console.log(instance.name());
    }

}

interface H20 {
    function owner() external view returns(address);
    function totalSupply() external view returns(uint256);
    function mint(uint256) external;
    function balanceOf(address) external view returns(uint256);
    function transfer(address, uint256) external;
    function allowance(address, address) external view returns(uint256);
    function approve(address, uint256) external;
    function transferFrom(address, address, uint256) external;
    function setName(string memory) external;
    function name() external view returns(string memory);
}
