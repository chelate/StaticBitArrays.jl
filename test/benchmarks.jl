using BenchmarkTools
using Profile
using ProfileVega
using StaticArrays
using StaticBitArrays

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