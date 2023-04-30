import PRNG from "../cadence/contracts/PRNG.cdc"

pub fun main(): Bool {
    // Arrange
    let generator <- PRNG.create(seed: 4294967296)

    // Act
    let value = generator.pickWeighted(
        ["heads", "tails"],
        [70, 30],
    ) as! String

    // Assert
    assert(value == "heads" || value == "tails")

    destroy generator
    return true
}
