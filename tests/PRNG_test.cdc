import Test

pub var blockchain = Test.newEmulatorBlockchain()
pub var account = blockchain.createAccount()

pub fun setup() {
    blockchain.useConfiguration(Test.Configuration({
        "../cadence/contracts/PRNG.cdc": account.address
    }))

    let PRNG = Test.readFile("../cadence/contracts/PRNG.cdc")
    let err = blockchain.deployContract(
        name: "PRNG",
        code: PRNG,
        account: account,
        arguments: []
    )

    Test.assert(err == nil)
}

pub fun testRandomUFix64() {
    let returnedValue = executeScript("random_ufix64.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testRandomRange() {
    let returnedValue = executeScript("random_range.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testPickWeighted() {
    let returnedValue = executeScript("pick_weighted.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testBlockHeightSeed() {
    let returnedValue = executeScript("block_height_seed.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testGenerate() {
    let returnedValue = executeScript("generate.cdc")
    Test.assert(returnedValue, message: "found: false")
}

priv fun executeScript(_ scriptPath: String): Bool {
    var script = Test.readFile(scriptPath)
    let value = blockchain.executeScript(script, [])

    Test.assert(value.status == Test.ResultStatus.succeeded)

    return value.returnValue! as! Bool
}
