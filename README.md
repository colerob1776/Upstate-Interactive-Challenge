# Upstate-Interactive-Challenge

Tests:
TestToken.sol - used to test RestrictedTime modifier by deploying Tokens with different time windows
TokenEvent.test.js - used to test event emitted on successful transfer
Contribution.test.js - used for all tests on Contribution contract

Note:
I was not sure if the withdraw and deposit functions were supposed to account for gas costs. Since most real world Dapps that I have used return the remaining balance after gas fees, I did the same.

Thanks for sending the challenge. It was fun.