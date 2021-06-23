using BenchmarkTools
using Profile
using ProfileVega
using StaticArrays
using StaticBitArrays

# Basic construction

# This should compile away completely
@btime SBitVector{64}(SVector{1, UInt64}(1));
@btime SBitVector{70}(SVector{2, UInt64}(3, 31));

# These should be real fast
a = rand(Bool, 64)
t = Tuple(a)
@btime SBitVector{64}(Ref($t)[]); # fast
@btime SBitVector{64}(Ref($a)[]); # also fast

# indexing is also fast
bv = SBitVector{64}(UInt32, a);
@btime $bv[Ref(10)[]] # Ref stops it compiling away
@btime map(x -> !x, Ref($bv)[]) # This should return a StaticBitVector
@btime map(x -> 2x, Ref($bv)[])

# The goal here is to find the fastest way to construct a population
function make_population(::Type{T}, x::SVector{L}, N) where {L,T}
    M = cld(L,sizeof(T)*8)
    out = SBitVector{L,M,T}[]
    for _ in 1:N
        push!(out, SBitVector{L}(T,map(p->p < rand(), x)))
    end
    return
end

## Tests 

x = @SVector rand(100) # initial population frequencies
@time out = make_population(UInt8, x, 10^6)
@code_warntype  make_population(UInt8, x, 10^3)
Profile.clear()
@profile out = make_population(UInt8, x, 10^6)
ProfileVega.view() 
# shows an enormous time component ip:0x0
# not sure what that is about
