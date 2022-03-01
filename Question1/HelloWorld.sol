// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.10 and less than 0.9.0
pragma solidity ^0.8.10;

//Declares Contract HelloWorld.
contract HelloWorld {
    ///declares Var "count" & sets initial value.
    uint public count = 5;


    // Function to get the current count.
    function getCount() view public returns (uint) {
        return count;
    }

}
