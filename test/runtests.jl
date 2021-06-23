using StaticBitArrays
using StaticArrays
using Test

v = SBitVector{70}(SVector{2, UInt64}(3, 31));
a = SBitArray{Tuple{70}}(SVector{2, UInt64}(3, 31));
@test v === a

T = UInt8
l = 7
for T in [UInt8,UInt16,UInt32,UInt64], l in (1, 2, 7, 8)
    rbv = rand(Bool, l)
    rbm = rand(Bool, l, l)
    rba = rand(Bool, l, l, l)

    bv = SBitVector{l}(T, rbv);
    @test bv isa AbstractVector
    @test bv[l] == rbv[l]
    @test bv[end] == rbv[end]
    @test all(rbv .== bv)

    bm = SBitMatrix{l,l}(T, rbm);
    @test bm isa AbstractMatrix
    @test bm[l, l] == rbm[l, l]
    @test all(rbm .== bm)

    ba = SBitArray{Tuple{l,l,l}}(T, rba);
    @test ba isa AbstractArray{Bool,3}
    @test ba[l, l, l] == rba[l, l, l]
    @test all(rba .== ba)
end

nothing
