// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "lib/forge-std/src/console.sol";

contract H20Test is Test {
    H20 instance; 

    function setUp() public {
        instance = H20(HuffDeployer.deploy("H20"));
    }   

    function testGetOwner() public {
        console.log(address(1));
        console.log(instance.owner());
    }

    function testGetBalanceOf() public {
        console.log(instance.balanceOf(address(1)));
    }

    function testMint() public {
        vm.startPrank(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        instance.mint(1000);
        console.log(instance.balanceOf(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246)));
    }

    function testMint2() public {
        vm.prank(address(1));
        vm.expectRevert();
        instance.mint(1000);
        console.log(instance.balanceOf(address(1)));
    }

    function testTotalSupply() public {
        vm.startPrank(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        instance.mint(1000);
        instance.mint(1000);
        console.log(instance.totalSupply());
    }

    function testTransfer() public {
        vm.startPrank(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        instance.mint(1000);
        instance.mint(1000);
        instance.transfer(address(1), 200);
        console.log(instance.balanceOf(address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246)));
    }

}

interface H20 {
    function owner() external view returns(address);
    function totalSupply() external view returns(uint256);
    function mint(uint256) external;
    function balanceOf(address) external view returns(uint256);
    function transfer(address, uint256) external;
}
