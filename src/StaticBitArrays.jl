module StaticBitArrays

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
         length(s) == nchunks(T, L) || error("register/length mismatch")
         new{S,M,T,N,L}(s)
    end
end

const SBitVector{S1} = SBitArray{Tuple{S1}} where S1
const SBitMatrix{S1,S2} = SBitArray{Tuple{S1,S2}} where {S1,S2}

# Convenience constructors for an array of booleans, not type stable
SBitArray{S}(a::AbstractArray{Bool}) where S = SBitArray{S}(UInt64, a)
SBitArray{S}(nt::NTuple{<:Any,Bool}) where S = SBitArray{S}(UInt64, nt)
function SBitArray{S}(::Type{T}, a::Union{AbstractArray{Bool},NTuple{<:Any,Bool}}) where {S,T<:Unsigned}
    L = SA.tuple_prod(S)
    M = nchunks(T, L)
    length(a) == L || error("Length of prod(S): $L does not match length of array a $(length(a))")
    nb = nbits(T)
    # build an ntuple for the number of chunks M
    chunks = ntuple(M) do c
        # loop over bits to build the chunk
        chunk = zero(T)
        for i in 1:nbits(T)
            chunk |= a[(c - 1) * nb + i] << (i - 1)
        end
        chunk
    end
    SBitArray{S}(SVector{M,T}(chunks))
end

SBitArray{S}(a::AbstractArray{Bool}) where {S} = SBitArray{S}(UInt64, a)

Base.size(::SBitArray{S,M}) where {S,M} = S
Base.IndexStyle(::Type{<:SBitArray}) = IndexLinear()
Base.getindex(s::SBitArray{S,M,T}, ind::Int) where {S,M,T} = @inbounds readbit_mod(s.chunks[cld(ind, nbits(T))], ind)
# moded version of readbit
readbit_mod(x::T, loc::Int) where {T<:Unsigned} = (x >> (mod1(loc, nbits(T)) - 1)) & one(T) == one(T)

nchunks(T, l) = cld(l, nbits(T))
nbits(T) = sizeof(T) * 8

function Base.iterate(s::SBitArray{S,M,T}, state=(1, s.chunks[1])) where {S,M,T} 
    (ind, val::T) = state
    size = fieldtypes(S)
    L = prod(size)
    if ind > L
        nothing
    else
        return @inbounds (readbit_mod(val, ind), 
            (ind+1, mod1(ind, nbits(T)) == 1 ? S.chunks[nchunks(T, ind)] : val))
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
