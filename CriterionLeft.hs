#! /usr/bin/env stack
-- stack script --resolver lts-9.5

module CriterionLeft where

import Criterion
import Criterion.Main

main = defaultMain [ env (return (13,17)) unrelatedBenchmark ]

unrelatedBenchmark :: (Int, Int) -> Benchmark
unrelatedBenchmark (n, m) = bench "const" $ nf (const 23 :: Int -> Int) 29
