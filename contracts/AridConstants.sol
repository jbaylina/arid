pragma solidity 0.4.18;

import "@aragon/os/contracts/kernel/KernelStorage.sol";

contract AridConstants is KernelConstants {
    bytes32 constant public ID_IDENTITY_APP_ID = keccak256("identity.aragon");

    bytes32 constant public ID_DIRECTORY_APP_ID = keccak256("iddirectory.aragon");
    bytes32 constant public ID_DIRECTORY_APP = keccak256(APP_ADDR_NAMESPACE, ID_DIRECTORY_APP_ID);
}
