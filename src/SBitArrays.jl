module SBitArrays
using Core: ReturnNode
export SBitVector

using StaticArrays

struct SBitVector{L,M,T<:Unsigned} <: AbstractVector{Bool}
    # type signiture: {Length, ChunksLength, ChunksType}
    chunks::SVector{M,T}
    function SBitVector(s::SVector{M, T}, ::Val{L}) where {M,T,L}
         if !isa(L, Integer) || length(s) != cld(L, sizeof(T)*8)
             error("register/length mismatch")
         end
         new{L,M,T}(s)
    end
end

# Convenience constructors for an array of booleans, not type stable
function SBitVector{L}(::Type{T}, a::AbstractVector{Bool}) where {L,T<:Unsigned}
    M = cld(L, sizeof(T)*8)
    chunks = zeros(T,M)
    ii = 0
    for bool in a
        ii += 1
        ii > L && break
        if bool
            chunks[cld(ii,sizeof(T)*8)] += one(T) << (mod1(ii, sizeof(T)*8) - 1)
        end
    end
    SBitVector(SVector{M,T}(chunks),Val(L))
end

SBitVector{L}(a::AbstractVector{Bool}) where {L} = SBitVector{L}(UInt64, a::AbstractVector{Bool})

Base.size(::SBitVector{L,M}) where {L,M} = (L,)
Base.IndexStyle(::Type{<:SBitVector}) = IndexLinear()
Base.getindex(S::SBitVector{L,M,T}, ind::Int) where {L,M,T} = @inbounds readbit_mod(S.chunks[cld(ind, sizeof(T)*8)], ind)
# moded version of readbit
readbit_mod(x::T, loc::Int) where {T<:Unsigned} = (x >> (mod1(loc, sizeof(T)*8) - 1)) & one(T) == one(T)

function Base.iterate(S::SBitVector{L,M,T}, state=(1, S.chunks[1])) where {L,M,T} 
    (ind, val::T) = state
    if ind > L
        nothing
    else
        return @inbounds (readbit_mod(val, ind), 
            (ind+1, 
            mod1(ind,sizeof(T)*8) == 1 ? S.chunks[cld(ind, sizeof(T)*8)] : val))
    end
end

function dot(a::SBitVector, b::AbstractVector{T}) where T
    s = zero(T)
    for (bool,val) in zip(a,b)
        if bool 
            s += val
        end
    end
    return s
end




end # module




