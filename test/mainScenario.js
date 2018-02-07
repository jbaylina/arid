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
  let user2;

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
    user2 = accounts[3];
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

  it('should create an identity', async () => {
    const r = await idDirectory.createIdentity(user1, {from: directoryManager});
    const idAddr = r.events.NewIdentity.returnValues.identity;
    identity = new contracts.Identity(web3, idAddr);
    assert.ok(identity.$address);
  });

  it('should be possible to send eth to the identity', async () => {
    await web3.eth.sendTransaction({from: accounts[0], to: identity.$address, value: web3.utils.toWei("0.123"), gas: 2000000});
    const balance = await web3.eth.getBalance(identity.$address);
    assert.equal(0.123, web3.utils.fromWei(balance));
  });

  it('should be possible to send eth back', async () => {
    const tx = await identity.forward(accounts[0], web3.utils.toWei("0.011"), "0x", {from: user1, gas: 300000});
    assert.equal("0x01", tx.status)
    const balance = await web3.eth.getBalance(identity.$address);
    assert.equal(0.112, web3.utils.fromWei(balance));
  });

  it('should fail if some body else tries to do some thing', async() => {
    const tx = await identity.forward(accounts[0], web3.utils.toWei("0.011"), "0x", {from: user2, gas: 300000});
    assert.equal("0x00", tx.status)
  });

  it('a random person should not be able to create an identity ', async () => {
    const tx = await idDirectory.createIdentity(user2, {from: user2, gas: 3000000});
    assert.equal("0x00", tx.status)
  });

  it('should be possible to add another user to the identity', async () => {
    const tx = await identity.addExecutor(user2, {from: user1, gas: 200000});
    assert.equal("0x01", tx.status);
  });


});
