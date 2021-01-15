pragma solidity >=0.6.0 <0.7.0;
// SPDX-License-Identifier: AGPL-3.0-only

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC20/IERC20.sol";

contract BULOT
{
    ////////////////////////////////////////////////////////////////////////////////
    // data                                                                       //
    ////////////////////////////////////////////////////////////////////////////////

    IERC20 private TL_BANK;
    uint constant PRICE = 10;
    mapping(uint => mapping(uint => bytes32)) hashes;     // database for hash of random numbers stored:   first index: lottery_no, second index: ticket_no
    mapping(uint => bytes32) lotteryRandom;               // list for the random numbers calculated for each week's lottery
    mapping(uint => mapping(uint=> address)) ticketowner; // (lotteryno, ticketno) => owner   // to authenticate withdraw // we could make ticket_no unique to avoid some extra storage
    mapping(address => uint) lastBoughtTicket;            // owner => owner's last bought ticket no.  Set by buyTicket, read by getLastBoughtTicketNo
    mapping(uint => mapping(uint => bool)) notrevealed;   // (lotteryno, ticketno) => redeemable (those who do not reveal will not get a prize)
    mapping(uint => mapping(uint => bool)) notclaimed;    // (lotteryno, ticketno) => remunerable
    mapping(uint =>uint)  ticketcount;                              // (lotteryno)=> ticketcount  (number of tickets sold for lotteryno). Updated by buyTicket
    mapping(uint =>uint) moneycollected;
    mapping(uint =>uint) moneyreturned;
    uint totalmoneycollected;                //failsafe accounting variables
    uint totalmoneyreturned;


    ////////////////////////////////////////////////////////////////////////////////
    // code                                                                       //
    ////////////////////////////////////////////////////////////////////////////////

    constructor                     (address TL_contract)               public
    {
        TL_BANK = IERC20(TL_contract);
    }

    fallback                        ()                                  external    // not payable
    {}

    receive                         ()                                  external payable
    {
        require(false, "This is an automated contract. Do not giveaway!");
    }

    function buyTicket              (bytes32 hash_rnd_number)           payable public //returns (uint ticket_no)
    {
        require(TL_BANK.transferFrom(msg.sender, address(this), PRICE)); //First of all, make sure the cost is received to avout reentrance attacks 
        uint lottery_no = getCurrentLotteryNo();                         //View function is used to get the date instead of calculating to preserve abstraction
        moneycollected[lottery_no] += PRICE;                             //Update failsafe accounting variables
        totalmoneycollected += PRICE;                                    //Update failsafe accounting variables
        uint ticket_no = ticketcount[lottery_no];                        //Generate the ticket number for the ticket to be created
        lastBoughtTicket[msg.sender] = ticket_no;                        //Set the last bought ticket by the msg.sender to this new ticket
        ticketcount[lottery_no]++;                                       //Update the number of tickets sold at this very lottery
        hashes[lottery_no][ticket_no] = hash_rnd_number;                 //Record the hash supplied to authenticate future random number revelation
        ticketowner[lottery_no][ticket_no] = msg.sender;                 //Record the owner of this ticket to check before withdrawal
        notrevealed[lottery_no][ticket_no] = true;                       //Set the variables for checking eligibility for withdrawal in the future
        notclaimed[lottery_no][ticket_no] = true;
    }

    function revealRndNumber        (uint ticket_no, uint rnd_number)    public
    {
        uint last_lottery_no = getCurrentLotteryNo() - 1;
        require(ticketowner[last_lottery_no][ticket_no] == msg.sender, "Only the ticket owner can perform this operation");     //Authenticate the owner 
        require(notrevealed[last_lottery_no][ticket_no], "You have already revealed the ticket");                               //Avoid unnecessary redundant storage updates
        require(keccak256(abi.encode(rnd_number)) == hashes[last_lottery_no][ticket_no], "Your random number is not correct!"); //Authenticate the random number revealed using its previously supplied hash
        //We do not update anything before all checks are made
        notrevealed[last_lottery_no][ticket_no] = false;                                                                        //Update the state of having revealed
        lotteryRandom[last_lottery_no] = keccak256(abi.encode(lotteryRandom[last_lottery_no], rnd_number));                     //Update the lottery random number according to the technique described in documentation
    }

    function withdrawTicketPrize    (uint lottery_no, uint ticket_no)   public
    {
        require(lottery_no < getCurrentLotteryNo() - 1, "Rewards can be claimed after reveal stage ends");                       //Check whether the final lottery random number is found
        require(ticketowner[lottery_no][ticket_no] == msg.sender, "Only the ticket owner can claim reward");                     //Authenticate that entity willing to receive the price is who bought this ticket
        require(notrevealed[lottery_no][ticket_no] != true, "You did not reveal your random number. No rewards can be claimed!");
        require(notclaimed[lottery_no][ticket_no], "You have already claimed your reward");                                      //Check the eligibility to receive prize for this ticket. See documentation for details.
        //We do not do state update or transfers before all checks are made to avoid reentrancy attack        
        uint amount = checkIfTicketWon(lottery_no, ticket_no);                                                                   //The amount calculation logic is implemented *only* in that view function for code robustness and abstraction
        require(amount > 0, "You didn't win this time");                                                                         //Do not continue 
        notclaimed[lottery_no][ticket_no] = false;                                                                               //Disable ability of this ticket to do another withdraw to avoid reentrancy attacks
        require(TL_BANK.transfer(msg.sender, amount), "Transaction failed!");                                                    //
        moneyreturned[lottery_no] += amount;                                                                                     //Update auxiliary accounting records
        totalmoneyreturned += amount;
    }

    ////////////////////////////////////////////////////////////////////////////////
    // private                                                                    //
    ////////////////////////////////////////////////////////////////////////////////

    function currentWeek            ()                                  private view returns (uint)
    {
        return block.timestamp / (60*60*24*7);         //Divide Unix Epoch by the number of seconds per week. See documentation for details                                                         
    }

    ////////////////////////////////////////////////////////////////////////////////
    // view                                                                       //
    ////////////////////////////////////////////////////////////////////////////////

    function getLastBoughtTicketNo  (uint lottery_no)                   public view returns (uint)
    {
        uint ticket_no=lastBoughtTicket[msg.sender];                                        //The result was memoized, written by buyTicket. See documentation for details.
        require(ticketowner[lottery_no][ticket_no]==msg.sender,"No tickets bought yet.");   //To avoid returning default storage value of 0 in case no tickets were bought 
        return ticket_no;
    }

    function getIthBoughtTicketNo   (uint i, uint lottery_no)           public view returns (uint)
    {
        require(ticketowner[lottery_no][i] != address(0), "Ticket is not sold"); //Ticket owner structure is used to check whether that ticket is sold, saving storage.
        return i;                                                                //The ticket numbering scheme assigns i'th ticket with the number i, implemented in the buyTicket method
    }

    function checkIfTicketWon       (uint lottery_no, uint ticket_no)   public view returns (uint amount)
    {
        require(lottery_no < getCurrentLotteryNo() - 1, "Tickets are rewarded after reveal stage ends"); //Check if the final lottery random number is calculated ie. reveal stage is over.
        uint last_ticket_no = ticketcount[lottery_no]; 
        require(ticket_no <= last_ticket_no, "Ticket is not sold");                                      //Check if such a ticket exists at all. An arbitrary and high ticket number can be miscalculated to have won a prize otherwise.
        uint M = moneycollected[lottery_no];
        amount=0;                                                                                        //Amount will be the sum of all prizes won 
        for (uint i = 1; 2**i < M*2; i++)                                                                //Sum for all prizes
        {
            (uint ith_ticket_no, uint ith_amount) = getIthWinningTicket(i, lottery_no);
            if (ith_ticket_no == ticket_no){                                                             //Add only the prizes actually won by this ticket
                amount+=ith_amount;
            }
        }
    }

    function getIthWinningTicket    (uint i, uint lottery_no)           public view returns (uint ticket_no, uint amount)
    {
        require(lottery_no < getCurrentLotteryNo() - 1, "Tickets are rewarded after reveal stage ends");
        uint M = moneycollected[lottery_no];                                               //Number of tickets sold in that lottery will be used
        require(i > 0 && 2**i < M*2, "Invalid reward number");                           //Make sure there exists a reward i
        amount = (M / 2**i) + ((M / 2**(i-1)) % 2);                                     //The actual formula for reward of the i'th prize
        ticket_no = uint(keccak256(abi.encode(lotteryRandom[lottery_no], i))) % ticketcount[lottery_no];      //This is the winner calculation logic. See documentation for details.
    }

    function getCurrentLotteryNo    ()                                  public view returns (uint lottery_no)
    {
        return currentWeek();                                                           //Currently, the lotteries are indexed with the Unix Epoch week.
    }

    function getMoneyCollected      (uint lottery_no)                   public view returns (uint amount)
    {
        return moneycollected[lottery_no];                                              //Simply return the accounting function updated by buyTicket
    }
    
    function getHash                (uint rnd_number)                   external pure returns (bytes32)
    {
        return keccak256(abi.encode(rnd_number));                                       //To be used for clients to make the exact hash algorithm compatible
    }
}
