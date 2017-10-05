#! /usr/bin/env stack
-- stack script --resolver lts-9.5

module CriterionWut where

import Criterion
import Criterion.Main

main = defaultMain [ env (return 13) unrelatedBenchmark ]

unrelatedBenchmark :: Int -> Benchmark
unrelatedBenchmark n = bench "const" $ nf (const 23 :: Int -> Int) 29
