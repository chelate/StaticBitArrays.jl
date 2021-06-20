
using SBitArrays
using StaticArrays

a = SBitVector(SVector{2, UInt64}(3,31),Val(70) )

b = rand(Bool,1000)


@time k = [SBitVector{200}(UInt8,rand(Bool,200)) for ii in 1:100]

bb = SBitVector(UInt8,b)

reduce((&),b .== bb)
