const { assert } = require("chai");
const BN = require('bn.js');
require('@openzeppelin/test-helpers/configure')({ web3 });

const Token = artifacts.require('./Token.sol');

const ONE = new BN('1000000000000000000'); //10^18 for wei conversion


contract('Token', (accounts) => {
    before(async () => {
        this.Token = await Token.deployed();
    })

    it('should return event on successful transfer', async() => {
        const Token = await this.Token;
        const tokenAddress = await Token.address;
        const startTime = await Token.startTime();
        const endTime = await Token.endTime();

        //assert Token was deployed with 24 hour time window
        assert.equal(startTime.toNumber(), 0);
        assert.equal(endTime.toNumber(), 86400);

        //tranfer 1 coin
        const transferAmount = new BN("1");
        const result = await Token.transfer(tokenAddress, transferAmount.mul(ONE));
        
        //assert TokenTransferred event
        const event = result.logs[0].args;
        assert.equal(event.value/(10**18), transferAmount.toNumber(), "TokenTransferred event result does not equal transfer amount")
    })
})