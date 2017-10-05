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
