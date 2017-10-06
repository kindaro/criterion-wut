`criterion`: `env` doesn't like tuples.
=======================================

Here presented are two Haskell scripts, one of which is erroneous.

    % ./CriterionLeft.hs
    CriterionLeft.hs: Criterion.env could not determine the list of your benchmarks
    since they force the environment (see the documentation for details)
    CallStack (from HasCallStack):
      error, called at ./Criterion/Internal.hs:202:7 in
    criterion-1.1.4.0-EKiMF3PtlUVEKNn1brKmII:Criterion.Internal

The difference between them is solely in the environment type:

    -main = defaultMain [ env (return (13,17)) unrelatedBenchmark ]
    +main = defaultMain [ env (return 13) unrelatedBenchmark ]
     
    -unrelatedBenchmark :: (Int, Int) -> Benchmark
    -unrelatedBenchmark (n, m) = bench "const" $ nf (const 23 :: Int -> Int) 29
    +unrelatedBenchmark :: Int -> Benchmark
    +unrelatedBenchmark n = bench "const" $ nf (const 23 :: Int -> Int) 29

The reason for this error is so far unclear.

---

The reason for such *apparently unreasonable* behaviour is found out to be the strict evaluation
of the outermost -- that is, tuple, -- constructor. The solution is to add a `~` before the
pattern.

A more detailed explanation can be found here:
[github.com/bos/criterion/issues/159](https://github.com/bos/criterion/issues/159).

The situation before and after resolution is marked with tags `erroneous` & `fixed`. You may
review the difference with command such as `git diff erroneous fixed`.

Repeatedly Test
---------------

There surfaced some three more issues during my investigation of this case.

1. Inflated variance (conjectured to be related to 0 deviance). [An issue is opened](https://github.com/bos/criterion/issues/160).

2. `Sample is empty` runtime error. [An issue is
   opened](https://github.com/bos/criterion/issues/161).

3. `index out of bounds` runtime error. [An issue is
   opened](https://github.com/bos/criterion/issues/162).
