# BULOT Ethereum-Based Decentralized Lottery System

**Authors:**
* Muhammed Enes Toptaş [@EnesToptas](https://github.com/EnesToptas)
* Burak Yıldızöz [@burak-yildizoz](https://github.com/burak-yildizoz)
* Selman Berk Özkurt [@SelmanB](https://github.com/SelmanB)

# Requirements
This is one of the projects for the course CMPE483 of the Boğaziçi University. The requirements and the interface are defined by the instructor of the course, Prof. Can Özturan.

The back end code is written in Solidity language and is intended for deployment to any Ethereum-based network. Some web3 programs are also supplied as reference front ends and for testing the functionality.


## Tickets and Rewards
Some virtual lottery tickets are bought with a fixed price of 10 ERC20 tokens. Which token is used depends on the specific deployment of the lottery system. We assume during testing that it is a Turkish Lira token.

For any weekly lottery with money collected `M` , there are `ceil(log2(M))` distinct prizes each with value `floor(M/2^i)+mod(floor(2^(i-1)),2)` for prize number `i`. As an example, consider a lottery with 100 participants and correspondingly 1000 tokens collected and 10 prizes:

Prize Number | Prize Value
--------- | ----------
1|500
2|250
3|125
4|63
5|31
6|16
7|8
8|4
9|2
10|1


## Lottery Rounds
Lottery is held weekly. Every week's lottery has an index. The current index can be freely learnt using `getCurrentLotteryNo()` method. 

Every such lottery has two stages that take one week each. In the first phase, users can buy lottery ticket by depositing the necessary amount of tokens. In addition, they must pick a random number to be used for the fair lottery logic. While buying the ticket, they must commit to this random number by supplying its SHA3 hash. They can keep their random number secret until all tickets are sold.

In the second phase, the users are asked to reveal their random numbers. If they fail to supply the system with this information on time, they will lose their chance of claiming a reward.

After this phase ends, all the results will be apparent on the blockchain and the ticket owners can check the results and claim their rewards given they did reveal their random number at stage two. The users can claim their rewards even after a lot of time.

It should be noted that in this particular implementation, the weeks begin at the Greenwich midnight between every wednesday and thursday.


## Interface
Aformementioned actions of buying a ticket, revealing the number number and withdrawing the prize are accomplished using solidity methods with following footprints:
`function buyTicket (bytes32 hash_rnd_number) payable public`
`function revealRndNumber (uint ticket_no, uint rnd_number) public`
`function withdrawTicketPrize (uint lottery_no, uint ticket_no)   public`
In addition, users need to retrieve some information from the lottery system like the ticket number of a ticket they just bought. For that purpose, they can use the view functions with these footprints:
`function getLastBoughtTicketNo(uint lottery_no) public view returns(uint)`
`function getIthBoughtTicketNo(uint i,uint lottery_no) public view returns(uint)`
`function checkIfTicketWon(uint lottery_no, uint ticket_no) public view returns (uint amount)`
`function getIthWinningTicket(uint i, uint lottery_no) public view returns (uint ticket_no,uint amount)`
`function getCurrentLotteryNo() public view returns (uint lottery_no)`
`function getMoneyCollected(uint lottery_no) public view returns (uint amount)`


# Algorithm

## Lottery Logic
All the winning tickets are determined using entropy in a single master 256-bit random number for each lottery. This number will be referred to as the *lottery random number*. The lottery random number is used to calculate the winning ticket number for i'th prize for the lottery of that week. 

A ticket can win multiple prizes, making the lottery more exciting. A ticket can be assigned a reward even if the ticket's random number was not revealed. That amount will not be recoverable by the ticket owner and will be a profit for the house. It could be implemented in some other way allowing the prizes to be assigned only to the tickets that have been revealed. When it is done so, expected net revenue will become higher than zero for participants that revealed their random numbers in case some participants do not. This kind of an implementation may encourage the lottery participants to try to avoid revelations of each other, creating a potential real-life security threat. In larger stakes owned by smaller number of entities, this may even include serious criminal activities.

### Degree of Randomness Needed
256 bit lottery random number has enough entropy for only up to `2^16=65536` tickets. This is because there are 16 rewards for such a lottery and each reward needs information to select one of the tickets (ie. 16 bits of information). Total entropy to have a perfectly random lottery for this size is `16*16=256` bits. For larger lotteries, it is impossible to give perfectly random results using a lottery random number of this size.

It is, however, possible to generate sufficiently random pseudorandom winning combinations when it is infeasible to determine the correlation between the outcomes. We accomplished this by using cryptographically secure hash functions to derive winning ticket numbers from the input lottery random number. In this manner, it is computationally infeasible to determine any correlation in the winning tickets, as it would necessitate a computation in the same asymptotic order as explicit enumeration, which needs `2^256` enumerations.


### Outcome Calculation
As explained, we made use of cryptographic hash functions to calculate the winning tickets using what we call the lottery random number. Specifically, we calculate  secondary pseudorandom numbers for each reward by hashing the lottery random number concatenated with the reward index `i`. Then the resulting 256-bit number was written in modulo `M`, which is the number of tickets. This yields an index that can be used as the winning ticket number, when the tickets are numbered in the range `[0,M)`, which is the case in our system. The fact that this secondary random number used is 256 bits long ensures that the result of the modulo is homogeneously distributed as far as any practical application is concerned.

### Computation Cost Burden
See the relevant section for how the lottery random number is calculated. This unified lottery random number occupies ony one 256 bit integer per weekly lottery in the storage, saving gas. Gas cost of computing the reward won using the aforementioned technique is exerted on the sender of the ethereum transaction to collect the prize calcualated (see `withdrawTicketPrize`). There is no memoization of previously calculated values here, making the gas burden on first and last prize collectors equal. Users can save gas by calling the view functions to learn what prize they won beforehand, without having to spend gas even when they do not receive anything.

## Random Number Generation Logic
Random numbers from ticket buyers is combined to yield a master 256-bit random number we call the *lottery random number* that will be used to determine lottery winners. How this number is generated is the topic of this section.

### Random Number Aggregation
Lottery participants are each asked to commit a secret random number by submitting its hash and then to reveal them to be used for generating the lottery random number. The method used to aggregate these random numbers needs to be free of any possible manipulation exploiting any statistical relation between any submitted number and the final lottery random number. We ensured there is no such vulnerability by updating the lottery random number as the cryptographically hash of its concatenation with the revealed random number. After all such random number revelations upadting the lottery random number, the lottery random number at the end of the revelation period is used for calculating prizes after the revelation period.

### Trust and Incentive Considerations
Using secure hash functions ensures that even a single random number submitted to this aggregation ensures sufficient randomness in the resulting lottery random number. Ability of all the participants to include randomness that is impossible to exploit by other parties assures senders of random number on the randomness of the resulting number. Revealing the number is incentivized by making it compulsory in order to receive a reward. Cost of revealing a random number is a lot less than the expected return from a fair lottery. 

In the scenario using only the supplied random numbers to generate the lottery random number, the last entity to reveal a random number has an advantage to alter the result of the lottery for its benefit. This is because that entity knows what the lottery random number, therefore the whole outcome of the lottery will be, and has a choice regarding whether to reveal its random number or not. The cost of not revealing a random number has the cost of losing any potential reward for its ticket. However, there could be another benefit to the revealer with the alternative lottery random number through other tickets. This opportunity to partially decide the outcome reduces the legitimacy and will incentivize being the last revealer, creating network congestions in the end of the reveal period.

This problem can be solved by including an independent entropy source to the random number aggregation *after* all the revelations were made. The best candidate we can imagine is the hash of the first block mined following the reveal period. **This is not implemented in this version**. The downside of this approach is that it may slightly incentivize mining for entities willing to affect the outcomes. However, this is computationally very difficult and even if it is not, it is beneficial to incentivize mining for the overall functioning of the network.

### Ability to Alter the Result
Because a cryptographically secure hash function is used at every step of generating the lottery random number, it is extremely difficult to 

The contribution by all participants to lottery random number generation is previously fixed by their commitments of random number hashes to the blockchain. Only decision of the participants potentially affecting the outcome is the decision of whether to reveal the random number and when. The implications of this is discussed in detail in the previous section.
 

### Computation Cost Burden
Every random number commit (in `buyTicket`) and reveal (in `revealRndNumber`) have the same gas cost and this cost is inflicted on all participants equally.

## Time Management

Calls to the core functions for buying and revealing some random numbers for a given lottery is related to the time these functions are called, which determines the relevant lottery. 

The current week index can be learnt using `getCurrentLotteryNo()` view function without spending any gas. The lottery week indices are determined simply by integer division of the Unix Epoch of the last block mined(`block.timestamp`) by number of seconds in a week. This results in lottery rounds starting at around midnight between every wednesday and thursday UTC. The index of a lottery is given by the week number of the ticket buying stage calculated this way.

# Code Documentation

## Storage Variables

* `mapping(uint => mapping(uint => bytes32)) hashes;`
Holds the random number hashes submitted while buying tickets. The first index refers to the lottery index for the list. The second index is the ticket number associated with that random number to be submitted.

* `mapping(uint => bytes32) lotteryRandom;`
Holds the combined *Lottery random number* as described in the algorithm section of the document. One such number exists for every lottery and the index in this structure is the lottery index.

* `mapping(uint => mapping(uint=> address)) ticketowner;`
Holds the addresses of the owners of the tickets bought on each lottery. The first index is the lottery index, and the second index is the ticket number. This is used to check the authenticity of any reward withdraw request.

* `mapping(address => uint) lastBoughtTicket`
This function holds the ticket last bought by a given address, regardless of the lottery, the index being the ticket owner's address. It is updated by `buyTicket` and used as the return value for the function `getLastBoughtTicketNo`.

* `mapping(uint => mapping(uint => bool)) notrevealed;`
This is used to determine whether the random number associated with a given ticket was revealed. The first index is the lottery index and the second index is the ticket number. It is used to determine whether it is possible for a possible prize for any ticket is redeemable, together with `notclaimed`.

* `mapping(uint => mapping(uint => bool)) notclaimed;`
This is used to record whether a won prize amount was withdrawn. The first index is the lottery index and the second is the ticket number. It is used in conjuction with `notrevealed` to determine possibility of redeeming a prize.

* `mapping(uint =>uint)  ticketcount;`
This records the number of tickets sold for any lottery. The index is the lottery index.

* `mapping(uint =>uint) moneycollected;` and `mapping(uint =>uint) moneyreturned;`
These are accounting variables to be used for possible failsafe security mechanisms. First indices are the lottery indices and the variables held are tokens collected and returned for each lottery, respectively. In addition, the specification calls for implementing a view interface to get the money collected.

* `uint totalmoneycollected;` and `uint totalmoneyreturned;`
These are also possible failsafe accounting variables similar to the `moneycollected` and `moneyreturned` structures. The main difference is that the `totalmoneycollected` and `totalmoneyreturned` record sums of all of the lotteries.


## Core Functions

* `function buyTicket (bytes32 hash_rnd_number) payable public`
Implements the functionality for buying ticket as shouşd be done by the participants during the first week of a lottery. It tries to receive necessary amount of ERC20 tokens 


* `function revealRndNumber (uint ticket_no, uint rnd_number) public`
Implements the second week's functionality. Checks if the random number is the one whose hash was committed. Records that the ticket owner may be eligible for collecting a prize if won. Also includes the logic for updating the lottery random number for that week.

* `function withdrawTicketPrize (uint lottery_no, uint ticket_no)   public`
Implements the latter part of the lottery cycle. The users can redeem the prize won by a ticket. The function is careful in its prevention of reentrance attacks.


## View Functions

* `function getLastBoughtTicketNo(uint lottery_no) public view returns(uint)`
Returns the last ticket bought by the `msg.sender` of the call. Returns the result from storage. Its result is recorded by `buyTicket` method.

* `function getIthBoughtTicketNo(uint i,uint lottery_no) public view returns(uint)`
Returns the ticket number of the i'th ticket in a given lottery regardless of the buyer. Checks the range of `i` to avoid future bugs.

* `function checkIfTicketWon(uint lottery_no, uint ticket_no) public view returns (uint amount)`
Scans all the prizes and sums all the prizes, if there is any, won. Uses `getIthWinningTicket` to check whether it is won. Spends gas only when withdrawing the prize, therefore it is not a problem that the complexity is high for this function.


* `function getIthWinningTicket(uint i, uint lottery_no) public view returns (uint ticket_no,uint amount)`
Uses the lottery random number, the prize index `i` and the number of tickets to calculate the ticket number of the winning ticket for this prize, using the algorithm specified in the related section.


* `function getCurrentLotteryNo() public view returns (uint lottery_no)`
The lottery index depends on the current time. This implementation uses the helper function `currentweek` to determine this number. As per the association, the current lottery, in the time sense, is defined as the lottery currently selling tickets.


* `function getMoneyCollected(uint lottery_no) public view returns (uint amount)`
Returns the amount of money collected by selling tickets in the specified lottery index. Is also used to determine the prizes through the specified formulae.


## Helper Functions


* `function currentweek () private view returns (uint)`
Gives the current lottery week number by dividing Unix Epoch timestamp of the last block mined by the number of seconds per week. This index increments roughly in the midnights between wednesdays and thursdays.

* `function getHash (uint rnd_number) external pure returns (bytes32)`
This is to be used by the clients, particularly our tester code, without spending any gas, to be able to encode their random number in the exact same format necessary for comparing in the contract. No other function in the contract use this.


## Miscellaneous Functions
* `constructor (address TL_contract) public`


* `fallback () external`


* `receive () external payable`


## Gas Usages

Function | Gas Usage
-------- | --------
getCurrentLotteryNo | execution: 273
getMoneyCollected | execution: 1178
getIthBoughtTicketNo | execution: 1421
getIthWinningTicket | execution: infinite
getLastBoughtTicketNo | execution: 2313
checkIfTicketWon | execution: infinite
buyTicket | execution: 167352
revealRndNumber | execution: infinite
withdrawTicketPrize | execution: infinite



# Deployment and Testing

We used remix.ethereum.org to deploy and then test the contract. First we deploy an IERC20 contract, for that we used the code our instructor shared via Piazza. Then we give that contract's address to BULOT contract's constructor and deploy it.

To test we created bulot.js, and implemented some auxiliary functions that called our contract's functions. In this test, we first create accounts if we don't have already. Then we send these accounts TL tokens, and approve our BULOT smart contract to make transfers on behalf of those accounts. Then we buy ticket and wait, normally this wait would be one week, but since this is merely a test and we have a limited time, we changed the week interval to a minute on the smart contract's code, so we wait a minute and then we reveal the numbers. After that reveal, we again wait another minute for this reveal stage to end, and when it ends, we call various functions of BULOT smart contract, to see whether they work as intended. Finally, we withdraw the money.
