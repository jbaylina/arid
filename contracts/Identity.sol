pragma solidity 0.4.18;

import "@aragon/os/contracts/apps/AragonApp.sol";

import "./AridConstants.sol";
import "./IIdDirectory.sol";

contract Identity is AragonApp, AridConstants {

    bytes32 constant public EXECUTE_ROLE = bytes32(1);

    event Forwarded (address indexed destination, uint value, bytes data);
    event Received (address indexed sender, uint value);

    function Identity() public {

    }

    function () public payable {
        Received(msg.sender, msg.value);
    }

    function forward(address destination, uint value, bytes data) public auth(EXECUTE_ROLE) {
        require(executeCall(destination, value, data));
        Forwarded(destination, value, data);
    }

    // copied from GnosisSafe
    // https://github.com/gnosis/gnosis-safe-contracts/blob/master/contracts/GnosisSafe.sol
    function executeCall(address to, uint256 value, bytes data) internal returns (bool success) {
        assembly {
            success := call(not(0), to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }

    function addExecutor(address newExecutor) public auth(EXECUTE_ROLE) {
        IIdDirectory d = IIdDirectory(kernel.getApp(ID_DIRECTORY_APP_ID));
        d.addExecutor(this, newExecutor);
    }

    function removeExecutor(address newExecutor) public auth(EXECUTE_ROLE) {
        IIdDirectory d = IIdDirectory(kernel.getApp(ID_DIRECTORY_APP_ID));
        d.removeExecutor(this, newExecutor);
    }

    function executeScript(bytes script, bytes input) public auth(EXECUTE_ROLE) {
        address[] memory blacklist = new address[](0);
        runScript(script, input, blacklist);
    }

}
