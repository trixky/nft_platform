// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.24;

// from : https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Burnable.sol

import {IERC721Enumerable} from "./interfaces/IERC721Enumerable.sol";
import {ERC721} from "./ERC721.sol";

/**
 * @title ERC-721 Burnable Token
 * @dev ERC-721 Token that can be burned (destroyed).
 */
contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address owner => mapping(uint256 index => uint256)) private _ownedTokens;
    mapping(uint256 tokenId => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 tokenId => uint256) private _allTokensIndex;

    error OwnerTokenIndexOverflow(address owner, uint256 index);

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns(bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

        /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
        if (_index > balanceOf(_owner)) {
            revert OwnerTokenIndexOverflow(_owner, _index);
        }

        return _ownedTokens[_owner][_index];
    }
    
    function _update(address _from, address _to, uint256 _tokenId) internal override virtual {
        super._update(_from, _to, _tokenId);

        if (_from == address(0)) {
            _addTokenToAllTokensEnumeration(_tokenId);
        } else if (_from != _to) {
            _removeTokenFromOwnerEnumeration(_from, _tokenId);
        }

        if (_to == address(0)) {
            _removeTokenFromAllEnumeration(_tokenId);
        } else if (_from != _to) {
            _addTokenToOwnerEnumeration(_to, _tokenId);
        }
    }

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256) {

    }

    // =========================================== private (for the _update override)
    function _addTokenToOwnerEnumeration(address _to, uint256 _tokenId) private {
        uint256 length = balanceOf(_to) - 1;
        _ownedTokens[_to][length] = _tokenId;
        _ownedTokensIndex[_tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 _tokenId) private {
        _allTokensIndex[_tokenId] = _allTokens.length;
        _allTokens.push(_tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address _from, uint256 _tokenId) private {
        uint256 lastTokenIndex = balanceOf(_from);
        uint256 tokenIndex = _ownedTokensIndex[_tokenId];

        mapping(uint256 index => uint256) storage _ownedTokensByOwner = _ownedTokens[_from];

        if (tokenIndex != lastTokenIndex) {
            // swap only if the token index is not the last one
            uint256 lastTokenId = _ownedTokensByOwner[lastTokenIndex];

            _ownedTokensByOwner[tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        delete _ownedTokensIndex[_tokenId];
        delete _ownedTokensByOwner[lastTokenIndex];
    }

    function _removeTokenFromAllEnumeration(uint256 _tokenId) private {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[_tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        // swap in any case because the "if" case is rare (gas optimization)
        _allTokens[tokenIndex] = lastTokenId; // swap
        _allTokensIndex[lastTokenId] = tokenIndex; // swap

        delete _allTokensIndex[_tokenId];
        _allTokens.pop();
    }
}