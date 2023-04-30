import PRNG from "../cadence/contracts/PRNG.cdc"

pub fun main(): Bool {
    // Arrange
    let generator <- PRNG.create(seed: 4294967296)

    // Act
    let value = generator.range(1, 6)

    // Assert
    assert(value >= 1 && value <= 6)

    destroy generator
    return true
}
