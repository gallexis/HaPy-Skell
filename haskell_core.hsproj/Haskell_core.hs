{-# LANGUAGE OverloadedStrings #-}

module Main where

import JSON_Parser
import Structures
import Manager

import Control.Monad
import qualified Data.ByteString.Char8 as B

import Network.Socket hiding (send, sendTo, recv, recvFrom)
import Network.Socket.ByteString


-- concurrency
import Control.Exception
import Control.Concurrent

import Utils.Logging

main :: IO ()
main = do

    logging "Connecting to python server..."

    chan <- newChannel

    sock <- socket AF_UNIX Stream defaultProtocol
    connect sock $ SockAddrUnix "/tmp/test_sock.ipc"


    forkIO $ receiver chan sock
    forkIO $ sender chan sock

    writeChannel chan $ Just $ Command "order" "haskell -> python"
    -- writeChannel chan p

    threadDelay 6000000
    print "exit"


