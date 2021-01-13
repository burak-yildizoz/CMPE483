# BULOT Ethereum-Based Decentralized Lottery System

https://github.com/burak-yildizoz/CMPE483/compare/ee68452d6a56...9c5bd2a4c01a

**Authors:**
* Muhammed Enes Toptaş @EnesToptas
* Burak Yıldızöz @burak-yildizoz
* Selman Berk Özkurt @SelmanB


# Requirements
The requirements and the interface are defined by the instructor of the course, Prof. Can Özturan. See the accompanying definition pdf for details.

## Tickets and Rewards

## Lottery Rounds

# Algorithm

## Lottery Logic
All the winning tickets are determined using entropy in a single master 256-bit random number for each lottery. This number will be referred to as the *lottery number*. The lottery number is used to calculate the winning ticket number for i'th prize for the lottery of that week. 

A ticket can win multiple prizes. A ticket can win a reward even if the ticket's random number was not revealed. That amount will not be recoverable by the ticket owner and be a profit to the house. 

### Degree of Randomness Needed
256 bit lottery number has enough entropy for only up to `2^16=65536` tickets. This is because there are 16 rewards for such a lottery and each reward needs information to select one of the tickets (ie. 16 bits of information). Total entropy to have a perfectly random lottery for this size is `16*16=256` bits. For larger lotteries, it is impossible to give perfectly random results using a lottery number of this size.

It is, however, possible to generate sufficiently random pseudorandom winning combinations when it is infeasible to determine the correlation between the outcomes. We accomplished this by using cryptographically secure hash functions to derive winning ticket numbers from the input lottery number. In this manner, it is computationally infeasible to determine any correlation in the winning tickets, as it would necessitate a computation in the same asymptotic order as explicit enumeration, which needs `2^256` enumerations.


### Outcome Calculation
As explained, we made use of cryptographic hash functions to calculate the winning tickets using what we call the lottery number. Specifically, we calculate  secondary pseudorandom numbers for each reward by hashing the lottery number concatenated with the reward index `i`. Then the resulting 256-bit number was written in modulo `M`, which is the number of tickets. This yields an index that can be used as the winning ticket number, when the tickets are numbered in the range `[0,M)`, which is the case in our system. The fact that this secondary random number used is 256 bits long ensures that the result of the modulo is homogeneously distributed as far as any practical application is concerned.

### Computation Cost Burden
See the relevant section for how the lottery number is calculated. This unified lottery number occupies ony one 256 bit integer per weekly lottery in the storage, saving gas. Gas cost of computing the reward won using the aforementioned technique is exerted on the sender of the ethereum transaction to collect the prize calcualated (see `withdrawTicketPrize`). There is no memoization of previously calculated values here, making the gas burden on first and last prize collectors equal. Users can save gas by calling the view functions to learn what prize they won beforehand, without having to spend gas even when they do not receive anything.

## Random Number Generation Logic
Random numbers from ticket buyers is combined to yield a master 256-bit random number we call the *lottery number* that will be used to determine lottery winners. How this number is generated is the topic of this section.

### Random Number Aggregation
Lottery participants are each asked to commit a secret random number by submitting its hash and then to reveal them to be used for generating the lottery number. The method used to aggregate these random numbers needs to be free of any possible manipulation exploiting any statistical relation between any submitted number and the final lottery number. We ensured there is no such vulnerability by updating the lottery number as the cryptographically hash of its concatenation with the revealed random number. After all such random number revelations upadting the lottery number, the lottery number at the end of the revelation period is used for calculating prizes after the revelation period.

### Trust and Incentive Considerations
Using secure hash functions ensures that even a single random number submitted to this aggregation ensures sufficient randomness in the resulting lottery number. Ability of all the participants to include randomness that is impossible to exploit by other parties assures senders of random number on the randomness of the resulting number. Revealing the number is incentivized by making it compulsory in order to receive a reward. Cost of revealing a random number is a lot less than the expected return from a fair lottery. 

In the scenario using only the supplied random numbers to generate the lottery number, the last entity to reveal a random number has an advantage to alter the result of the lottery for its benefit. This is because that entity knows what the lottery number, therefore the whole outcome of the lottery will be, and has a choice regarding whether to reveal its random number or not. The cost of not revealing a random number has the cost of losing any potential reward for its ticket. However, there could be another benefit to the revealer with the alternative lottery number through other tickets. This opportunity to partially decide the outcome reduces the legitimacy and will incentivize being the last revealer, creating network congestions in the end of the reveal period.

This problem can be solved by including an independent entropy source to the random number aggregation *after* all the revelations were made. The best candidate we can imagine is the hash of the first block mined following the reveal period. **This is not implemented in this version**. The downside of this approach is that it may slightly incentivize mining for entities willing to affect the outcomes. However, this is computationally very difficult and even if it is not, it is beneficial to incentivize mining for the overall functioning of the network.

### Ability to Alter the Result

### Computation Cost Burden


## Time Management

### 



# Code Documentation

## Core Functions


## View Functions

## Helper Functions


## Gas Usages

Function | Gas Usage
-------- | --------
asd | 345


# Deployment and Testing
