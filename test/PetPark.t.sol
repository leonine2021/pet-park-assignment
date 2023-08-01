// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PetPark.sol";

contract PetParkTest is Test, PetPark {
    PetPark petPark;

    address testOwnerAccount;

    address testPrimaryAccount;
    address testSecondaryAccount;

    function setUp() public {
        petPark = new PetPark();

        testOwnerAccount = msg.sender;
        testPrimaryAccount = address(0xABCD);
        testSecondaryAccount = address(0xABDC);
    }

    function testOwnerCanAddAnimal() public {
        petPark.add(PetPark.AnimalType.Fish, 5);
    }

    function testCannotAddAnimalWhenNonOwner() public {
        // 1. Complete this test and remove the assert line below
        vm.prank(testPrimaryAccount);
        vm.expectRevert("Only the contract owner can call this function");
        petPark.add(PetPark.AnimalType.Fish, 5);
    }

    function testCannotAddInvalidAnimal() public {
        vm.expectRevert("Invalid animal");
        petPark.add(PetPark.AnimalType.None, 5);
    }

    function testExpectEmitAddEvent() public {
        vm.expectEmit(false, false, false, true);

        emit Added(PetPark.AnimalType.Fish, 5);
        petPark.add(PetPark.AnimalType.Fish, 5);
    }

    function testCannotBorrowWhenAgeZero() public {
        // 2. Complete this test and remove the assert line below
        vm.expectRevert("Age cannot be zero");
        petPark.borrow(0, PetPark.Gender.Male, PetPark.AnimalType.Fish);
    }

    function testCannotBorrowUnavailableAnimal() public {
        vm.expectRevert("Selected animal not available");

        petPark.borrow(24, PetPark.Gender.Male, PetPark.AnimalType.Fish);
    }

    function testCannotBorrowInvalidAnimal() public {
        vm.expectRevert("Invalid animal type");

        petPark.borrow(24, PetPark.Gender.Male, PetPark.AnimalType.None);
    }

    function testCannotBorrowCatForMen() public {
        petPark.add(PetPark.AnimalType.Cat, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, PetPark.Gender.Male, PetPark.AnimalType.Cat);
    }

    function testCannotBorrowRabbitForMen() public {
        petPark.add(PetPark.AnimalType.Rabbit, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, PetPark.Gender.Male, PetPark.AnimalType.Rabbit);
    }

    function testCannotBorrowParrotForMen() public {
        petPark.add(PetPark.AnimalType.Parrot, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, PetPark.Gender.Male, PetPark.AnimalType.Parrot);
    }

    function testCannotBorrowForWomenUnder40() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Invalid animal for women under 40");
        petPark.borrow(24, PetPark.Gender.Female, PetPark.AnimalType.Cat);
    }

    function testCannotBorrowTwiceAtSameTime() public {
        petPark.add(PetPark.AnimalType.Fish, 5);
        petPark.add(PetPark.AnimalType.Cat, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, PetPark.Gender.Male, PetPark.AnimalType.Fish);

        vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, PetPark.Gender.Male, PetPark.AnimalType.Fish);

        vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, PetPark.Gender.Male, PetPark.AnimalType.Cat);
    }

    function testCannotBorrowWhenAddressDetailsAreDifferent() public {
        petPark.add(PetPark.AnimalType.Fish, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, PetPark.Gender.Male, PetPark.AnimalType.Fish);

        vm.expectRevert("Invalid Age");
        vm.prank(testPrimaryAccount);
        petPark.borrow(23, PetPark.Gender.Male, PetPark.AnimalType.Fish);

        vm.expectRevert("Invalid Gender");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, PetPark.Gender.Female, PetPark.AnimalType.Fish);
    }

    function testExpectEmitOnBorrow() public {
        petPark.add(PetPark.AnimalType.Fish, 5);
        vm.expectEmit(false, false, false, true);

        emit Borrowed(PetPark.AnimalType.Fish);
        petPark.borrow(24, PetPark.Gender.Male, PetPark.AnimalType.Fish);
    }

    function testBorrowCountDecrement() public {
        // 3. Complete this test and remove the assert line below
        uint count = 5;
        petPark.add(PetPark.AnimalType.Fish, count);

        petPark.borrow(24, PetPark.Gender.Male, PetPark.AnimalType.Fish);
        uint reducedPetCount = petPark.animalCounts(PetPark.AnimalType.Fish);
        assertEq(reducedPetCount, count - 1);
    }

    function testCannotGiveBack() public {
        vm.expectRevert("No borrowed pets");
        petPark.giveBackAnimal();
    }

    function testPetCountIncrement() public {
        petPark.add(PetPark.AnimalType.Fish, 5);

        petPark.borrow(24, PetPark.Gender.Male, PetPark.AnimalType.Fish);
        uint reducedPetCount = petPark.animalCounts(PetPark.AnimalType.Fish);

        petPark.giveBackAnimal();
        uint currentPetCount = petPark.animalCounts(PetPark.AnimalType.Fish);

        assertEq(reducedPetCount, currentPetCount - 1);
    }
}
