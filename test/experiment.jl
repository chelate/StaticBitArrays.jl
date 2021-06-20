
using SBitArrays
using StaticArrays

a = SBitVector(SVector{2, UInt64}(3,31),Val(70) )

b = rand(Bool,1000)
for t in [UInt8,UInt16,UInt32,UInt64] # works for all UInts
    bb = SBitVector{1000}(t,b)
    out = reduce((&),b .== bb)
    println(out)
end
