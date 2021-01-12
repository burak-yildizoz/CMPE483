loadScript("erc20tokenabi.js")
loadScript("bulottokenabi.js")

// change this to the address you deployed with web3 provider in remix
erc20address = "0xb7DbDD3dE04Da2221D6E240546d4f7C9B45c3f32"
bulotaddress = "0xfc115495Dc73d91EB465547e06B1AF8fbcFB2534"

erc20contract = web3.eth.contract(erc20tokenabi).at(erc20address);
bulotcontract = web3.eth.contract(bulottokenabi).at(bulotaddress);

ticketsOfPeople = {}

function createAccounts(howmany) {
    var numacc = eth.accounts.length - 1
    console.log("There are " + numacc + " accounts")
    var minbalance = 1000000000
    for (var i=1; i<=howmany; i++) {
        if (i > numacc) {
            personal.newAccount('')
            console.log("Created account " + i)
        }
        var balance = eth.getBalance(eth.accounts[i])
        if (balance < minbalance) {
            var sendvalue = minbalance - balance
            web3.eth.sendTransaction({from:eth.accounts[0],
                                      to:eth.accounts[i],
                                      value:sendvalue})
            console.log("Sent " + sendvalue + " to " + i)
        }
    }
}

function givePeopleMoneyToBuyTickets(howmany) {
    eth.defaultAccount = eth.accounts[0];
    for (i=1; i< howmany; i++) {
        erc20contract.transfer(eth.accounts[i], 10);
    }
}

function giveAllowance(howmany) {
    for (i=0; i< howmany; i++) {
        eth.defaultAccount=eth.accounts[i];
        web3.personal.unlockAccount(eth.accounts[i],'',10)
        erc20contract.approve(bulotaddress, 10);
    }
}

function buyTickets(howmany) {
    for (i=0; i< howmany; i++) {
        eth.defaultAccount=eth.accounts[i];
        web3.personal.unlockAccount(eth.accounts[i],'',10);
        thisTicketNo = bulotcontract.buyTicket(hash(i*3));
        ticketsOfPeople[eth.accounts[i]] = thisTicketNo;
    }
}

function hash(input) {
    return web3.sha3(input);
}

function sleep( sleepDuration ){
    var now = new Date().getTime();
    while(new Date().getTime() < now + sleepDuration){} 
}

function reveal(howmany) {
    for (i=0; i< howmany; i++) {
        eth.defaultAccount=eth.accounts[i];
        personal.unlockAccount(eth.accounts[i],'',10);
        bulotcontract.revealRndNumber.call(ticketsOfPeople[eth.accounts[i]], i*3);
    }
}

function getCurrentLotteryNo() {
    return bulotcontract.getCurrentLotteryNo.call();
}

function getLastBoughtTicketNo(lotteryNo) {
    return bulotcontract.getLastBoughtTicketNo.call(lotteryNo);
}

function checkIfTicketWon(lotteryNo, ticketNo) {
    return bulotcontract.checkIfTicketWon.call(lotteryNo, ticketNo);
}

function getMoneyCollected(lotteryNo) {
    return bulotcontract.getMoneyCollected.call(lotteryNo);
}

function getWinningTickets(moneyCollected, lotteryNo) {
    howManyDidWin = Math.ceil(Math.log(moneyCollected));
    winners = [];

    for (i=1; i <= howManyDidWin; i++) {
        var result = bulotcontract.getIthWinningTicket.call(i, lotteryNo);
        ticket_no = result[ticket_no];
        amount = result[amount];
        winners.push([ticket_no, amount]);
    }

    return winners;
}

/*
createAccounts(5);
console.log("Lottery no: " + getCurrentLotteryNo())
givePeopleMoneyToBuyTickets(5);
giveAllowance(5);
buyTickets(5);
lastTicketNo = getLastBoughtTicketNo(lotteryNo);
lotteryNo = getCurrentLotteryNo();
*/
checkIfTicketWon(lotteryNo, 4);
/*
moneyCollected = getMoneyCollected(lotteryNo);
sleep(600000);
reveal(5);
sleep(600000);
nextLotteryNo = getCurrentLotteryNo();
if(nextLotteryNo == lotteryNo + 1) console.log("next week"); else console.log("not working");
winners = getWinningTickets(moneyCollected, lotteryNo);
*/
//TODO : withdrawPrizes(lotteryNo, winners);

// use loadScript("bulot.js")
