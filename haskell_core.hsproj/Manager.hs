{-# LANGUAGE OverloadedStrings #-}

module Manager( receiver,
                sender,
                manager
) where

import Utils.JSON
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

import System.Posix
import Utils.Logging


receiver:: Socket -> Map String (String -> String) -> IO()
receiver sock map_functions =
    forever $ do
        messageReceived <- recv sock 1024
        let message = str_to_json $ B.unpack messageReceived
        manager message map_functions
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

manager:: Maybe Command -> Map String (String -> String) -> IO ()
manager Nothing _ = do
            error "Error"
            return ()
manager (Just(Command order message)) map_functions = do
      case (lookup order map_functions) of
        Nothing -> error "error"
        Just f -> do
          let a = f message
          logging a
          return ()
      




