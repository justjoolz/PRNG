import PRNG from "../cadence/contracts/PRNG.cdc"

pub fun main(): Bool {
    // Arrange
    let generator <- PRNG.create(seed: 4294967296)

    // Act
    let value = generator.ufix64()

    // Assert
    assert(value >= 0.0 && value <= 1.0)

    destroy generator
    return true
}
