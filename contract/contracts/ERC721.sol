// SPDX-License-Identifier: UNKNOWN 
pragma solidity ^0.8.26;

// ERC721 : https://github.com/binodnp/openzeppelin-solidity/blob/master/contracts/token/ERC721/ERC721.sol
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// IERC721Receiver : https://github.com/binodnp/openzeppelin-solidity/blob/master/contracts/token/ERC721/IERC721Receiver.sol
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./utils/Address.sol";
// IERC165 : https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99eda2225c0246c265c902475c47ec0c6321f119/contracts/utils/introspection/IERC165.sol#L3
// ERC165 : https://github.com/OpenZeppelin/openzeppelin-contracts/blob/99eda2225c0246c265c902475c47ec0c6321f119/contracts/utils/introspection/ERC165.soll
import {ERC165} from  "./utils/ERC165.sol";

contract ERC721 is ERC165, IERC721 {
    using Address for address;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping(uint256 tokenid => address) private _tokenOwner;
    mapping(uint256 tokenid => address) private _tokenApprovals;

    mapping(address account => uint256) private _ownedTokensCount;

    mapping(address => mapping(address => bool)) _operatorApprovals;

    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;

    function balanceOf(address owner) public view returns(uint256) {
        require(owner != address(0));
        return _ownedTokensCount[owner];
    }

    function ownerOf(uint256 tokenId) public view returns(address) {
        address owner = _tokenOwner[tokenId];
        require (owner != address(0));
        return owner;
    }

    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, to));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns(address) {
        require (_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns(bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        require(to != address(0));

        _clearApproval(from, tokenId);
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data)); // ??????????
    }

    function _exists(uint256 tokenId) internal view returns(bool) {
        return _tokenOwner[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);

        return (spender == owner || getApproved(tokenId) == owner || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0));
        _addTokenTo(to, tokenId);
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {
        _clearApproval(owner, tokenId);
        _removeTokenFrom(owner, tokenId);
        emit Transfer(owner, address(0), tokenId);
    }

    function _addTokenTo(address to, uint256 tokenId) internal {
        require(_tokenOwner[tokenId] == address(0));
        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to]++;
    }

    function _removeTokenFrom(address from, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from);
        _ownedTokensCount[from]--;
        delete _tokenOwner[tokenId];
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(address owner, uint256 tokenId) private {
        require(ownerOf(tokenId) == owner);
        if (_tokenApprovals[tokenId] != address(0)) {
            delete _tokenApprovals[tokenId];
        }
    }
}