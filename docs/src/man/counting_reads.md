```@meta
CurrentModule = MerCounting
```

# Counting kmers in read datasets

MerCounting provides some more dedicated counting algorithms for counting kmers
in read datasets, particularly ReadDatastores.

This is because as conceptually simple as counting kmers is, to do it quickly
for large sequencing read datasets output by sequencing machines can be
difficult for some datasets.

There are many ways you can try to optimise the kmer counting process, and many
kmer counting tools already exist.

MerCounting provides a `Counters` submodule, which contains nessecery methods
and types required to implement various kinds of kmer counter, as well as
exporting a selection of "off-the-shelf" methods that use different counting
strategies, one or several of which hopefully suit the user's dataset and
computational resources available. We describe and showcase these below.

## The `serial_mem` counter

The [`serial_mem`](@ref) counter is the simplest kmer counter for reads that
is provided.

It counts kmers in each read serially, and stores the kmers and counts entirely
in RAM.

```@docs
Counters.serial_mem
```

It is fairly simple to use. First you need a ReadDatastore, if you need to
recall how to create one then head over
to [here](https://biojulia.net/ReadDatastores.jl/stable/build-datastores/) in
ReadDatastores.jl's documentation.

The example below opens a datastore before using [`serial_mem`](@ref) to count
the kmers in the read datastore.

```@setup serialmem
using ReadDatastores
using FASTX
using BioSequences
print(pwd())
fwq = open(FASTQ.Reader, "test/ecoli_tester_R1.fastq")
rvq = open(FASTQ.Reader, "test/ecoli_tester_R2.fastq")
PairedReads{DNAAlphabet{2}}(fwq, rvq, "ecoli-test-paired", "my-ecoli-test", 250, 300, 0, FwRv)
```

```@repl serialmem
using MerCounting
using ReadDatastores
ds = @openreads "ecoli-test-paired.prseq"
kl = Counters.serial_mem(DNAMer{31}, ds, CANONICAL)
```