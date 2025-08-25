pragma solidity ^0.8.26;

// https://eips.ethereum.org/EIPS/eip-7572

interface IERC7572 {
  function contractURI() external view returns (string memory);

  event ContractURIUpdated();
}
