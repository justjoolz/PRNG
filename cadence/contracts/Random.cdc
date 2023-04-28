import PRNG from "./PRNG.cdc"

/*
    Random.cdc

    A helper smart contract for generating random traits for NFTs.

    This contract uses the PRNG contract to generate a stream of random numbers for each trait from the same seed.
    You create a new Struct with a salt and an offset. The salt is used to generate the seed for the PRNG contract.
    The offset is how many blocks before you can resolve the traits. This is to prevent the traits from being resolved in the same block which would result in predictable random numbers and the ability to abort if the seed is not to the callers liking.

    Usage:

    // First create a structure for storing the traits, which can be resolved, in this case after an offset of 1 block.
    let metadata = Random.Struct(offset: 1)
    
    // add some traits
    metadata.addUFix64(trait: "Hue") // adds a trait that will be resolved to a UFix64 between 0 and 1
    metadata.addRange(trait: "Saturation", min: 0, max: 100) // adds a trait that will be resolved to a UInt128 between 0 and 100
    metadata.addWeightedChoice(trait: "Brightness", choices: [0.1, 0.2, 0.3], weights: [1, 2, 3]) // adds a trait that will be resolved to a UFix64 between 0 and 1 with a 1/6 chance of being 0.1, 2/6 chance of being 0.2, and 3/6 chance of being 0.3
    metadata.addWeightedChoice(trait: "head", choices: ["Big", "Small", "Fancy"], weights: [49, 49, 2]) // adds a trait that will be resolved to a String with a 49/100 chance of being "Big", 49/100 chance of being "Small", and 2/100 chance of being "Fancy"
    
    You can pass any AnyStruct as a choice, but the weight must be a UInt128.

    metadata.getTraits() // returns ["Hue": nil, "Saturation": nil, "Brightness": nil, "head": nil]

    // one block later.... in a transaction or a script....
    metadata.resolve() // resolves the traits
    metadata.getTraits() // returns ["Hue": 0.1, "Saturation": 50, "Brightness": 0.3, "head": "Big"]
    
    Once the traits are resolved they are no longer calculated but returned directly from the getTraits() function.

    You can pass any struct to the choices array in the addWeightedChoice function.
    You could have something like this:

    metadata.addWeightedChoice(trait: "head", choices: [templateId1, templateId2, templateId3], weights: [90, 5, 5])

    where Head1, Head2, and Head3 are structs that implement the Trait interface.
 */

pub contract Random {
    pub var test: Struct

    // A resource that is only used for generating a 'random' salt from it's uuid
    pub resource Salt {
        init() {}
    }

    // a Structure for storing randomized traits
    // this struct uses the same generator to generate a stream of random numbers for each trait from the same seed    
    pub struct Struct {
        access(self) var traits: [AnyStruct{Trait}]
        access(self) var calculatedTraits: {String: AnyStruct}
        access(self) var resolveAtBlockheight: UInt64
        access(self) var salt: UInt64
        access(self) var isResolved: Bool
        
        pub init(offset: UInt64) {
            pre {
                offset > 0: "offset must be greater than 0"
            }
            self.traits = []
            self.calculatedTraits = {}
            self.resolveAtBlockheight = getCurrentBlock().height + offset
            let salt <- create Random.Salt()
            self.salt = salt.uuid
            destroy salt
            self.isResolved = false
        }

        // value between ufix 0 and 1
        pub fun addUFix64(trait: String) {
            pre {
                trait.length > 0: "trait must be longer than 0"
            }
            self.traits.append(UFix64Trait(traitName: trait))
        }

        pub fun addRange(trait: String, min: UInt128, max: UInt128) {
            pre {
                trait.length > 0: "trait must be longer than 0"
                min < max: "min must be less than max"
            }
            self.traits.append(RangeTrait(traitName: trait, min: min, max: max))
        }

        pub fun addWeightedChoice(trait: String, choices: [AnyStruct], weights: [UInt128]) {
            pre {
                trait.length > 0: "trait must be longer than 0"
                weights.length == choices.length: "choices and weights must be the same length"
            }
            self.traits.append(WeightChoiceTrait(traitName: trait, choices: choices, weights: weights))
        }

        pub fun resolve() {
            pre {
                getCurrentBlock().height > self.resolveAtBlockheight: "This struct can not be resolved until block ".concat(self.resolveAtBlockheight.toString()).concat(" has passed")
            } 
            let rng <- self.generator()
            for trait in self.traits {
                if trait.getType() == Type<Random.WeightChoiceTrait>() {
                    let resolvedTrait =  trait as! WeightChoiceTrait
                    self.calculatedTraits.insert(key: resolvedTrait.traitName, rng.pickWeighted(resolvedTrait.choices, resolvedTrait.weights))
                } else if trait.getType() == Type<Random.RangeTrait>() {
                    let resolvedTrait =  trait as! RangeTrait
                    self.calculatedTraits.insert(key: resolvedTrait.traitName, rng.range(resolvedTrait.min, resolvedTrait.max))
                } else if trait.getType() == Type<Random.UFix64Trait>() {
                    let resolvedTrait =  trait as! UFix64Trait
                    self.calculatedTraits.insert(key: resolvedTrait.traitName, rng.ufix64())
                }
            }
            destroy rng
            self.isResolved = true
        }

        pub fun getTraits(): {String: AnyStruct} {
            if self.isResolved {
                return self.calculatedTraits
            } 
            if getCurrentBlock().height > self.resolveAtBlockheight {
                self.resolve()
                return self.calculatedTraits
            }            
            let traits: {String: AnyStruct} = {}
            // return the traits as nil if they have not been resolved
            for trait in self.traits {
                traits.insert(key: (trait as {Trait}).traitName, nil)
            }
            return traits
        }

        // internal function to get the generator
        access(self) fun generator(): @PRNG.Generator {
            return <- PRNG.createFrom(blockHeight: self.resolveAtBlockheight, salt: self.salt)
        }
    }

    pub struct interface Trait {
        pub let traitName: String
    }

    // a structure for storing a trait that will be resolved at a later time
    pub struct UFix64Trait: Trait {
        pub let traitName: String

        init(traitName: String) {
            self.traitName = traitName
        }
    }

    pub struct RangeTrait: Trait {
        pub let traitName: String
        pub let min: UInt128
        pub let max: UInt128

        init(traitName: String, min: UInt128, max: UInt128) {
            self.traitName = traitName
            self.min = min
            self.max = max
        }
    }

    pub struct WeightChoiceTrait: Trait {
        pub let traitName: String
        pub let choices: [AnyStruct]
        pub let weights: [UInt128]

        init(traitName: String, choices: [AnyStruct], weights: [UInt128]) {
            self.traitName = traitName
            self.choices = choices
            self.weights = weights
        }
    }

    init() {
        self.test = Struct(offset: 1)

        var sampleSize = 350
        while sampleSize > 0 {
            self.test.addUFix64(trait: sampleSize.toString())
            sampleSize = sampleSize - 1
        } 
        // self.test.addRange(trait: "Age", min: 0, max: 100)
        // self.test.addWeightedChoice(trait: "Brightness", choices: [0.1, 0.2, 0.3], weights: [1, 2, 3])
        self.test.addWeightedChoice(trait: "head", choices: ["Big", "Small", "Fancy"], weights: [49, 49, 2])

        // self.test.resolve()
        log(self.test.getTraits()) // returns ["Hue": nil, "Saturation": nil, "Brightness": nil, "head": nil]
    }
}

// create a metadata view for the probabilities etc.