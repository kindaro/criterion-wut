#! /usr/bin/env stack
-- stack script --resolver nightly-2017-10-05

module RepeatedlyTest where

import Control.Monad (when, replicateM)
import Data.List (groupBy, sortBy)
import Data.Maybe
import System.Environment
import System.FilePath
import System.IO
import System.Process

target = "./CriterionRight.hs"
targetArgs = []

type Result = (Maybe String, Maybe String)

isOutputPathological output = (length . lines $ output) /= 7

eqResults :: Result -> Result -> Bool
eqResults (a,x) (b,y) = length a == length b && x == y

compareResults :: Result -> Result -> Ordering
compareResults (a,x) (b,y) | x == y = a `compare` b
                           | otherwise = x `compare` y

main = do
    args <- getArgs
    if null args || ((read :: String -> Int) . head $ args) < 0
        then putStrLn "Usage:\n    One non-negative integral argument for the number of runs."
        else main' args

main' (count': _) = do
    let count = (read :: String -> Int) count'
    captured <- replicateM count captureErrors
    prettyPrint captured

captureErrors :: IO (Maybe Result)
captureErrors = do
    (_, Just stdOut, Just stdErr, pid) <- createProcess $
        (proc target targetArgs) { std_out = CreatePipe, std_err = CreatePipe }
    output <- hGetContents stdOut
    errors <- hGetContents stdErr

    let maybeOutput | isOutputPathological output = Just output
                    | otherwise                   = Nothing

    let maybeError  | (not . null) errors = Just errors
                    | otherwise           = Nothing

    if isJust maybeOutput || isJust maybeError
        then return $ Just (maybeOutput, maybeError)
        else return Nothing

prettyPrint :: [Maybe Result] -> IO ()
prettyPrint chunks = do
    let groups = groupBy eqResults . sortBy compareResults . catMaybes $ chunks
    let boringN = length . filter isNothing $ chunks
    when (boringN > 0) $ putStrLn $ show boringN ++ " boring chunks ignored."
    sequence_ $ prettyPrintGroup <$> groups

  where
    prettyPrintGroup :: [Result] -> IO ()
    prettyPrintGroup [] = return ()
    prettyPrintGroup group = do
        putStrLn $ "Group of " ++ show (length group) ++ " entries:"
        prettyPrintEntry "Pathological output" (fst $ head group)
        prettyPrintEntry "Error text" (snd $ head group)

    prettyPrintEntry :: String -> Maybe String -> IO ()
    prettyPrintEntry caption (Just entry) = do
        putStrLn $ caption ++ ":"
        putStrLn $ unlines $ ("> " ++) <$> lines entry
    prettyPrintEntry _ Nothing = return ()
