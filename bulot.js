loadScript("erc20tokenabi.js")
loadScript("bulottokenabi.js")

// change this to the address you deployed with web3 provider in remix
erc20address = "0x68F4A697De25A8Aa688fC582BE671571c4F40cB1"
bulotaddress = "0xf8e81D47203A594245E36C48e151709F0C19fBe8"

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
        erc20contract.transfer.sendTransaction(eth.accounts[i], 10);
    }
}

function giveAllowance(howmany) {
    for (i=0; i< howmany; i++) {
        eth.defaultAccount=eth.accounts[i];
        web3.personal.unlockAccount(eth.accounts[i],'',10)
        erc20contract.approve.sendTransaction(bulotaddress, 10);
    }
}

function buyTickets(howmany) {
	curentLotteryNo = getCurrentLotteryNo();
    for (i=0; i< howmany; i++) {
        eth.defaultAccount=eth.accounts[i];
        web3.personal.unlockAccount(eth.accounts[i],'',10);
        bulotcontract.buyTicket.sendTransaction(hash(i*3));
        sleep(5000);
        thisTicketNo = getLastBoughtTicketNo(curentLotteryNo);
        ticketsOfPeople[eth.accounts[i]] = thisTicketNo;
    }
}

function hash(input) {
    return bulotcontract.getHash.call(input);
}

function sleep( sleepDuration ){
    var now = new Date().getTime();
    while(new Date().getTime() < now + sleepDuration){} 
}

function reveal(howmany) {
    for (i=0; i< howmany; i++) {
        eth.defaultAccount=eth.accounts[i];
        personal.unlockAccount(eth.accounts[i], '', 10);
        bulotcontract.revealRndNumber.sendTransaction(ticketsOfPeople[eth.accounts[i]], i*3);
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

function withdrawPrizes(lotteryNo) {
	for (i=0; i <= winners.length; i++){
		winnerAccount = Object.keys(ticketsOfPeople).find(function (key){ticketsOfPeople[key] === winners[i][0]});
		eth.defaultAccount = winnerAccount;
		personal.unlockAccount(winnerAccount, '', 10);
		bulotcontract.withdrawTicketPrize.sendTransaction(lotteryNo, winners[i][0]);
	}
}

// TEST BY COMMENTING OUT BELOW CALLS
// AND CALLING loadScript("bulot.js") IN GETH CONSOLE

// createAccounts(5);
// lotteryNo = getCurrentLotteryNo();
// console.log("Lottery no: " + lotteryNo)
// givePeopleMoneyToBuyTickets(5);
// giveAllowance(5);
// buyTickets(5);
// ithTicketNo = bulotcontract.getIthBoughtTicketNo.call(3, lotteryNo);
// moneyCollected = getMoneyCollected(lotteryNo);
// sleep(600000);
// reveal(5);
// sleep(600000);
// nextLotteryNo = getCurrentLotteryNo();
// if(nextLotteryNo == lotteryNo + 1) console.log("next week"); else console.log("not working");
// winners = getWinningTickets(moneyCollected, lotteryNo);
// withdrawPrizes(lotteryNo, winners);
