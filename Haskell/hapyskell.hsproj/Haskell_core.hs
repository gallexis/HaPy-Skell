
module Main where

import Control.Monad
import qualified Data.ByteString.Char8 as B

import Network.Socket hiding (send, sendTo, recv, recvFrom)
import Network.Socket.ByteString

import Data.Map

-- concurrency
import Control.Exception
import Control.Concurrent

import Hapyskell.Hapyskell as Hapyskell
import Hapyskell.Utils.Logging

display_message:: String -> String 
display_message msg= "message received: " ++ msg


functions = fromList [ ("display_message",display_message) ]


main = do
  logging "Starting"
  
  chan <- Hapyskell.connect_to_python functions
  Hapyskell.send chan "test" "haskell to python"
  
  threadDelay 6000000
  logging "exit"
  
  return ()