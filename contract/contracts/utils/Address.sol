// SPDX-License-Identifier: UNKNOWN 
pragma solidity ^0.8.20;

// https://github.com/binodnp/openzeppelin-solidity/blob/master/contracts/utils/Address.sol

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;

        assembly {
            size := extcodesize(account)
        }

        return size > 0;
    }
}