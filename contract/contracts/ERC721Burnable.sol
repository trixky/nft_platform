// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.24;

// from : https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Burnable.sol

import {ERC721} from "./ERC721.sol";

/**
 * @title ERC-721 Burnable Token
 * @dev ERC-721 Token that can be burned (destroyed).
 */
abstract contract ERC721Burnable is ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) tokenExists(tokenId) operatorIsAuthorizedForTransfer(tokenId) public  {
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.

        _update(msg.sender, address(0), tokenId);
    }
}