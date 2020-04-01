"""
    count_mers_srd(::Type{M}, sbuf::DatastoreBuffer{PairedReads}, range::UnitRange{Int}) where {M<:AbstractMer}

MerCounting's simplest kmer counting method.

Build a sorted list (vector) of kmer counts (MerCount), serially and entirely in memory.

!!! warning
    The "_srd" part of "count_mers_srd" jokingly stands for "Serial RAM Destroyer" (or "Stupid RAM Destroyer"):
    
    This function is a serial and in memory `MerCount` list builder that can build a
    kmer count from a PairedReads datastore on its own (if you have memory and time),
    but it is also intended to be composed into other multi-process or multi-threaded
    kmer counting strategies.

    This method estimates roughly how many kmers will be generated by the reads
    specified by `range` in the dataset. It then pre-allocates an array to contain
    them. It then collects the kmers, sorts, them, and then collapses them into a
    list of counts sorted by the kmer.
    
    So if you want to count kmers and have the resources to throw at it, this is
    the simplest method, and possibly even the quickest given that simplicity.
"""
function count_mers_srd(::Type{M}, sbuf::DatastoreBuffer{<:PairedReads}, range::UnitRange{Int}) where {M<:AbstractMer}
    max_read_size = max_read_length(ReadDatastores.datastore(sbuf))
    chunk_mers = Vector{M}(undef, length(range) * (max_read_size - ksize(M) + 1))
    wi = firstindex(chunk_mers)
    read_sequence = eltype(sbuf)()
    @inbounds for i in range
        for mer in each(M, load_sequence!(sbuf, i, read_sequence))
            chunk_mers[wi] = canonical(mer)
            wi = wi + 1
        end
    end
    resize!(chunk_mers, wi - 1)
    return collapse_into_counts(chunk_mers)
end

function count_mers_srd(::Type{M}, prdsfile::String, range::UnitRange{Int}) where {M<:AbstractMer}
    prds = open(PairedReads, prdsfile)
    bufprds = SequenceBuffer(prds)
    return count_mers_srd(M, bufprds, range)
end

function count_mers_srd(::Type{M}, sbuf::DatastoreBuffer{<:PairedReads}) where {M<:AbstractMer}
    return count_mers_srd(M, sbuf, 1:length(sbuf))
end