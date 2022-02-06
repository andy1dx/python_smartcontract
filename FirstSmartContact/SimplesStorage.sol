// SPDX License-Identifier: MIT
pragma solidity ^0.6.0;

contract SimpleStorage {
    uint256 favoriteNumber;

    struct People {
        uint256 favoriteNumber;
        string name;
    }

    People person = People({favoriteNumber: 2, name: "name"});

    People[] people;

    mapping(string=>uint256) public nameToFavoriteNumber;

    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
    }

    // view and pure no need tracsaction
    // view for getting data
    // pure for run function with out changing data
    function retrieve() public view returns(uint256) {
        return favoriteNumber;
    }

    function plus(uint256 _favoriteNumbe) public pure {
        _favoriteNumbe + _favoriteNumbe;
    }

    // place to store the object
    // memory or storage
    // memory is better use when we only use the object in this function (data will be delete after function finish)
    // storage will save event function finish execute
    function assPerson(string memory _name, uint256 _favoriteNumber) public {
        people.push(People(_favoriteNumber, _name));
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }
}

// Way To Deploy
//ENVIRONMENT https://remix.ethereum.org/
// 1 JavaScript VM => Deploy in web  https://remix.ethereum.org/
// Deploy To Metamas
// Deploy to own web3
// EVM => Is the compliler that is generated when deploy smart contract
