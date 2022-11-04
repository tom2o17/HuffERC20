// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract SimpleStoreTest is Test {
    /// @dev Address of the SimpleStore contract.
    SimpleStore public simpleStore;

    /// @dev Setup the testing environment.
    function setUp() public {
        simpleStore = SimpleStore(HuffDeployer.deploy("SimpleStore"));
    }

    /// @dev Ensure that you can set and get the value.
    function testSetAndGetValue(uint256 value) public {
        simpleStore.setValue(value);
        console.log(value);
        console.log(simpleStore.getValue());
        assertEq(value, simpleStore.getValue());
    }

    function testLog() public {
        console.log("The default value");
        console.log(simpleStore.getValue());
        simpleStore.setValue(1);
        console.log(1);
        console.log(simpleStore.getValue());
    }
}

interface SimpleStore {
    function setValue(uint256) external;
    function getValue() external returns (uint256);
}

interface SimpleAddress {
    function setAddress(address) external;
    function getAddress() external returns (address);
}

contract NativeAddress {
    address value;
    function setAddress(address _value) external {
        value = _value;
    }

    function getAddress() external view returns(address) {
        return value;
    }
}


contract SimpleAddressTest is Test {
    /// @dev Address of the SimpleStore contract.
    SimpleAddress public simpleAddress;
    NativeAddress public nativeAddress;

    /// @dev Setup the testing environment.
    function setUp() public {
        simpleAddress = SimpleAddress(HuffDeployer.deploy("SimpleAddress"));
        nativeAddress = new NativeAddress();
    }

    function testNativeSet() public {
        nativeAddress.setAddress(address(1));
    }
    function testHuffSet() public {
        simpleAddress.setAddress(address(1));
    }

    /// @dev Ensure that you can set and get the value.
    function testSetAndGetValue() public {
        simpleAddress.setAddress(address(1));
        console.log(simpleAddress.getAddress());
    }

    function testSetAndGetValue_native() public {
        nativeAddress.setAddress(address(1));
        console.log(nativeAddress.getAddress());
    }

    function testLog() public {
        console.log("The default value");
        console.log(simpleAddress.getAddress());
        simpleAddress.setAddress(address(1));
        console.log(simpleAddress.getAddress());
    }
}


interface ITSOwnable {
    function owner() external view returns (address);
    function pendingOwner() external view returns (address);
    function fault() external view returns (address);

    // function setPendingOwner(address pendingOwner) external;
    function acceptOwnership() external;
}

contract TSOwnableTest is Test {

    // The System under Test.
    ITSOwnable sut;

    function setUp() public {
       sut = ITSOwnable(HuffDeployer.deploy("TSOwnable"));
    }

   function testBasic() public {
    console.log(sut.owner());
    console.log(sut.pendingOwner());
   }
   function test_call_fake_function() public {
    console.log(sut.fault());
   }
   
}

contract H20Test is Test {
    

    function testGetOwner() public {
        console.log("Hello");
    }

}
