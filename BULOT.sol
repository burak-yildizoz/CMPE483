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
    mapping(uint => mapping(uint => bool)) notrevealed;   // (lotteryno, ticketno) => redeemable (reveal etmeyen adam sonradan ödül de alamaz)
    mapping(uint => mapping(uint => bool)) notclaimed;    // (lotteryno, ticketno) => remunerable
    mapping(uint =>uint)  ticketcount;                              // (lotteryno)=> ticketcount  (number of tickets sold for lotteryno). Updated by buyTicket
    mapping(uint =>uint) moneycollected;
    mapping(uint =>uint) moneyreturned;
    uint totalmoneycollected;                //failsafe accounting variables
    uint totalmoneyreturned;

    // TODO: use events for logging https://github.com/ethchange/smart-exchange/blob/master/lib/contracts/SmartExchange.sol

    ////////////////////////////////////////////////////////////////////////////////
    // code                                                                       //
    ////////////////////////////////////////////////////////////////////////////////

    constructor                     (address TL_contract)               public
    {
        TL_BANK = IERC20(TL_contract);
    }

    fallback                        ()                                  external    // not payable
    {}

    // https://stackoverflow.com/questions/59651032/why-does-solidity-suggest-me-to-implement-a-receive-ether-function-when-i-have-a
    receive                         ()                                  external payable
    {
        require(false, "This is an automated contract. Do not giveaway!");
    }

    function buyTicket              (bytes32 hash_rnd_number)           payable public //returns (uint ticket_no)
    {
        // hash_rnd_number == keccak256(abi.encode(rnd_number))
        require(TL_BANK.transferFrom(msg.sender, address(this), 10)); //buna bir de exception handling lazım olabilir?
        uint lottery_no = getCurrentLotteryNo();
        moneycollected[lottery_no] += PRICE;
        totalmoneycollected += PRICE;
        ticket_no = ticketcount[lottery_no]; //ticketcount is used here to avoid exception from getLastBoughtTicketNo when ticketcount==0
        lastBoughtTicket[msg.sender] = ticket_no;
        ticketcount[lottery_no]++;
        hashes[lottery_no][ticket_no] = hash_rnd_number;
        ticketowner[lottery_no][ticket_no] = msg.sender;
        notrevealed[lottery_no][ticket_no] = true;
        notclaimed[lottery_no][ticket_no] = true;
    }

    function revealRndNumber        (uint ticket_no, uint rnd_number)    public
    {
        uint last_lottery_no = getCurrentLotteryNo() - 1;
        require(ticketowner[last_lottery_no][ticket_no] == msg.sender, "Only the ticket owner can perform this operation");
        require(notrevealed[last_lottery_no][ticket_no], "You have already revealed the ticket");
        require(keccak256(abi.encode(rnd_number)) == hashes[last_lottery_no][ticket_no], "Your random number is not correct!");
        notrevealed[last_lottery_no][ticket_no] = false;
        lotteryRandom[last_lottery_no] = keccak256(abi.encode(lotteryRandom[last_lottery_no], rnd_number));
    }

    function withdrawTicketPrize    (uint lottery_no, uint ticket_no)   public
    {
        require(lottery_no < getCurrentLotteryNo() - 1, "Rewards can be claimed after reveal stage ends");
        require(ticketowner[lottery_no][ticket_no] == msg.sender, "Only the ticket owner can claim reward");
        require(notrevealed[lottery_no][ticket_no] != true, "You did not reveal your random number. No rewards can be claimed!");
        require(notclaimed[lottery_no][ticket_no], "You have already claimed your reward");
        
        uint amount = checkIfTicketWon(lottery_no, ticket_no);
        require(amount > 0, "You didn't win this time");
        notclaimed[lottery_no][ticket_no] = false;
        require(TL_BANK.transfer(msg.sender, amount), "Transaction failed!");  //This function merits some form of fail-safe control(comparing accounts here and on erc20)
        moneyreturned[lottery_no] += amount;
        totalmoneyreturned += amount;
    }

    ////////////////////////////////////////////////////////////////////////////////
    // private                                                                    //
    ////////////////////////////////////////////////////////////////////////////////

    function currentWeek            ()                                  private view returns (uint)
    {
        return block.timestamp / /*SECONDS_PER_WEEK*/ (60*60*24*7);
    }

    ////////////////////////////////////////////////////////////////////////////////
    // view                                                                       //
    ////////////////////////////////////////////////////////////////////////////////

    function getLastBoughtTicketNo  (uint lottery_no)                   public view returns (uint)
    {
        ticket_no=lastBoughtTicket[msg.sender];
        require(ticketowner[lottery_no][ticket_no]==msg.sender,"No tickets bought yet.");
        return ticket_no;
    }

    function getIthBoughtTicketNo   (uint i, uint lottery_no)           public view returns (uint)
    {
        require(ticketowner[lottery_no][i] != address(0), "Ticket is not sold");
        return i;
    }

    function checkIfTicketWon       (uint lottery_no, uint ticket_no)   public view returns (uint amount)
    {
        require(lottery_no < getCurrentLotteryNo() - 1, "Tickets are rewarded after reveal stage ends");
        uint last_ticket_no = getLastBoughtTicketNo(lottery_no);
        require(ticket_no <= last_ticket_no, "Ticket is not sold");
        for (uint i = 1; 2**i <= ticketcount[lottery_no]*2; i++)
        {
            (uint ith_ticket_no, uint ith_amount) = getIthWinningTicket(i, lottery_no);
            if (ith_ticket_no == ticket_no)
                return ith_amount;
        }
        return 0;
    }

    function getIthWinningTicket    (uint i, uint lottery_no)           public view returns (uint ticket_no, uint amount)
    {
        require(lottery_no < getCurrentLotteryNo() - 1, "Tickets are rewarded after reveal stage ends");
        uint M = ticketcount[lottery_no];
        require(i > 0 && 2**i <= M, "Invalid reward number");
        amount = (M / 2**i) + ((M / 2**(i-1)) % 2);
        // disadvantage: does not check whether the ticket was revealed, in that case the money won't be rewarded to anyone
        // TODO: use the block after reveal stage for randomness https://docs.soliditylang.org/en/v0.6.0/units-and-global-variables.html
        ticket_no = uint(keccak256(abi.encode(lotteryRandom[lottery_no], i))) % M;
    }

    function getCurrentLotteryNo    ()                                  public view returns (uint lottery_no)
    {
        return currentWeek();
    }

    function getMoneyCollected      (uint lottery_no)                   public view returns (uint amount)
    {
        // TODO: award the remaining money from the last week that were not revealed ?
        return moneycollected[lottery_no];
    }
}

/*************HOCAYA SORULACAK SORULAR:***************
 * buyTicket() ticket_no return etmeli, değil mi?
 * storage'dan eski lotterylerin bilgilerini silmeli miyiz?                                     // eski lotterylerdeki ödülleri de sonradan alabilmeli onun için lottery_numberlar silinmemeli. hashleri silmek gerekebilir.
 * her haftanın lotosu için yeni contract mı deploy edilmeli, aynı contract mı kullanılmalı?    // muhtemelen aynı
 * fallback function implement edilmeli mi?
 * piyango sayısı reveal etmemiş birine vurabilir mi?
 */
