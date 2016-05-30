{-# LANGUAGE OverloadedStrings #-}

module Manager( receiver,
                sender,
                manager
) where

import JSON_Parser
import Data


import Control.Monad
import qualified Data.ByteString.Char8 as B

import Network.Socket hiding (send, sendTo, recv, recvFrom)
import Network.Socket.ByteString

import System.IO
import System.Posix

-- concurrency
import Control.Exception
import Control.Concurrent


-- receiver:: (Socket z t)  -> Channel (Maybe Command) -> IO()
receiver chan sock =
    forever $ do
        messageReceived <- recv sock 1024
        let message = str_to_json $ B.unpack messageReceived
        let v = manager message
        print v
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

manager:: Maybe Command -> String
manager Nothing = "Error"
manager (Just(Command order message)) = order ++ " " ++ message