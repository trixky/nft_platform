// SPDX-License-Identifier: UNKNOWN 

pragma solidity ^0.8.20;

// IERC721 : https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99eda2225c0246c265c902475c47ec0c6321f119/contracts/token/ERC721/IERC721.sol#L1
import {IERC165} from "./interfaces/IERC165.sol";

contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}