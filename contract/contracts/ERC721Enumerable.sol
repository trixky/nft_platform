// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.24;

// from : https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Burnable.sol

import {IERC721Enumerable} from "./interfaces/IERC721Enumerable.sol";
import {ERC165} from "./ERC165.sol";
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

        
    }

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256) {

    }
}