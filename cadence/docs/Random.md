# Random Smart Contract Usage Guide

This guide provides a simplified overview of the pertinent functions of the `Random` smart contract along with examples. It focuses on the essential functions for adding traits, resolving them, and retrieving the calculated traits.

## Step 1: Creating a Random.Struct Instance

To start using the Random contract, you need to create an instance of the Random.Struct structure.

```swift
let myStruct = Random.Struct(offest: 10)
```

In the example above, a new Struct instance named myStruct is created with an offset of 10 blocks. The struct will be resolved after 10 blocks have passed.

## Step 2: Adding Traits

Once you have a Struct instance, you can add traits to it using the appropriate functions based on the type of randomization you want.

### Adding a UFix64 Trait

To add a UFix64 trait, use the addUFix64 function.

```swift
myStruct.addUFix64(trait: "trait1")
```

In the example above, a UFix64 trait named "trait1" is added to the myStruct instance.

### Adding a Range Trait

To add a range trait, use the addRange function.

```swift
myStruct.addRange(trait: "trait2", min: 1, max: 100)
```

In the example above, a range trait named "trait2" is added to the myStruct instance. The trait will be resolved with a random value between 1 and 100.

### Adding a Weighted Choice Trait

To add a weighted choice trait, use the addWeightedChoice function.

```swift
let choices = ["choice1", "choice2", "choice3"]
let weights: [UInt128] = [1, 2, 3]
myStruct.addWeightedChoice(trait: "trait3", choices: choices, weights: weights)
```

In the example above, a weighted choice trait named "trait3" is added to the myStruct instance. The trait will be resolved by choosing one of the choices based on their respective weights.

## Step 3: Resolving Traits

Once you have added all the desired traits, you can resolve them to calculate their values.

```swift
myStruct.resolve()
```

The resolve function will calculate the values of the traits using the specified randomization methods. It can only be called after the required number of blocks (specified by the offset during initialization) have passed.

## Step 4: Retrieving Calculated Traits

After resolving the traits, you can retrieve the calculated trait values using the getTraits function.

```swift
let calculatedTraits = myStruct.getTraits()
```

The getTraits function returns a dictionary of trait names mapped to their calculated values. If the traits have not been resolved yet, the function will return a dictionary with trait names as keys and nil as values.

In the example above, the calculated traits are stored in the calculatedTraits dictionary.

## Full Example

Here's a complete example demonstrating the usage of the Random smart contract:

```swift
let myStruct = Random.Struct(offset: 10)

myStruct.addUFix64(trait: "trait1")
myStruct.addRange(trait: "trait2", min: 1, max: 100)

let choices = ["choice1", "choice2", "choice3"]
let weights: [UInt128] = [1, 2, 3]
myStruct.addWeightedChoice(trait: "trait3", choices: choices, weights

// 10 block later... 
myStruct.resolve()

let calculatedTraits = myStruct.getTraits()
```

In this example, a Struct instance named myStruct is created with an offset of 10 blocks. Three different traits are added, and then the traits are resolved. Finally, the calculated traits are retrieved and stored in the calculatedTraits dictionary.
