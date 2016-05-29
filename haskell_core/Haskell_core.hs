{-# LANGUAGE OverloadedStrings #-}

module Main where

import JSON_Parser
import System.IO
import Control.Monad
import System.ZMQ4.Monadic
import qualified Data.ByteString.Char8 as B

ext :: Maybe Command -> String
ext Nothing = "error"
ext (Just p) = JSON_Parser.order p ++ " -- " ++ JSON_Parser.message p

logFile = "haskell-log.txt"

logging :: String -> IO ()
logging str = do
    withFile logFile AppendMode $ \h -> do
        hSetBuffering h (BlockBuffering Nothing)
        hPutStr h $ str ++ "\n"

main :: IO ()
main =
    runZMQ $ do
    liftIO $ logging "Connecting to python server..."

    requester <- socket Pair
    connect requester "ipc:///tmp/1"

    send requester [] $ B.pack $ json_to_str $ Command "order" "world"
    w <- receive requester
    let p = str_to_json $ B.unpack  w
    liftIO . logging $  "Received "  ++ (ext p)


    liftIO $ logging "exit"


