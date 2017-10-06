#! /usr/bin/env stack
-- stack script --resolver nightly-2017-10-05

module CriterionLeft where

import Criterion
import Criterion.Main

main = defaultMain [ env (return (13,17)) unrelatedBenchmark ]

unrelatedBenchmark :: (Int, Int) -> Benchmark
unrelatedBenchmark ~(n, m) = bench "const" $ nf (const 23 :: Int -> Int) 29
