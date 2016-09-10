{-# LANGUAGE OverloadedStrings #-}

module Hapyskell.Hapyskell where

import Hapyskell.Utils.JSON
import Hapyskell.Structures
import Hapyskell.Manager

import Hapyskell.Utils.Logging

import Control.Monad
import qualified Data.ByteString.Char8 as B

import Network.Socket hiding (send, sendTo, recv, recvFrom)
import Network.Socket.ByteString

import Data.Map

-- concurrency
import Control.Exception
import Control.Concurrent


{-
display_message:: String -> String 
display_message msg= "massage received: " ++ msg


functions = fromList [ ("display_message",display_message) ]

-}

send :: Channel (Maybe Command) -> String -> String -> IO ()
send chan [] [] = return ()
send chan [] _  = return ()
send chan _ []  = return ()
send chan order message =
      writeChannel chan $ Just $ Command order message
 

connect_to_python :: Map String (String -> String) -> IO (Channel (Maybe Command))
connect_to_python map_functions = do
    chan <- newChannel
    sock <- socket AF_UNIX Stream defaultProtocol
    connect sock $ SockAddrUnix "/tmp/test_sock.ipc"
    
    forkIO $ receiver sock map_functions
    forkIO $ sender chan sock


    return chan




    -- writeChannel chan $ Just $ Command "order" "haskell -> python"
    -- writeChannel chan p


