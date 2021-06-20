module SBitArrays

using StaticArrays
const SA = StaticArrays

export SBitVector, SBitMatrix, SBitArray

struct SBitArray{S,M,T<:Unsigned,N,L} <: StaticArray{S,Bool,N}
    # type signiture: {Length, ChunksLength, ChunksType}
    chunks::SVector{M,T}
    function SBitArray{S}(s::SVector{M,T}) where {S,M,T}
         S <: Tuple || error("type parameter S: $S must be a Tuple type of Int, e.g. `SBitArray{Tuple{4,5}}`")
         N = SA.tuple_length(S)
         L = SA.tuple_prod(S)
         if length(s) != nchunks(T, L)
             error("register/length mismatch")
         end
         new{S,M,T,N,L}(s)
    end
end

const SBitVector{S1} = SBitArray{Tuple{S1}} where S1
const SBitMatrix{S1,S2} = SBitArray{Tuple{S1,S2}} where {S1,S2}

# Convenience constructors for an array of booleans, not type stable
function SBitArray{S}(::Type{T}, a::AbstractArray{Bool}) where {S,T<:Unsigned}
    L = SA.tuple_prod(S)
    M = nchunks(T, L)
    chunks = zeros(T,M)
    ii = 0
    for bool in a
        ii += 1
        ii > L && break
        if bool
            chunks[cld(ii,sizeof(T)*8)] += one(T) << (mod1(ii, sizeof(T)*8) - 1)
        end
    end
    SBitArray{S}(SVector{M,T}(chunks))
end

SBitArray{S}(a::AbstractArray{Bool}) where {S} = SBitArray{S}(UInt64, a)

Base.size(::SBitArray{S,M}) where {S,M} = S
Base.IndexStyle(::Type{<:SBitArray}) = IndexLinear()
Base.getindex(s::SBitArray{S,M,T}, ind::Int) where {S,M,T} = @inbounds readbit_mod(s.chunks[cld(ind, sizeof(T)*8)], ind)
# moded version of readbit
readbit_mod(x::T, loc::Int) where {T<:Unsigned} = (x >> (mod1(loc, sizeof(T)*8) - 1)) & one(T) == one(T)

nchunks(T, l) = cld(l, sizeof(T) * 8)

function Base.iterate(s::SBitArray{S,M,T}, state=(1, s.chunks[1])) where {S,M,T} 
    (ind, val::T) = state
    size = fieldtypes(S)
    L = prod(size)
    if ind > L
        nothing
    else
        return @inbounds (readbit_mod(val, ind), 
            (ind+1, 
            mod1(ind,sizeof(T)*8) == 1 ? S.chunks[cld(ind, sizeof(T)*8)] : val))
    end
end

function dot(a::SBitArray, b::AbstractVector{T}) where T
    s = zero(T)
    for (bool,val) in zip(a,b)
        if bool 
            s += val
        end
    end
    return s
end

end # module
