loadScript("erc20tokenabi.js")
loadScript("bulottokenabi.js")
loadScript("addresses.js")

erc20contract = web3.eth.contract(erc20tokenabi).at(erc20address);
bulotcontract = web3.eth.contract(bulottokenabi).at(bulotaddress);

ticketsOfPeople = {}

//creates accounts
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

//gives tl tokens to other accounts
function givePeopleMoneyToBuyTickets(howmany) {
    eth.defaultAccount = eth.accounts[0];
    for (i=1; i< howmany; i++) {
        erc20contract.transfer.sendTransaction(eth.accounts[i], 10);
    }
}

//allows bulot to use transferFrom
function giveAllowance(howmany) {
    for (i=1; i< howmany; i++) {
        eth.defaultAccount=eth.accounts[i];
        web3.personal.unlockAccount(eth.accounts[i],'',10)
        erc20contract.approve.sendTransaction(bulotaddress, 10);
    }
}

//buys tickets for accounts
function buyTickets(howmany) {
	curentLotteryNo = getCurrentLotteryNo();
    for (i=1; i< howmany; i++) {
        eth.defaultAccount=eth.accounts[i];
        web3.personal.unlockAccount(eth.accounts[i],'',10);
        bulotcontract.buyTicket.sendTransaction(hash(i*3));
        thisTicketNo = getLastBoughtTicketNo(curentLotteryNo);
        ticketsOfPeople[eth.accounts[i]] = thisTicketNo;
    }
}

//gets hash
function hash(input) {
    return bulotcontract.getHash.call(input);
}

//sleeps for a week (minute)
function sleep( sleepDuration ){
    var now = new Date().getTime();
    while(new Date().getTime() < now + sleepDuration){}
}

//reveals numbers
function reveal(howmany) {
    for (i=1; i< howmany; i++) {
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

//adds winning tickets and amounts to a array
function getWinningTickets(moneyCollected, lotteryNo) {
    howManyDidWin = Math.ceil(Math.log(moneyCollected)/Math.log(2));
    winners = [];

    for (i=1; i <= howManyDidWin; i++) {
        var result = bulotcontract.getIthWinningTicket.call(i, lotteryNo);
        ticket_no = result[0];
        amount = result[1];
        winners.push([ticket_no, amount]);
    }

    return winners;
}

//withdraws winning tickets
function withdrawPrizes(lotteryNo) {
	for (i=0; i < winners.length; i++){
    var ticketno = winners[i][0]
    // It seems like the number in uint object is accessed via
    // uintvar["c"]["0"]
    // check by using Object.keys(uintvar)
		winnerAccount = Object.keys(ticketsOfPeople).filter(function(key) { return ticketsOfPeople[key]["c"]["0"] === ticketno["c"]["0"] })[0];
    if (winnerAccount === undefined) { continue; }
		eth.defaultAccount = winnerAccount;
		personal.unlockAccount(winnerAccount, '', 10);
		bulotcontract.withdrawTicketPrize.sendTransaction(lotteryNo, winners[i][0]);
	}
}

// TEST BY COMMENTING OUT BELOW CALLS
// AND CALLING loadScript("bulot.js") IN GETH CONSOLE

// createAccounts(5);
// givePeopleMoneyToBuyTickets(5);
// lotteryNo = getCurrentLotteryNo();
// console.log("Lottery no: " + lotteryNo)
// giveAllowance(5);
// buyTickets(5);
// ithTicketNo = bulotcontract.getIthBoughtTicketNo.call(3, lotteryNo);
// moneyCollected = getMoneyCollected(lotteryNo);
  // timing is important here
  // to update block.timestamp, you can use givePeopleMoneyToBuyTickets
// sleep(1000*60);
// nextLotteryNo = getCurrentLotteryNo();
  //  Object.keys(lotteryNo) -> Object.keys(lotteryNo["c"])
// if(nextLotteryNo["c"]["0"] == lotteryNo["c"]["0"] + 1) console.log("next week"); else console.log("not working");
// reveal(5);
// sleep(1000*60);
// winners = getWinningTickets(moneyCollected, lotteryNo);
// withdrawPrizes(lotteryNo, winners);
