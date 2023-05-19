import PRNG from "../cadence/contracts/PRNG.cdc"

pub fun main(): Bool {
    // Arrange
    let generator <- PRNG.createFrom(
        blockHeight: 2,
        uuid: 726546,
    )

    // Act
    let value = generator.pickWeighted(
        ["heads", "tails"],
        [60, 40],
    ) as! String

    // Assert
    assert(value == "heads" || value == "tails")

    destroy generator
    return true
}
