 /* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

const TestRPC = require('ganache-cli');
const Web3 = require('web3');
const chai = require('chai');
const contracts = require("../build/contracts.js");

const assert = chai.assert;
chai.use(require('chai-as-promised')).should();

describe('Test ArId', () => {
  let testrpc;
  let web3;
  let accounts;
  let idDirectoryFactory;
  let idDirectory;
  let identity;
  let directoryManager;
  let user1;

  before(async () => {
    testrpc = TestRPC.server({
      ws: true,
      gasLimit: 18800000,
      total_accounts: 10, // eslint-disable-line camelcase
    });
    testrpc.listen(8546, '127.0.0.1');

    web3 = new Web3('ws://localhost:8546');
    accounts = await web3.eth.getAccounts();
    directoryManager = accounts[1];
    user1 = accounts[2];
  });

  after( (done) => {
    setTimeout(() => {
      testrpc.close();
      done();
    }, 100);
  });

  it('should deploy Directory Factory', async () => {
    idDirectoryFactory = await contracts.IdDirectoryFactory.new(web3, {from: accounts[0], gas: 18800000});

    assert.ok(idDirectoryFactory.$address);

    const r = await idDirectoryFactory.newIdDirectory(directoryManager, {from: accounts[0], gas: 4000000});
    const idDirectoryAddr = r.events.DeployIdDirectory.returnValues.idDirectory;
    idDirectory = new contracts.IdDirectory(web3, idDirectoryAddr);
    assert.ok(idDirectory.$address);
  }).timeout(6000);
});
