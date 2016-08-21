{-# LANGUAGE OverloadedStrings #-}

module Manager( receiver,
                sender,
                manager
) where

import JSON_Parser
import Structures

import Control.Monad
import qualified Data.ByteString.Char8 as B

import Network.Socket hiding (send, sendTo, recv, recvFrom)
import Network.Socket.ByteString

import Prelude hiding (lookup)
import Data.Map

import System.IO
import System.Posix

-- concurrency
import Control.Exception
import Control.Concurrent


display_message:: String -> String 
display_message msg= "massage received: " ++ msg

list_of_functions = fromList [ 
                      ("display_message",display_message),
                      ("local_test",display_message)
                    ]



receiver chan sock =
    forever $ do
        messageReceived <- recv sock 1024
        let message = str_to_json $ B.unpack messageReceived
        manager message
        return ()

sender chan sock =
    forever $ do
        command <- try (readChannel chan) :: IO (Either SomeException (Maybe Command) )
        case command of
            Left ex  -> do
                print ex
                return ()

            Right cmd  ->
                case cmd of
                    Just(Command order message) -> do
                        send sock $ B.pack $ json_to_str $ Command order message
                        print "sent"
                        return ()

                    Nothing -> do
                        print "nothing"
                        return ()

manager:: Maybe Command -> IO()
manager Nothing = do
            error "Error"
            return ()
manager (Just(Command order message)) = do
      case (lookup order list_of_functions) of
        Nothing -> error "error"
        Just f -> do
          let a = f message
          return ()
      









