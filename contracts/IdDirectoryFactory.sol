pragma solidity 0.4.18;


import "@aragon/os/contracts/factory/DAOFactory.sol";
import "@aragon/os/contracts/factory/AppProxyFactory.sol";

import "./IdDirectory.sol";
import "./Identity.sol";
import "./AridConstants.sol";


contract IdDirectoryFactory is DAOFactory, AppProxyFactory, AridConstants {

    IdDirectory idDirectoryBase;
    Identity identityBase;

    event DeployIdDirectory(IdDirectory idDirectory);

    function IdDirectoryFactory() public {
        idDirectoryBase = new IdDirectory();
        identityBase = new Identity();
    }

    function newIdDirectory(address directoryManager) public returns(IdDirectory) {
        Kernel dao = newDAO(this);
        ACL acl = ACL(dao.acl());


        bytes32 appManagerRole = dao.APP_MANAGER_ROLE();
        bytes32 permRole = acl.CREATE_PERMISSIONS_ROLE();

        acl.createPermission(this, dao, appManagerRole, this);

        IdDirectory idDirectory = IdDirectory(dao.newAppInstance(ID_DIRECTORY_APP_ID, idDirectoryBase));

        DeployIdDirectory(idDirectory);

        dao.setApp(dao.APP_BASES_NAMESPACE(), ID_IDENTITY_APP_ID, identityBase);

        acl.createPermission(directoryManager, idDirectory, idDirectory.DIRECTORY_MANAGER_ROLE(), directoryManager);
        acl.grantPermission(idDirectory, acl, permRole);

        // Remove permission of appManager to this and remove permission
        // it can always be created by directoryManager
        acl.revokePermission(this, dao, appManagerRole);
        acl.setPermissionManager(0x0, dao, appManagerRole);

        acl.grantPermission(directoryManager, acl, permRole);
        acl.revokePermission(this, acl, permRole);
        acl.setPermissionManager(directoryManager, acl, permRole);

        idDirectory.initialize();

        return idDirectory;

    }
}
