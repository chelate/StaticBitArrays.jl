using SBitArrays
using StaticArrays
using Test

v = SBitVector{70}(SVector{2, UInt64}(3, 31));
a = SBitArray{Tuple{70}}(SVector{2, UInt64}(3, 31));
@test v === a

rbv = rand(Bool, 100)
rbm = rand(Bool, 10, 10)
rba = rand(Bool, 10, 10, 10)

T = UInt64
for T in [UInt8,UInt16,UInt32,UInt64] # works for all UInts
    bv = SBitVector{100}(T, rbv);
    @test bv isa AbstractVector
    @test bv[1] == rbv[1]
    @test all(rbv .== bv)

    bm = SBitMatrix{10,10}(T, rbm);
    @test bm isa AbstractMatrix
    @test bm[1, 2] == rbm[1, 2]
    @test all(rbm .== bm)

    ba = SBitArray{Tuple{10,10,10}}(T, rba);
    @test ba isa AbstractArray{Bool,3}
    @test ba[1, 2, 3] == rba[1, 2, 3]
    @test all(rba .== ba)
end
