erc20abi = [
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_initialAmount",
                "type": "uint256"
            },
            {
                "internalType": "string",
                "name": "_tokenName",
                "type": "string"
            },
            {
                "internalType": "uint8",
                "name": "_decimalUnits",
                "type": "uint8"
            },
            {
                "internalType": "string",
                "name": "_tokenSymbol",
                "type": "string"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "address",
                "name": "",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "address",
                "name": "",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "Transfer",
        "type": "event"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_owner",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "_spender",
                "type": "address"
            }
        ],
        "name": "allowance",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "remaining",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "name": "allowed",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_spender",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_value",
                "type": "uint256"
            }
        ],
        "name": "approve",
        "outputs": [
            {
                "internalType": "bool",
                "name": "success",
                "type": "bool"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_owner",
                "type": "address"
            }
        ],
        "name": "balanceOf",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "balance",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "name": "balances",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "decimals",
        "outputs": [
            {
                "internalType": "uint8",
                "name": "",
                "type": "uint8"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "name",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "symbol",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "totalSupply",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_to",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_value",
                "type": "uint256"
            }
        ],
        "name": "transfer",
        "outputs": [
            {
                "internalType": "bool",
                "name": "success",
                "type": "bool"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_from",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "_to",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_value",
                "type": "uint256"
            }
        ],
        "name": "transferFrom",
        "outputs": [
            {
                "internalType": "bool",
                "name": "success",
                "type": "bool"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    }
]

bulotabi = [
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "TL_contract",
                "type": "address"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "stateMutability": "nonpayable",
        "type": "fallback"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "hash_rnd_number",
                "type": "bytes32"
            }
        ],
        "name": "buyTicket",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "ticket_no",
                "type": "uint256"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "lottery_no",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "ticket_no",
                "type": "uint256"
            }
        ],
        "name": "checkIfTicketWon",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getCurrentLotteryNo",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "lottery_no",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "i",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "lottery_no",
                "type": "uint256"
            }
        ],
        "name": "getIthBoughtTicketNo",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "i",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "lottery_no",
                "type": "uint256"
            }
        ],
        "name": "getIthWinningTicket",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "ticket_no",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "lottery_no",
                "type": "uint256"
            }
        ],
        "name": "getLastBoughtTicketNo",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "lottery_no",
                "type": "uint256"
            }
        ],
        "name": "getMoneyCollected",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "ticket_no",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "rnd_number",
                "type": "uint256"
            }
        ],
        "name": "revealRndNumber",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "lottery_no",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "ticket_no",
                "type": "uint256"
            }
        ],
        "name": "withdrawTicketPrize",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
]

erc20address = "0x5a4eBb10942cBf41154F13Ed16cFf57CDE116350"
// change this to the address you deployed with web3 provider in remix
bulotaddress = "0x0d3C830D9a79aC2C48290fe73af7039818FC6fe9"

var erc20contract = undefined
var bulotcontract = undefined

erc20contract = web3.eth.contract(erc20abi).at(erc20address);
bulotcontract = web3.eth.contract(bulotabi).at(bulotaddress);

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
