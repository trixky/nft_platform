pragma solidity ^0.8.26;

// https://eips.ethereum.org/EIPS/eip-7572
import {IERC7572} from './interfaces/IERC7572.sol';

abstract contract ERC7572 is IERC7572 {
  string private _contractURI;

  function contractURI() external view returns (string memory) {
    return _contractURI;
  }

  function _updateContractURI(string calldata contractURI_) internal {
    _contractURI = contractURI_;
  }
}
