#! /usr/bin/env stack
-- stack script --resolver nightly-2017-10-05

module RepeatedlyTest where

import Control.Monad (when)
import Data.List (groupBy)
import Data.Maybe
import System.Environment
import System.FilePath
import System.IO
import System.Process

target = "./CriterionRight.hs"
targetArgs = []

isOutputPathological output = (length . lines $ output) /= 7
compareResults (a,x) (b,y) = length a == length b && x == y

main = do
    args <- getArgs
    if null args || ((read :: String -> Int) . head $ args) < 0
        then putStrLn "Usage:\n    One non-negative integral argument for the number of runs."
        else main' args

main' (count': _) = do
    let count = (read :: String -> Int) count'
    captured <- sequence (replicate count captureErrors)
    prettyPrint captured

captureErrors :: IO (Maybe (Maybe String, Maybe String))
captureErrors = do
    (_, Just stdOut, Just stdErr, pid) <- createProcess $
        (proc target targetArgs) { std_out = CreatePipe, std_err = CreatePipe }
    output <- hGetContents stdOut
    errors <- hGetContents stdErr

    let maybeOutput | isOutputPathological output = Just output
                    | otherwise                   = Nothing

    let maybeError  | (not . null) errors = Just errors
                    | otherwise           = Nothing

    if   isJust maybeOutput || isJust maybeError
    then return $ Just (maybeOutput, maybeError)
    else return Nothing

prettyPrint :: [Maybe (Maybe String, Maybe String)] -> IO ()
prettyPrint chunks = do
    let groups = groupBy compareResults . catMaybes $ chunks
    let boringN = length . filter isNothing $ chunks
    when (boringN > 0) $ putStrLn $ (show boringN) ++ " boring chunks ignored."
    sequence_ $ prettyPrintGroup <$> groups

  where
    prettyPrintGroup :: [(Maybe String, Maybe String)] -> IO ()
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
