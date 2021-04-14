require('../node_modules/@openzeppelin/test-helpers/configure')({ web3 });


var Token = artifacts.require("./Token.sol");
var Contribution = artifacts.require("./Contribution.sol");
var MyDateLibrary = artifacts.require("./MyDateLibrary.sol");
var BokkyPooBahsDateTimeLibrary = artifacts.require("./BokkyPooBahsDateTimeLibrary.sol");

module.exports = function(deployer) {
  deployer.deploy(BokkyPooBahsDateTimeLibrary);
  deployer.link(BokkyPooBahsDateTimeLibrary, MyDateLibrary);
  deployer.deploy(MyDateLibrary);
  deployer.link(MyDateLibrary, Token);
  deployer.deploy(Token,0,24);
  deployer.deploy(Contribution)
};