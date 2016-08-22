{-# LANGUAGE OverloadedStrings #-}

module Hapyskell.Manager( 
            receiver,
            sender,
            incoming_messages_manager
) where

import Hapyskell.Utils.JSON
import Hapyskell.Structures
import Hapyskell.Utils.Logging

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

import System.Posix


receiver:: Socket -> Map String (String -> String) -> IO()
receiver sock map_functions =
    forever $ do
        messageReceived <- recv sock 1024
        let message = str_to_json $ B.unpack messageReceived
        incoming_messages_manager message map_functions
        return ()

sender:: Channel (Maybe Command) -> Socket -> IO()
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

incoming_messages_manager:: Maybe Command -> Map String (String -> String) -> IO ()
incoming_messages_manager Nothing _ = do
                                     error "Error"
                                     return ()
incoming_messages_manager (Just(Command order message)) map_functions = do
      case (lookup order map_functions) of
        Nothing -> logging "error"
        Just f -> do
          let a = f message
          logging a
          return ()
      




