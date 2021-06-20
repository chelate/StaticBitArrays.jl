# Motivation
If we have an array of objects,
    the compiler has to allocated enough space for each of them.
If they were to grow or shrink, then the compiler 
    has to leave a lot of room for each object.
But even if the objects are of fixed size, there is a performance penalty
    because the compiler has to account for the fact that each object 
    *could* be a different size.
Accessing each object in memory means doing a lot of calculations,
    and such mutable objects have more affinity for the "stack" than the "heap."
That means slow.

Fixed size arrays `Static Arrays` have known memory footprint.
Unfortunately for static arrays of Bool, that known footprint is rather large,
    8 bits per Bool.
If our vectors are too big, they wont fit on the stack, 
    and that was the whole point!
`BitArrays` have a footprint which is compact (if your size is greater than 64!)
    but which are not fixed size.
The goal of this package is to combine these features into a single type:
    a compact, flexible, and  efficient statically sized array of bits.

# Scientific use case
In  Ecology or Genetics,
    I want to define a population undergoing kinetic equations,
    such as birth, death and mutation.
```
    [i] → 2[i]
    [i] → *`
    [i] → [j]
```
If the number of types are small
    then I can keep track of the population state with a set of integer vectors,
    indicating the population size for each indvidual.
```
    [n1, n2, ... nN]
```
But if individuals are marked by unique genomes, 
    or by location, 
    or by anything combinatorial, 
    then I really have 'no choice' but to define a 1-1 mapping between individuals and memory registers.
```
    [ [i] ,[i] ,[i] , [j] ...  ]
```
Birth events are really exactly `copy`'s from one register to another.
Good thing we live in the age of 32GB ram!

When I say 'no choice', 
    there are alterantives,
    but they tend to be complicated and inflexible.
As long as we have RAM to spare, and our birth and death events are fast,
    the dumb way is going to be the best way.
Computers are square, and trees are not!

We want complete control over what an individual is,
    cramming as much information into each `[i]` as we test out more ideas
    in our model.
With full bit-wise static memory at our disposal,
    we might see 10^9 individuals born and die,
    in an afternoon on the registers of our laptop!
We are become death, destroyer of worlds.