pragma solidity 0.4.18;

contract AridConstants {
    // Cant have a regular APM appId because it is used to build APM
    bytes32 constant public ID_IDENTITY_APP_ID = keccak256("apm.aragon");
    bytes32 constant public ID_DIRECTORY_APP_ID = keccak256("repo.aragon");
}
