//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    address public owner;
    enum AnimalType {
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot,
        None
    }
    enum Gender {
        Male,
        Female
    }

    mapping(address => Borrower) public borrowers;
    mapping(AnimalType => uint256) public animalCounts;

    struct Borrower {
        bool hasBorrowed;
        uint8 age;
        Gender gender;
        AnimalType borrowedAnimalType;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    event Added(AnimalType indexed animalType, uint256 count);
    event Borrowed(AnimalType indexed animalType);
    event Returned(AnimalType indexed animalType);

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animalType, uint256 _count) public onlyOwner {
        //animal type cannot be none
        require(_animalType != AnimalType.None, "Invalid animal");
        animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animalType) public {
        //age cannot be zero
        require(_age > 0, "Age cannot be zero");
        //animal type cannot be none
        require(_animalType != AnimalType.None, "Invalid animal type");
        //same address cannot borrow twice with different age or gender details
        if (borrowers[msg.sender].age > 0) {
            require(borrowers[msg.sender].age == _age, "Invalid Age");
            require(borrowers[msg.sender].gender == _gender, "Invalid Gender");
        }
        // same address cannot borrow twice with same age, gender and animal type
        require(!borrowers[msg.sender].hasBorrowed, "Already adopted a pet");
        // gender related limits
        require(
            (_gender == Gender.Male &&
                (_animalType == AnimalType.Fish ||
                    _animalType == AnimalType.Dog)) ||
                (_gender == Gender.Female &&
                    (_age >= 40 || _animalType != AnimalType.Cat)),
            _gender == Gender.Male
                ? "Invalid animal for men"
                : "Invalid animal for women under 40"
        );
        // animal count must not be zero to be able to borrow
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        borrowers[msg.sender] = Borrower(true, _age, _gender, _animalType);
        animalCounts[_animalType]--;
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        // must borrowed a pet first before return
        require(borrowers[msg.sender].hasBorrowed, "No borrowed pets");
        AnimalType borrowedAnimalType = borrowers[msg.sender]
            .borrowedAnimalType;
        delete borrowers[msg.sender];
        animalCounts[borrowedAnimalType]++;
        emit Returned(borrowedAnimalType);
    }
}
