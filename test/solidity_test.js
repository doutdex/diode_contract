// Diode Contracts
// Copyright 2019 IoT Blockchain Technology Corporation LLC (IBTC)
// Licensed under the Diode License, Version 1.0
const path = require('path');
const fs = require('fs');

let items = fs.readdirSync("./test");
for (let i = 0; i < items.length; i++) {
    if (items[i].endsWith("_test.sol")) {
        doTest(items[i]);
    }
}

function doTest(filename) {
    let name = path.basename(filename)
    // Cutting '_test.sol' and appending 'Test'
    // Eg. turning 'BNS_test.sol' into 'BNSTest' 
    let contractName = name.substr(0, name.length - 9) + 'Test';
    let Contract = artifacts.require(contractName);
    let methods = [];
    Contract.abi.forEach(function (item) {
        if (item.type != "function") {
            return;
        }

        if (item.name.startsWith("check")) {
            methods.push(item.name)
        }
    });

    contract(contractName, async function (accounts) {
        let instance;
        it("initialize contract", async () => {
            instance = await Contract.new({ from: accounts[0], gasLimit: 4000000 });
        })

        methods.forEach(function (name) {
            it(name, async () => {
                await instance[name]();
            })
        })
    });
}
