loadScript("erc20tokenabi.js")
loadScript("bulottokenabi.js")

erc20address = "0x5a4eBb10942cBf41154F13Ed16cFf57CDE116350"
// change this to the address you deployed with web3 provider in remix
bulotaddress = "0x0d3C830D9a79aC2C48290fe73af7039818FC6fe9"

var erc20contract = undefined
var bulotcontract = undefined

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

function giveAllowance(howmany) {
    for (i=0; i< howmany; i++) {
        eth.defaultAccount=eth.accounts[i];
        erc20contract.approve(bulotaddress,10);
    }
}

function buyTickets(howmany) {
    for (i=0; i< howmany; i++) {
        eth.defaultAccount=eth.accounts[i];
        thisTicketNo = bulotcontract.buyTicket(hash(i*3));
        ticketsOfPeople[eth.accounts[i]] = thisTicketNo;
    }
}

function hash(input) {
    return web3.utils.soliditySHA3(input)
}
/*
async function sleep(ms) {
    x = await new Promise(resolve => setTimeout(resolve, ms));
    return x;
}
*/
function reveal(howmany) {
    for (i=0; i< howmany; i++) {
        eth.defaultAccount=eth.accounts[i];
        personal.unlockAccount(eth.accounts[i],'',100);
        bulotcontract.revealRndNumber(ticketsOfPeople[eth.accounts[i]], i*3);
    }
}

function getCurrentLotteryNo() {
    return bulotcontract.getCurrentLotteryNo.call();
}

function getLastBoughtTicketNo(lotteryNo) {
    return bulotcontract.getLastBoughtTicketNo(lotteryNo);
}

function checkIfTicketWon(lotteryNo, ticketNo) {
    return bulotcontract.checkIfTicketWon(lotteryNo, ticketNo);
}

function getMoneyCollected(lotteryNo) {
    return bulotcontract.getMoneyCollected(lotteryNo);
}

function getWinningTickets(moneyCollected, lotteryNo) {
    howManyDidWin = Math.ceil(Math.log(moneyCollected));
    winners = [];

    for (i=1; i <= howManyDidWin; i++) {
        var result = bulotcontract.getIthWinningTicket.call(i, lotteryNo)
        [ticket_no, amount] = result
        winners.push([ticket_no, amount]);
    }

    return winners;
}

createAccounts(5);
console.log("Lottery no: " + getCurrentLotteryNo())
/*
giveAllowance(5);
buyTickets(5);
lotteryNo = getCurrentLotteryNo();
lastTicketNo = getLastBoughtTicketNo(lotteryNo);
checkIfTicketWon(lotteryNo, lastTicketNo);
moneyCollected = getMoneyCollected(lotteryNo);
sleep(1200000);
reveal(5);
sleep(1200000);
nextLotteryNo = getCurrentLotteryNo();
if(nextLotteryNo == lotteryNo + 1) console.log("next week"); else console.log("not working");
winners = getWinningTickets(moneyCollected, lotteryNo);
*/
//TODO : withdrawPrizes(lotteryNo, winners);

// use loadScript("bulot.js")
