# Starknet DAO ZKX Medium Challenge - Aira
See our solution for the easy challenge [here](https://github.com/andykamin3/zkx-challenge-easy)
## Introduction
The objective was to build a DAO voting contract. Using this contract a DAO could create and vote on proposals with ease. The usage of ERC20 token balances with the option to use quadratic voting before deployment makes it a very enticing option for both new and established DAOs. 
## Technical Overview
Using the `init_poll` function the user is able to create a poll. They are able to close it afterwards using the `finalize_poll` function. During the poll users can call the `vote` function to vote. There are several variables to correctly count the votes as well as preventing double voting. 
While Cairo's support for strings is limited we were able to store an IPFS url associated with each poll in order for users to be able to vote on the content of the proposal itself without relying on a centralized service to store the content and/or relay it to them. 
## Challenges
We faced a handful of technical challenges that limited our implementation. Namely:
 1. The lack of an ERC20Vote contract written for Cairo. We tried to build one but didn't manage to finish it before the deadline. Check the `andy` branch for the currrent code.
 2. The lack of standarization of the `getBlockTimestamp()` function for validators means that we could not reliably use it to provide deadline for a proposal and remove the proposer's intervention.
