pragma solidity 0.4.18;


interface IIdDirectory {
    function createIdentity(address identityOwner) public;
    function resetOwner(address identity, address newIdentityOwner) public;

    function addExecutor(address identity, address executor) public;
    function removeExecutor(address identity, address executor) public;
    function disableIdentity(address identoty) public;
}
