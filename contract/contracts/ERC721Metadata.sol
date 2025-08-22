pragma solidity ^0.8.26;

import {IERC721Metadata} from "./interfaces/IERC721Metadata.sol";
import {ERC721} from "./ERC721.sol";
import {ERC165} from "./ERC165.sol";
import {Address} from "./utils/Address.sol";

// https://github.com/ethereum/ercs/blob/master/ERCS/erc-721.md
// inspiration : https://opensea.io/collection/magicalpixelord

// IERC721Receiver : https://github.com/binodnp/openzeppelin-solidity/blob/master/contracts/token/ERC721/IERC721Receiver.sol
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract ERC721Metadata is ERC721, IERC721Metadata {
    string private _name;
    string private _symbol;
    string private _baseURI;

    error BaseURIEmpty();

    constructor(string memory name_, string memory symbol_, string memory baseURI_) {
        if (bytes(baseURI_).length == 0) {
            revert BaseURIEmpty(); 
        }

        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
    }

    function _getBaseURI() internal view virtual returns (string memory) {
        return _baseURI;
    }

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external virtual view tokenExists(tokenId) returns (string memory) {
        string memory baseURI = _getBaseURI();

        return string(abi.encodePacked(baseURI, tokenId, ".json"));
    }
}