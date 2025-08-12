pragma solidity ^0.8.26;

import {IERC721} from "./interfaces/IERC721.sol";
import {ERC165} from "./ERC165.sol";
import {Address} from "./utils/Address.sol";

// https://github.com/ethereum/ercs/blob/master/ERCS/erc-721.md
// inspiration : https://opensea.io/collection/magicalpixelord

// IERC721Receiver : https://github.com/binodnp/openzeppelin-solidity/blob/master/contracts/token/ERC721/IERC721Receiver.sol
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract ERC721 is IERC721, ERC165 {
    // *********************************************************** INIT
    using Address for address;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // ownership
    mapping(address owner => uint256 count) _ownerCounts;
    mapping(uint256 tokenId => address owner) internal _tokenOwners;
    // approvals
    mapping(uint256 tokenId => address operator) internal _tokenApprovals;
    mapping(address owner => mapping(address operator => bool)) internal _ownerOperators;

    // =========================================================== PRIVATE
    // =========================================================== INTERNAL
    // ---------------------------------- Errors
    error NotAuthorizedOperator(address addr, uint256 tokenId);
    error TokenDoesNotExist(uint256 tokenId);
    error InvalidAddress(address addr);
    error FromIsTo(address from, address to);
    error TokenOwnerMissMatch(uint256 tokenId, address owner);
    error DestinationNotSafe(address to);

    // ---------------------------------- Modifiers
    modifier fromIsNotTo(address _from, address _to) {
        if (_from == _to) revert FromIsTo(_from, _to);
        _;
    }

    modifier addressIsValid(address _addr) {
        if (_addr == address(0)) revert InvalidAddress(_addr);
        _;
    }

    modifier tokenExists(uint256 _tokenId) {
        if (_tokenOwners[_tokenId] != address(0)) revert TokenDoesNotExist(_tokenId);
        _;
    }

    modifier operatorIsAuthorizedForApproval(uint256 _tokenId) {
        address tokenOwner = _tokenOwners[_tokenId];
        if (!(
            tokenOwner == msg.sender
            || _ownerOperators[tokenOwner][msg.sender] == true
            )) revert NotAuthorizedOperator(msg.sender, _tokenId);
        _;
    }

    modifier operatorIsAuthorizedForTransfer(uint256 _tokenId) {
        address tokenOwner = _tokenOwners[_tokenId];
        if (!(
            tokenOwner == msg.sender
            || _ownerOperators[tokenOwner][msg.sender] == true
            || _tokenApprovals[_tokenId] == msg.sender
            )) revert NotAuthorizedOperator(msg.sender, _tokenId);
        _;
    }

    modifier tokenIsFrom(uint256 _tokenId, address _from) {
        if (_tokenOwners[_tokenId] != _from) revert TokenOwnerMissMatch(_tokenId, _from);
        _;
    }

    modifier _destinationSafety(address _from, address _to, uint256 _tokenId, bytes calldata _data) {
        if (!_to.isContract()) {
            if (IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) != _ERC721_RECEIVED) revert DestinationNotSafe(_to);
        }
        _;
    }

    // ---------------------------------- Functions
    function _transfer(address _from, address _to, uint256 _tokenId) internal virtual {
        _ownerCounts[_from]--;
        _ownerCounts[_to]++;
        _tokenOwners[_tokenId] = _to;
        delete _tokenApprovals[_tokenId];
    }

    // =========================================================== PUBLIC
    // =========================================================== EXTERNAL

    // ERC165 override
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId || super.supportsInterface(interfaceId);
    }

    // IERC721 implementation
    function balanceOf(address _owner) external view addressIsValid(_owner) returns (uint256) {
        return _ownerCounts[_owner];
    }

    // IERC721 implementation
    function ownerOf(uint256 _tokenId) external view tokenExists(_tokenId) returns (address) {
        return _tokenOwners[_tokenId];
    }

    // IERC721 implementation
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data)
    external
    payable 
    tokenExists(_tokenId)
    addressIsValid(_from)
    addressIsValid(_to) 
    fromIsNotTo(_from, _to)
    tokenIsFrom(_tokenId, _from)
    operatorIsAuthorizedForTransfer(_tokenId)
    _destinationSafety(_from, _to, _tokenId, _data) {
        _transfer(_from, _to, _tokenId);
    }

    // IERC721 implementation
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        this.safeTransferFrom(_from, _to, _tokenId, "");
    }

    // IERC721 implementation
    function transferFrom(address _from, address _to, uint256 _tokenId)
    external
    payable 
    tokenExists(_tokenId)
    addressIsValid(_from)
    addressIsValid(_to) 
    fromIsNotTo(_from, _to)
    tokenIsFrom(_tokenId, _from)
    operatorIsAuthorizedForTransfer(_tokenId) {
        _transfer(_from, _to, _tokenId);
    }

    // IERC721 implementation
    function approve(address _operator, uint256 _tokenId)
    external
    payable 
    addressIsValid(_operator) 
    tokenExists(_tokenId) 
    operatorIsAuthorizedForApproval(_tokenId) {
        _tokenApprovals[_tokenId] = _operator;
    }

    // IERC721 implementation
    function setApprovalForAll(address _operator, bool _approved)
    external
    addressIsValid(_operator) {
        _ownerOperators[msg.sender][_operator] = _approved;
    }

    // IERC721 implementation
    function getApproved(uint256 _tokenId) 
    external 
    view
    tokenExists(_tokenId)
    returns (address) {
        return _tokenApprovals[_tokenId];
    }

    // IERC721 implementation
    function isApprovedForAll(address _owner, address _operator)
    external
    view
    addressIsValid(_owner) 
    addressIsValid(_operator) 
    returns (bool) {
        return _ownerOperators[_owner][_operator];
    }
}