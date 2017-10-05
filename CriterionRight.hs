#! /usr/bin/env stack
-- stack script --resolver nightly-2017-10-05

module CriterionWut where

import Criterion
import Criterion.Main

main = defaultMain [ env (return 13) unrelatedBenchmark ]

unrelatedBenchmark :: Int -> Benchmark
unrelatedBenchmark n = bench "const" $ nf (const 23 :: Int -> Int) 29
