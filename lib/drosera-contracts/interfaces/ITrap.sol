// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external view returns (bool, string memory);
}