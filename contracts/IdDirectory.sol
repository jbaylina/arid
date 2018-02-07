pragma solidity 0.4.18;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/factory/AppProxyFactory.sol";
import "@aragon/os/contracts/acl/ACL.sol";

import "./AridConstants.sol";
import "./Identity.sol";
import "./IIdDirectory.sol";

contract IdDirectory is IIdDirectory, AragonApp, AppProxyFactory, AridConstants {

    bytes32 constant public DIRECTORY_MANAGER_ROLE = bytes32(1);


    modifier managerOrIdentity(address identity) {
        require( canPerform(msg.sender, DIRECTORY_MANAGER_ROLE, new uint256[](0)) ||
                msg.sender == identity ||
                canPerform(msg.sender, Identity(identity).EXECUTE_ROLE(), new uint256[](0)));
        _;
    }

    function initialize() onlyInit public {
        initialized();
    }


    function createIdentity(address identityOwner) public auth(DIRECTORY_MANAGER_ROLE) {
        Identity identity = Identity(newAppProxy(kernel, ID_IDENTITY_APP_ID));

        ACL acl = ACL(kernel.acl());

        acl.createPermission(identityOwner, address(identity), identity.EXECUTE_ROLE(), this);
    }

    function resetOwner(address identity, address newIdentityOwner) public managerOrIdentity(identity) {
        ACL acl = ACL(kernel.acl());

//        acl.revokeAll(identity, identity.EXECUTE_ROLE());
        acl.grantPermission(newIdentityOwner, identity, Identity(identity).EXECUTE_ROLE());
    }

    function addExecutor(address identity, address executor) public managerOrIdentity(identity) {
        ACL acl = ACL(kernel.acl());

        acl.grantPermission(executor, identity, Identity(identity).EXECUTE_ROLE());
    }

    function removeExecutor(address identity, address executor) public managerOrIdentity(identity) {
        ACL acl = ACL(kernel.acl());

        acl.revokePermission(executor, identity, Identity(identity).EXECUTE_ROLE());
    }

    function disableIdentity(address identoty) public auth(DIRECTORY_MANAGER_ROLE) {
        ACL acl = ACL(kernel.acl());

//        acl.revokeAll(identity, Identity(identity).EXECUTE_ROLE());
    }
}
