# Motivation
If we have an array of objects,
    the compiler has to allocated enough space for each of them.
If they were to grow or shrink then the compiler 
    has to leave a lot of room for each object
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