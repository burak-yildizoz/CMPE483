pragma solidity >=0.6.0 <0.7.0;
// SPDX-License-Identifier: AGPL-3.0-only

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC20/IERC20.sol";

contract BULOT
{
    ////////////////////////////////////////////////////////////////////////////////
    // data                                                                       //
    ////////////////////////////////////////////////////////////////////////////////

    IERC20 private TL_BANK;
    mapping(uint => mapping(uint => bytes32)) hashes;     // database for hash of random numbers stored:   first index: lottery_no, second index: ticket_no
    mapping(uint => bytes32) lotteryRandom;               // list for the random numbers calculated for each week's lottery
    mapping(uint => mapping(uint=> address)) ticketowner; // (lotteryno, ticketno) => owner   // to authenticate withdraw // we could make ticket_no unique to avoid some extra storage
    mapping(uint => mapping(uint => bool)) notrevealed;   // (lotteryno, ticketno) => redeemable (reveal etmeyen adam sonradan ödül de alamaz)
    mapping(uint => mapping(uint => bool)) notclaimed;    // (lotteryno, ticketno) => remunerable

    // TODO: use events for logging https://github.com/ethchange/smart-exchange/blob/master/lib/contracts/SmartExchange.sol
    // TODO: implement M counter variable for getLastBoughtTicket

    ////////////////////////////////////////////////////////////////////////////////
    // code                                                                       //
    ////////////////////////////////////////////////////////////////////////////////

    constructor                     (address TL_contract)               public
    {
        TL_BANK = IERC20(TL_contract);
    }

    //implement fallback (in case someone sends ethers to the contract)
    //The instructor may ask us to delete this
    fallback                        ()                                  external    // not payable
    {}

    // https://stackoverflow.com/questions/59651032/why-does-solidity-suggest-me-to-implement-a-receive-ether-function-when-i-have-a
    receive                         ()                                  external payable
    {
        require(false, "This is an automated contract. Do not giveaway!");
    }

    function buyTicket              (bytes32 hash_rnd_number)           payable public returns (uint ticket_no)
    {
        // hash_rnd_number == keccak256(abi.encode(rnd_number))
        require(TL_BANK.transferFrom(msg.sender, address(this), 1)); //buna bir de exception handling lazım olabilir?
        uint lottery_no = getCurrentLotteryNo();
        try this.getLastBoughtTicketNo(lottery_no) returns (uint last_ticket_no) {
            ticket_no = last_ticket_no + 1;
        } catch {
            ticket_no = 0;
        }
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

        // erc20'deki allowed olayına bakarak değiştirilebilir
        uint amount = checkIfTicketWon(lottery_no, ticket_no);
        require(amount > 0, "You didn't win this time");
        notclaimed[lottery_no][ticket_no] = false;
        require(TL_BANK.transfer(msg.sender, amount), "Transaction failed!");  //This function merits some form of fail-safe control
    }

    ////////////////////////////////////////////////////////////////////////////////
    // private                                                                    //
    ////////////////////////////////////////////////////////////////////////////////

    function currentWeek            ()                                  private view returns (uint)
    {
        return block.timestamp / /*SECONDS_PER_WEEK*/ (60*60*24*7);
    }

    // https://ethereum.stackexchange.com/questions/8086/logarithm-math-operation-in-solidity#30168
    /*function log_2                  (uint x)                            private pure returns (uint y)
    {
        assembly
        {
            let arg := x
            x := sub(x,1)
            x := or(x, div(x, 0x02))
            x := or(x, div(x, 0x04))
            x := or(x, div(x, 0x10))
            x := or(x, div(x, 0x100))
            x := or(x, div(x, 0x10000))
            x := or(x, div(x, 0x100000000))
            x := or(x, div(x, 0x10000000000000000))
            x := or(x, div(x, 0x100000000000000000000000000000000))
            x := add(x, 1)
            let m := mload(0x40)
            mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
            mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
            mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
            mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
            mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
            mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
            mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
            mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
            mstore(0x40, add(m, 0x100))
            let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
            let shift := 0x100000000000000000000000000000000000000000000000000000000000000
            let a := div(mul(x, magic), shift)
            y := div(mload(add(m,sub(255,a))), shift)
            y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
        }
    }*/

    ////////////////////////////////////////////////////////////////////////////////
    // view                                                                       //
    ////////////////////////////////////////////////////////////////////////////////

    function getLastBoughtTicketNo  (uint lottery_no)                   public view returns (uint)
    {
        uint i = 0;
        while (true)
        {
            if (ticketowner[lottery_no][i] == address(0))
                break;
            i++;
        }
        require(i != 0, "No ticket sold!");
        return i - 1;
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
        uint M = last_ticket_no + 1; //getMoneyCollected(lottery_no);
        //for (uint i = 1; i <= log_2(M) + 1; i++)
        for (uint i = 1; 2**i <= M*2; i++)
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
        uint M = getMoneyCollected(lottery_no);
        //require(i > 0 && i <= log_2(M), "Invalid reward number");
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
        // TODO: award the remaining money from the last week that were not revealed
        return getLastBoughtTicketNo(lottery_no) + 1;
    }
}

/*************HOCAYA SORULACAK SORULAR:***************
 * buyTicket() ticket_no return etmeli, değil mi?
 * storage'dan eski lotterylerin bilgilerini silmeli miyiz?                                     // eski lotterylerdeki ödülleri de sonradan alabilmeli onun için lottery_numberlar silinmemeli. hashleri silmek gerekebilir.
 * her haftanın lotosu için yeni contract mı deploy edilmeli, aynı contract mı kullanılmalı?    // muhtemelen aynı
 * fallback function implement edilmeli mi?
 * piyango sayısı reveal etmemiş birine vurabilir mi?
 */
