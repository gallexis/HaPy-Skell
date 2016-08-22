{-# LANGUAGE OverloadedStrings #-}

module Main where

import Utils.JSON
import Structures
import Manager

import Control.Monad
import qualified Data.ByteString.Char8 as B

import Network.Socket hiding (send, sendTo, recv, recvFrom)
import Network.Socket.ByteString

import Data.Map

-- concurrency
import Control.Exception
import Control.Concurrent

import Utils.Logging

{-
display_message:: String -> String 
display_message msg= "massage received: " ++ msg


functions = fromList [ ("display_message",display_message) ]

-}

connect_to_python :: Map String (String -> String) -> IO (Socket, Channel (Maybe Command))
connect_to_python map_functions = do
    chan <- newChannel
    sock <- socket AF_UNIX Stream defaultProtocol
    connect sock $ SockAddrUnix "/tmp/test_sock.ipc"
    
    forkIO $ receiver sock map_functions
    forkIO $ sender chan sock


    return (sock,chan)




    -- writeChannel chan $ Just $ Command "order" "haskell -> python"
    -- writeChannel chan p


