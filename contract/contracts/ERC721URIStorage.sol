// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.24;

import {ERC721} from "./ERC721.sol";
import {ERC721Metadata} from "./ERC721Metadata.sol";
import {IERC721Metadata} from "./interfaces/IERC721Metadata.sol";
import {IERC4906} from "./interfaces/IERC4906.sol";
import {IERC165} from "./interfaces/IERC165.sol";

/**
 * @dev ERC-721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721, ERC721Metadata, IERC4906 {
    // Interface ID as defined in ERC-4906. This does not correspond to a traditional interface ID as ERC-4906 only
    // defines events and does not include any external function.
    bytes4 private constant ERC4906_INTERFACE_ID = bytes4(0x49064906);

    // Optional mapping for token URIs
    mapping(uint256 tokenId => string) private _tokenURIs;

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        return interfaceId == ERC4906_INTERFACE_ID || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IERC721Metadata
    function tokenURI(uint256 _tokenId) external virtual view tokenExists(_tokenId) override(ERC721Metadata) returns (string memory) {
        string memory _tokenURI = _tokenURIs[_tokenId];

        if (bytes(_tokenURI).length != 0) {
            return _tokenURI;
        }
        
        string memory baseURI = _getBaseURI();

        return string(abi.encodePacked(baseURI, _tokenId, ".json"));
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Emits {IERC4906-MetadataUpdate}.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenURIs[tokenId] = _tokenURI;
        emit MetadataUpdate(tokenId);
    }
}