/// PRNG - A Pseudo-Random Number Generator
///
/// Usage:
///     // Creates a random number generator resource that provides functions for generating a stream of random numbers
///     let myPRNG = PRNG.create(seed: 4294967296)
///     // Creates a random number generator resource seeded with a block height and uuid of a resource
///     let myPRNG = PRNG.createFrom(blockHeight: 2121, uuid: 726546)
///     // Generates a random UFix64 number between 0 and 1
///     myPRNG.ufix64()
///     // Dice roll
///     myPRNG.range(1, 6)
///     // Picks one of the weighted given choices
///     myPRNG.pickWeighted(["heads", "tails"], [60, 40])

pub contract PRNG {

    pub resource Generator {
        access(self) var seed: UInt128
        
        init (seed: UInt128) {
            self.seed = seed
            // create some inital entropy
            self.g()
            self.g()
            self.g()
        }

        pub fun generate(): UInt128 { 
            return self.g() 
        }

        pub fun g(): UInt128 {
            self.seed = PRNG.random(seed: self.seed)
            return self.seed
        }

        pub fun ufix64(): UFix64 {
            let s: UInt128 = self.g()
            return UFix64((UFix64(s)) / 9999999999.0)
        }

        pub fun range(_ min :UInt128, _ max: UInt128): UInt128 {
            return min + (self.g() % (max - min+ 1))
        }

        pub fun pickWeighted(_ choices: [AnyStruct], _ weights: [UInt128]): AnyStruct {
            var weightsRange: [UInt128] = []
            var totalWeight: UInt128 = 0     
            for weight in weights {
                totalWeight = totalWeight + weight
                weightsRange.append(totalWeight)
            }
            let p = self.g() % totalWeight
            var lastWeight: UInt128 = 0

            for i, _ in choices {
                if p >= lastWeight && p < weightsRange[i] {
                    // log("Picked Number: ".concat(p.toString()).concat("/".concat(totalWeight.toString())).concat(" corresponding to ".concat(i.toString())))
                    choice = choices[i]
                    break
                }
                lastWeight = weightsRange[i]
            }
            return choice
        }

    }

    pub fun create(seed: UInt128): @Generator {
        return <- create Generator(seed: seed)
    }

    // creates a rng seeded from blockheight salted with hash of a resource uuid (or any UInt64 value)
    // can be used to define traits based on a future block height etc.  
    pub fun createFrom(blockHeight: UInt64, salt: UInt64): @Generator {
        let hash = getBlock(at: blockHeight)!.id
        let h: [UInt8] = HashAlgorithm.SHA3_256.hash(salt.toBigEndianBytes())
        var seed = 0 as UInt128
        let hex : [UInt64] = []
        for byte, i in hash {
            let xor = (UInt64(byte) ^ UInt64(h[i%32]))
            seed = seed << 2
            seed = seed + UInt128(xor)
            hex.append(xor)
        }
        return <- self.create(seed: seed)
    }

    pub fun random(seed: UInt128): UInt128 {
        return self.lcg(modulus: 4294967296, a: 1664525, c: 1013904223, seed: seed)
    }
    
    pub fun lcg(modulus: UInt128, a: UInt128, c: UInt128, seed: UInt128): UInt128 {
        return (a * seed + c) % modulus
    }

}
