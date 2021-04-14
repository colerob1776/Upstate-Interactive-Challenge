const { assert } = require("../node_modules/chai");
const BN = require('../node_modules/bn.js');
require('../node_modules/@openzeppelin/test-helpers/configure')({ web3 });

const Contribution = artifacts.require('./Contribution.sol');

const ONE = new BN('1000000000000000000'); //10^18 for wei conversion


contract('Contribution', (accounts) => {
    before(async () => {
        this.Contr = await Contribution.deployed();
    })

    it('init contribution', async() => {
        const Contr = await this.Contr;
        const name = await Contr.name();
        const symbol = await Contr.symbol();
        //assert ERC20 token created
        assert.equal(name, 'contribution', 'Token name does not match')
        assert.equal(symbol, 'CONT', 'Token symbol does not match')

    });

    /*Contribution deposit() function
        make sure ETH transactions are fulfilled by checking user and contract balanced before and after the function call
        make sure contribution contract storage variables are updated accordingly
    */
    it('deposit ETH', async() => {
        const Contr = await this.Contr;
        const contrAddress = await Contr.address;
        const donateAmount = new BN("1");

        //check ETH balance of user and contract before donation
        const preBalanceUser = await web3.eth.getBalance(accounts[0]);
        const preBalanceContr = await web3.eth.getBalance(contrAddress);

        //Donate 10 ETH
        const result = await Contr.donate({value: donateAmount.mul(ONE), from: accounts[0]})

        //check ETH balance of user and contract after donation
        const postBalanceUser = await web3.eth.getBalance(accounts[0]);
        const postBalanceContr = await web3.eth.getBalance(contrAddress);

        //assert user lost 10 ETH plus gas and contract gained 10 ETH
        const userDiff = preBalanceUser - postBalanceUser;
        const contrDiff = postBalanceContr - preBalanceContr;
        assert.equal((postBalanceContr - preBalanceContr)/(10**18), donateAmount.toNumber(), "transaction did not succeed")
        assert((preBalanceUser - postBalanceUser)/(10**18) > donateAmount.toNumber(), "transaction did not succeed")

        //assert user gained equivalent ERC20 tokens from contract
        const userTokenBalance = await Contr.balanceOf(accounts[0]);
        assert.equal(userTokenBalance.div(ONE).toNumber(), donateAmount.toNumber() , "user did not receive correct amount of ERC20 tokens")

        //assert contract stored user's value correctly
        const userValue = await Contr.balances(accounts[0]);
        assert.equal(userValue.div(ONE).toNumber(), donateAmount.toNumber())

        //assert totalSupply of tokens are updated (token 1:1 ration with wei deposited)
        const totalSupply = await Contr.totalSupply();
        assert.equal(totalSupply.div(ONE), donateAmount.toNumber(), "Token supply not updated")

        //assert "DonationSuccessful" Event
        const event = result.logs[0].args
        assert.equal(event.value/(10**18), donateAmount.toNumber());
        

    });

    /*Contribution withdraw() function
        make sure ETH transactions are fulfilled by checking user and contract balanced before and after the function call
        make sure contribution contract storage variables are updated accordingly
    */
    it('withdraw ETH', async() => {
        const Contr = await this.Contr;
        const contrAddress = await Contr.address;
        const donateAmount = new BN("1");

        //check ETH balance of user and contract before donation
        const preBalanceUser = await web3.eth.getBalance(accounts[0]);
        const preBalanceContr = await web3.eth.getBalance(contrAddress);

        //Donate 10 ETH
        const result = await Contr.withdraw(accounts[0])

        //check ETH balance of user and contract after donation
        const postBalanceUser = await web3.eth.getBalance(accounts[0]);
        const postBalanceContr = await web3.eth.getBalance(contrAddress);

        //assert user gained 10 ETH minus gas and contract lost 10 ETH
        const userDiff = postBalanceUser - preBalanceUser;
        const contrDiff = preBalanceContr - postBalanceContr;
        assert.equal((preBalanceContr - postBalanceContr)/(10**18), donateAmount.toNumber(), "transaction did not succeed")
        assert((postBalanceUser - preBalanceUser)/(10**18) < donateAmount.toNumber(), "transaction did not succeed")

        //assert user gained equivalent ERC20 tokens from contract
        const userTokenBalance = await Contr.balanceOf(accounts[0]);
        assert.equal(userTokenBalance.div(ONE).toNumber(), 0 , "ERC20 tokens were not burned")

        //assert contract stored user's value correctly
        const userValue = await Contr.balances(accounts[0]);
        assert.equal(userValue.div(ONE).toNumber(), 0, 'contract did not subtract users value')

        //assert "EtherWithdrawn" Event
        const event = result.logs[0].args
        assert.equal(event.value/(10**18), donateAmount.toNumber());

    });

})

