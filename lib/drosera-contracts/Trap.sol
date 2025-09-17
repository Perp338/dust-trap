// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./interfaces/ITrap.sol";

contract Trap is ITrap {
    function collect() external view virtual override returns (bytes memory) {
        return bytes("");
    }

    function shouldRespond(bytes[] calldata data) external view virtual override returns (bool, string memory) {
        return (false, "");
    }
}
