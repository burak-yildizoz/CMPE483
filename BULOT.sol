//pragma solidity >=0.4.22 <0.7.0;
//import "./EIP20.sol";

contract BULOT{
    //.data 
    //EIP20 TL_BANK;
    //mapping(uint => mapping(uint => bytes32)) hashes;  //database for hash of random numbers stored:   first index= lottery_no, second index ticket_no 
    //mapping(uint => bytes32) lotterynumber             //list for the random numbers calculated for each week's lottery. //UPDATE TAVSİYESİ: her reveal ardından lotterynumber=sha3(lotterynumber,revealedrandom)
    //mapping(uint => mapping(uint=> address)) ticketowner// (lotteryno,ticketno)=>owner   //to authenticate withdraw //we could make ticket_no unique to avoid some extra storage
    //mapping(uint => mapping(uint => bool)) notrevealed    //(lotteryno,ticketno)=> redeemable (reveal etmeyen adam sonradan ödül de alamaz)
    
    //.code
    //implement constructor
    //implement fallback (in case someone sends ethers to the contract)
    // ? it may make sense to implement reward calculatro as a pure function //RANDOM TAVSİYESİ: i'nci ödülü kazanan ticket ID = sha3(lotterynumber,i) % M
    
    function buyTicket              (bytes32 hash_rnd_number)           public // returns (uint)
        // require(TL_BANK.transferFrom(msg.sender, address(this), 1)); //buna bir de exception handling lazım olabilir?
        
        
    function revealRndNumber        (uint ticketno, uint rnd_number)    public //zamanı kontrol etmeye gerek yok, zaten hash tutmaz o zaman.
        //require(sha3(rnd_number)==hashes[this.currentWeek()-1][ticketno]);   
        
    
    function withdrawTicketPrize    (uint lottery_no, uint ticket_no)   public   //eğer unique ticket_no kullanırsak ilk argümana gerek kalmayabilir.
        //require(ticketowner[lottery_no][ticket_no])
        //require(notrevealed[lottery_no][ticket_no])      //bu satır erc20'deki allowed olayına bakarak değiştirilebilir, ayrıca üstteki require içinde &&'lanabilir.
        //uint amount=this.checkIfTicketWon(lottery_no,ticket_no)
        //
        //  //burada notrevealed'dan lottery_no, ticket_no kısmı silinebilir. 
    
    /*function currentWeek () private returns (uint){
        return block.timestamp / SECONDS_PER_WEEK; //now \equiv block.timestamp
    }*/
    
    
    
    //.view
    function getLastBoughtTicketNo  (uint lottery_no)                   public view returns (uint)
    function getIthBoughtTicketNo   (uint i,uint lottery_no)            public view returns (uint)
    function checkIfTicketWon       (uint lottery_no, uint ticket_no)   public view returns (uint amount)
    function getIthWinningTicket    (uint i, uint ticket_no)            public view returns (uint ticket_no,uint amount)
    function getCurrentLotteryNo    ()                                  public view returns (uint lottery_no)
    function getMoneyCollected      (uint lottery_no)                   public view returns (uint amount)
    
}


/*************HOCAYA SORULACAK SORULAR:***************
 * buyTicket() ticket_no return etmeli, değil mi?
 * storage'dan eski lotterylerin bilgilerini silmeli miyiz?                                     //eski lotterylerdeki ödülleri de sonradan alabilmeli onun için lottery_numberlar silinmemeli. hashleri silmek gerekebilir. 
 * her haftanın lotosu için yeni contract mı deploy edilmeli, aynı contract mı kullanılmalı?    //muhtemelen aynı
 * getIthWinningTicket() fonksiyonunun ticket_no yerine lottery_no argüman alması lazım değil mi?
 * 
 * /
