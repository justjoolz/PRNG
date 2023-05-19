import PRNG from "../cadence/contracts/PRNG.cdc"

pub fun main(): Bool {
    // Arrange
    let generator <- PRNG.create(seed: 4294967296)

    // Act
    let value = generator.generate()

    // Assert
    assert(value.isInstance(Type<UInt256>()))

    destroy generator
    return true
}
