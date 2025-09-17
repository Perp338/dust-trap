// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./interfaces/ITrap.sol";

abstract contract BaseTrap is ITrap {
    // This is a base contract that can be extended by other traps.
    // It can contain common functionality that is shared across all traps.
}
