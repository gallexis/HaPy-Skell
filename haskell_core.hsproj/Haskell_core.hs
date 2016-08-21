{-# LANGUAGE OverloadedStrings #-}

module Main where

import JSON_Parser
import Structures
import Manager

import Control.Monad
import qualified Data.ByteString.Char8 as B

import Network.Socket hiding (send, sendTo, recv, recvFrom)
import Network.Socket.ByteString

import System.IO
import System.Posix

-- concurrency
import Control.Exception
import Control.Concurrent

logFile = "haskell-log.txt"

logging :: String -> IO ()
logging str = do
    withFile logFile AppendMode $ \h -> do
        hSetBuffering h (BlockBuffering Nothing)
        hPutStr h $ str ++ "\n"


main :: IO ()
main = do

    print "Connecting to python server..."

    -- Creating channel
    chan <- newChannel

    -- Creating socket
    sock <- socket AF_UNIX Stream defaultProtocol
    connect sock $ SockAddrUnix "/tmp/test_sock.ipc"

    -- starting threads
    forkIO $ receiver chan sock
    forkIO $ sender chan sock


    -- tests
    writeChannel chan $ Just $ Command "local_test" "haskell -> python"
    -- writeChannel chan p

    threadDelay 6000000
    print "exit"




